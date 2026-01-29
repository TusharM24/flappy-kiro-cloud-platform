import json
import os
import re
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.instrumentation.flask import FlaskInstrumentor
import logging

# Configure OTEL
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

app = Flask(__name__)
CORS(app)

# Instrument Flask with OTEL
FlaskInstrumentor().instrument_app(app)

# Configure logging for Kubernetes
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Use persistent volume for data storage in Kubernetes
LEADERBOARD_FILE = '/data/leaderboard.json'

def ensure_data_directory():
    """Ensure data directory exists"""
    os.makedirs(os.path.dirname(LEADERBOARD_FILE), exist_ok=True)

def load_leaderboard():
    """Load leaderboard from JSON file"""
    with tracer.start_as_current_span("load_leaderboard"):
        ensure_data_directory()
        if os.path.exists(LEADERBOARD_FILE):
            try:
                with open(LEADERBOARD_FILE, 'r') as f:
                    data = json.load(f)
                    logger.info(f"Loaded {len(data)} scores from leaderboard")
                    return data
            except Exception as e:
                logger.error(f"Error loading leaderboard: {e}")
                return []
        return []

def save_leaderboard(data):
    """Save leaderboard to JSON file"""
    with tracer.start_as_current_span("save_leaderboard"):
        try:
            ensure_data_directory()
            with open(LEADERBOARD_FILE, 'w') as f:
                json.dump(data, f, indent=2)
            logger.info(f"Saved {len(data)} scores to leaderboard")
            return True
        except Exception as e:
            logger.error(f"Error saving leaderboard: {e}")
            return False

def validate_username(username):
    """Validate username - alphanumeric, 3-20 chars, no profanity"""
    with tracer.start_as_current_span("validate_username"):
        if not username or len(username) < 3 or len(username) > 20:
            return False, "Username must be 3-20 characters"
        
        if not re.match("^[a-zA-Z0-9_-]+$", username):
            return False, "Username can only contain letters, numbers, _ and -"
        
        # Basic profanity filter
        banned_words = ['admin', 'root', 'test', 'null', 'undefined']
        if username.lower() in banned_words:
            return False, "Username not allowed"
        
        return True, "Valid"

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint for Kubernetes"""
    with tracer.start_as_current_span("health_check"):
        logger.info("Health check requested")
        return jsonify({
            "status": "healthy", 
            "timestamp": datetime.now().isoformat(),
            "service": "flappy-kiro-backend"
        })

@app.route('/ready', methods=['GET'])
def ready():
    """Readiness check endpoint for Kubernetes"""
    with tracer.start_as_current_span("readiness_check"):
        try:
            # Test if we can access the data directory
            ensure_data_directory()
            logger.info("Readiness check passed")
            return jsonify({
                "status": "ready", 
                "timestamp": datetime.now().isoformat(),
                "service": "flappy-kiro-backend"
            })
        except Exception as e:
            logger.error(f"Readiness check failed: {e}")
            return jsonify({"status": "not ready", "error": str(e)}), 503

@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    """Get top 10 scores"""
    with tracer.start_as_current_span("get_leaderboard"):
        try:
            data = load_leaderboard()
            # Sort by score descending, take top 10
            top_scores = sorted(data, key=lambda x: x['score'], reverse=True)[:10]
            logger.info(f"Retrieved top {len(top_scores)} scores")
            return jsonify(top_scores)
        except Exception as e:
            logger.error(f"Error getting leaderboard: {e}")
            return jsonify({"error": "Failed to load leaderboard"}), 500

@app.route('/api/score', methods=['POST'])
def submit_score():
    """Submit a new high score"""
    with tracer.start_as_current_span("submit_score") as span:
        try:
            data = request.get_json()
            username = data.get('username', '').strip()
            score = data.get('score', 0)
            difficulty = data.get('difficulty', 'Easy')
            
            span.set_attributes({
                "username": username,
                "score": score,
                "difficulty": difficulty
            })
            
            # Validate input
            if not isinstance(score, int) or score < 0:
                return jsonify({"error": "Invalid score"}), 400
            
            if difficulty not in ['Easy', 'Medium', 'Hard']:
                return jsonify({"error": "Invalid difficulty"}), 400
            
            valid, message = validate_username(username)
            if not valid:
                return jsonify({"error": message}), 400
            
            # Load current leaderboard
            leaderboard = load_leaderboard()
            
            # Add new score
            new_entry = {
                "username": username,
                "score": score,
                "difficulty": difficulty,
                "timestamp": datetime.now().isoformat()
            }
            
            leaderboard.append(new_entry)
            
            # Save updated leaderboard
            if save_leaderboard(leaderboard):
                logger.info(f"New score submitted: {username} - {score} ({difficulty})")
                return jsonify({"message": "Score submitted successfully", "entry": new_entry})
            else:
                return jsonify({"error": "Failed to save score"}), 500
                
        except Exception as e:
            logger.error(f"Error submitting score: {e}")
            return jsonify({"error": "Failed to submit score"}), 500

if __name__ == '__main__':
    logger.info("Starting Flappy Kiro Backend Microservice")
    app.run(debug=False, host='0.0.0.0', port=8080)