// OTEL-like logging for frontend microservice
class Logger {
    constructor() {
        this.sessionId = Math.random().toString(36).substr(2, 9);
        this.podId = this.generatePodId();
    }
    
    generatePodId() {
        return `frontend-${Math.random().toString(36).substr(2, 8)}`;
    }
    
    log(level, message, data = {}) {
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level,
            message,
            sessionId: this.sessionId,
            podId: this.podId,
            service: 'flappy-kiro-frontend',
            ...data
        };
        console.log(`[${level}] ${message}`, logEntry);
        
        // Send logs to backend for centralized logging (optional)
        if (level === 'ERROR') {
            this.sendLogToBackend(logEntry);
        }
    }
    
    async sendLogToBackend(logEntry) {
        try {
            await fetch(`${API_BASE}/logs`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(logEntry)
            });
        } catch (e) {
            // Fail silently for logging
        }
    }
    
    info(message, data) { this.log('INFO', message, data); }
    error(message, data) { this.log('ERROR', message, data); }
    debug(message, data) { this.log('DEBUG', message, data); }
}

const logger = new Logger();

// Game configuration
const GAME_CONFIG = {
    Easy: { gravity: 0.3, jumpPower: -6, wallSpeed: 2, wallGap: 200 },
    Medium: { gravity: 0.4, jumpPower: -7, wallSpeed: 3, wallGap: 180 },
    Hard: { gravity: 0.5, jumpPower: -8, wallSpeed: 4, wallGap: 160 }
};

// Game state
let game = {
    canvas: null,
    ctx: null,
    ghosty: { x: 100, y: 300, width: 40, height: 40, velocity: 0 },
    walls: [],
    score: 0,
    gameRunning: false,
    difficulty: 'Easy',
    config: GAME_CONFIG.Easy
};

// API configuration - will be set by backend service discovery
const API_BASE = '/api';

// Initialize game and check backend connectivity
function initGame() {
    logger.info('Initializing Flappy Kiro Kubernetes microservice');
    
    game.canvas = document.getElementById('gameCanvas');
    game.ctx = game.canvas.getContext('2d');
    
    // Event listeners
    document.addEventListener('keydown', handleKeyPress);
    
    // Update pod info
    document.getElementById('podInfo').textContent = logger.podId;
    
    // Check backend connectivity
    checkBackendHealth();
    
    // Load initial leaderboard
    loadLeaderboard();
    
    logger.info('Frontend microservice initialized successfully');
}

async function checkBackendHealth() {
    try {
        const response = await fetch(`${API_BASE}/../health`);
        const data = await response.json();
        
        if (response.ok) {
            document.getElementById('backendStatus').textContent = `✅ ${data.service}`;
            logger.info('Backend health check passed', data);
        } else {
            throw new Error('Backend unhealthy');
        }
    } catch (error) {
        document.getElementById('backendStatus').textContent = '❌ Unavailable';
        logger.error('Backend health check failed', { error: error.message });
    }
}

function handleKeyPress(event) {
    if (event.code === 'Space' && game.gameRunning) {
        event.preventDefault();
        jump();
    }
}

function jump() {
    game.ghosty.velocity = game.config.jumpPower;
    logger.debug('Ghosty jumped', { velocity: game.ghosty.velocity });
}

function startGame() {
    logger.info('Starting new game', { difficulty: game.difficulty });
    
    game.difficulty = document.getElementById('difficulty').value;
    game.config = GAME_CONFIG[game.difficulty];
    
    // Reset game state
    game.ghosty = { x: 100, y: 300, width: 40, height: 40, velocity: 0 };
    game.walls = [];
    game.score = 0;
    game.gameRunning = true;
    
    updateScore();
    gameLoop();
}

function gameLoop() {
    if (!game.gameRunning) return;
    
    update();
    draw();
    requestAnimationFrame(gameLoop);
}

function update() {
    // Update Ghosty physics
    game.ghosty.velocity += game.config.gravity;
    game.ghosty.y += game.ghosty.velocity;
    
    // Check ground collision
    if (game.ghosty.y + game.ghosty.height >= game.canvas.height) {
        endGame('Ground collision');
        return;
    }
    
    // Check ceiling collision
    if (game.ghosty.y <= 0) {
        endGame('Ceiling collision');
        return;
    }
    
    // Update walls
    updateWalls();
    
    // Check wall collisions
    checkCollisions();
}

function updateWalls() {
    // Move existing walls
    for (let wall of game.walls) {
        wall.x -= game.config.wallSpeed;
    }
    
    // Remove off-screen walls and update score
    game.walls = game.walls.filter(wall => {
        if (wall.x + wall.width < 0) {
            if (!wall.scored) {
                game.score++;
                updateScore();
                logger.debug('Score increased', { score: game.score });
            }
            return false;
        }
        return true;
    });
    
    // Add new walls
    if (game.walls.length === 0 || game.walls[game.walls.length - 1].x < game.canvas.width - 300) {
        addWall();
    }
}

function addWall() {
    const gapY = Math.random() * (game.canvas.height - game.config.wallGap - 100) + 50;
    
    game.walls.push({
        x: game.canvas.width,
        topHeight: gapY,
        bottomY: gapY + game.config.wallGap,
        bottomHeight: game.canvas.height - (gapY + game.config.wallGap),
        width: 60,
        scored: false
    });
    
    logger.debug('New wall added', { gapY, wallCount: game.walls.length });
}

function checkCollisions() {
    for (let wall of game.walls) {
        // Check if Ghosty is in wall's x range
        if (game.ghosty.x < wall.x + wall.width && 
            game.ghosty.x + game.ghosty.width > wall.x) {
            
            // Check collision with top or bottom wall
            if (game.ghosty.y < wall.topHeight || 
                game.ghosty.y + game.ghosty.height > wall.bottomY) {
                endGame('Wall collision');
                return;
            }
            
            // Mark wall as scored if Ghosty passes through
            if (!wall.scored && game.ghosty.x > wall.x + wall.width) {
                wall.scored = true;
            }
        }
    }
}

function draw() {
    // Clear canvas
    game.ctx.fillStyle = '#87CEEB';
    game.ctx.fillRect(0, 0, game.canvas.width, game.canvas.height);
    
    // Draw Ghosty (simple ghost shape)
    drawGhosty();
    
    // Draw walls
    game.ctx.fillStyle = '#228B22';
    for (let wall of game.walls) {
        // Top wall
        game.ctx.fillRect(wall.x, 0, wall.width, wall.topHeight);
        // Bottom wall
        game.ctx.fillRect(wall.x, wall.bottomY, wall.width, wall.bottomHeight);
    }
}

function drawGhosty() {
    const ctx = game.ctx;
    const x = game.ghosty.x;
    const y = game.ghosty.y;
    const w = game.ghosty.width;
    const h = game.ghosty.height;
    
    // Draw ghost body (white circle)
    ctx.fillStyle = 'white';
    ctx.beginPath();
    ctx.arc(x + w/2, y + h/2, w/2, 0, Math.PI * 2);
    ctx.fill();
    
    // Draw eyes
    ctx.fillStyle = 'black';
    ctx.beginPath();
    ctx.arc(x + w/3, y + h/3, 4, 0, Math.PI * 2);
    ctx.arc(x + 2*w/3, y + h/3, 4, 0, Math.PI * 2);
    ctx.fill();
    
    // Draw mouth
    ctx.beginPath();
    ctx.arc(x + w/2, y + 2*h/3, 6, 0, Math.PI);
    ctx.stroke();
}

function updateScore() {
    document.getElementById('currentScore').textContent = game.score;
}

function endGame(reason) {
    logger.info('Game ended', { reason, score: game.score, difficulty: game.difficulty });
    
    game.gameRunning = false;
    
    // Show game over modal
    document.getElementById('finalScore').textContent = game.score;
    document.getElementById('finalDifficulty').textContent = game.difficulty;
    document.getElementById('gameOverModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('gameOverModal').style.display = 'none';
    document.getElementById('usernameInput').value = '';
}

async function submitScore() {
    const username = document.getElementById('usernameInput').value.trim();
    
    if (!username) {
        alert('Please enter a username');
        return;
    }
    
    logger.info('Submitting score to backend microservice', { 
        username, 
        score: game.score, 
        difficulty: game.difficulty 
    });
    
    try {
        const response = await fetch(`${API_BASE}/score`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: username,
                score: game.score,
                difficulty: game.difficulty
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            logger.info('Score submitted successfully to backend', data);
            alert('Score submitted successfully!');
            closeModal();
            loadLeaderboard();
        } else {
            logger.error('Failed to submit score to backend', data);
            alert(`Error: ${data.error}`);
        }
    } catch (error) {
        logger.error('Network error submitting score to backend', { error: error.message });
        alert('Network error. Please try again.');
    }
}

async function loadLeaderboard() {
    logger.info('Loading leaderboard from backend microservice');
    
    try {
        const response = await fetch(`${API_BASE}/leaderboard`);
        const scores = await response.json();
        
        const leaderboardList = document.getElementById('leaderboardList');
        
        if (scores.length === 0) {
            leaderboardList.innerHTML = '<p>No scores yet. Be the first!</p>';
            return;
        }
        
        leaderboardList.innerHTML = scores.map((score, index) => `
            <div class="score-entry">
                <span>#${index + 1} ${score.username}</span>
                <span>${score.score} (${score.difficulty})</span>
            </div>
        `).join('');
        
        logger.info('Leaderboard loaded from backend', { scoreCount: scores.length });
        
    } catch (error) {
        logger.error('Failed to load leaderboard from backend', { error: error.message });
        document.getElementById('leaderboardList').innerHTML = '<p>Failed to load leaderboard</p>';
    }
}

// Initialize when page loads
window.addEventListener('load', initGame);

// Periodic health checks
setInterval(checkBackendHealth, 30000);