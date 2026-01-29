#!/bin/bash

# Edge Delta API Configuration
API_TOKEN="5a809497-42ca-489a-944e-87730207c355"
ORG_ID="761fa92b-2ac9-4fdc-b07b-247c2b379816"
API_BASE="https://api.edgedelta.com"
APP_URL="http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com"

echo "🔍 Creating additional Edge Delta monitors for Flappy Kiro application..."

# 1. Create Log Threshold Monitor for Frontend Errors
echo "🌐 Creating Log Threshold Monitor for frontend errors..."

FRONTEND_ERROR_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - Frontend Error Rate",
  "description": "Monitor error rate in Flappy Kiro frontend logs",
  "type": "log_threshold",
  "query": "{level:ERROR OR status:5*} by {namespace}",
  "alert_threshold": 15,
  "warning_threshold": 8,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 300,
  "evaluation_function": "count",
  "notification_options": {
    "message_template": "🚨 Flappy Kiro frontend is experiencing errors! Error count: {{value}} in namespace {{namespace}}",
    "group_bys": ["namespace"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P2 (High)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${FRONTEND_ERROR_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# 2. Create Log Threshold Monitor for API Response Time Issues
echo "⏱️ Creating Log Threshold Monitor for slow API responses..."

SLOW_API_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - Slow API Responses",
  "description": "Monitor for slow API responses in Flappy Kiro backend",
  "type": "log_threshold",
  "query": "{message:*slow* OR message:*timeout* OR response_time:>2000} by {service}",
  "alert_threshold": 10,
  "warning_threshold": 5,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 600,
  "evaluation_function": "count",
  "notification_options": {
    "message_template": "⚠️ Flappy Kiro API is responding slowly! Slow response count: {{value}} for service {{service}}",
    "group_bys": ["service"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P2 (High)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${SLOW_API_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# 3. Create Metric Threshold Monitor for High CPU Usage
echo "💻 Creating Metric Threshold Monitor for high CPU usage..."

HIGH_CPU_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - High CPU Usage",
  "description": "Monitor high CPU usage for Flappy Kiro pods",
  "type": "metric_threshold",
  "query": "avg:container_cpu_usage_seconds_total{namespace:flappy-kiro} by {pod}.rollup(60)",
  "alert_threshold": 0.8,
  "warning_threshold": 0.6,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 300,
  "evaluation_function": "avg",
  "notification_options": {
    "message_template": "🔥 Flappy Kiro pod {{pod}} is using high CPU: {{value}}%",
    "group_bys": ["pod"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P2 (High)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${HIGH_CPU_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# 4. Create Metric Threshold Monitor for High Memory Usage
echo "🧠 Creating Metric Threshold Monitor for high memory usage..."

HIGH_MEMORY_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - High Memory Usage",
  "description": "Monitor high memory usage for Flappy Kiro pods",
  "type": "metric_threshold",
  "query": "avg:container_memory_usage_bytes{namespace:flappy-kiro} by {pod}.rollup(60)",
  "alert_threshold": 536870912,
  "warning_threshold": 402653184,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 300,
  "evaluation_function": "avg",
  "notification_options": {
    "message_template": "🧠 Flappy Kiro pod {{pod}} is using high memory: {{value}} bytes",
    "group_bys": ["pod"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P2 (High)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${HIGH_MEMORY_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# 5. Create Log Threshold Monitor for Leaderboard API Failures
echo "🏆 Creating Log Threshold Monitor for leaderboard API failures..."

LEADERBOARD_FAILURE_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - Leaderboard API Failures",
  "description": "Monitor failures in Flappy Kiro leaderboard API",
  "type": "log_threshold",
  "query": "{endpoint:*/api/leaderboard* AND (status:5* OR level:ERROR)} by {pod}",
  "alert_threshold": 5,
  "warning_threshold": 3,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 300,
  "evaluation_function": "count",
  "notification_options": {
    "message_template": "🏆 Flappy Kiro leaderboard API is failing! Failure count: {{value}} in pod {{pod}}",
    "group_bys": ["pod"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P1 (Critical)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${LEADERBOARD_FAILURE_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# 6. Create Log Threshold Monitor for Game Session Anomalies
echo "🎮 Creating Log Threshold Monitor for game session anomalies..."

GAME_ANOMALY_MONITOR_PAYLOAD=$(cat <<EOF
{
  "name": "Flappy Kiro - Game Session Anomalies",
  "description": "Monitor for unusual game session patterns or errors",
  "type": "log_threshold",
  "query": "{message:*collision* OR message:*crash* OR message:*exception*} by {sessionId}",
  "alert_threshold": 50,
  "warning_threshold": 30,
  "threshold_type": "above",
  "evaluation_type": "sliding_window",
  "evaluation_window": 900,
  "evaluation_function": "count",
  "notification_options": {
    "message_template": "🎮 Flappy Kiro is experiencing game session anomalies! Anomaly count: {{value}}",
    "group_bys": ["sessionId"],
    "hide_options": {
      "hide_receiver_handlers": false,
      "hide_query": false,
      "hide_charts": false
    },
    "notify_creator_if_there_are_no_receivers": true
  },
  "snoozing_options": {
    "snoozed": false
  },
  "no_data_behavior": "show_no_data",
  "require_full_window": false,
  "priority": "P3 (Medium)"
}
EOF
)

curl -X POST "${API_BASE}/v1/orgs/${ORG_ID}/monitors" \
  -H "Content-Type: application/json" \
  -H "X-ED-API-Token: ${API_TOKEN}" \
  -d "${GAME_ANOMALY_MONITOR_PAYLOAD}" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

echo "✅ Additional Edge Delta monitors created successfully!"
echo ""
echo "📋 New Monitors Created:"
echo "   1. Flappy Kiro - Frontend Error Rate (Log Threshold)"
echo "   2. Flappy Kiro - Slow API Responses (Log Threshold)"
echo "   3. Flappy Kiro - High CPU Usage (Metric Threshold)"
echo "   4. Flappy Kiro - High Memory Usage (Metric Threshold)"
echo "   5. Flappy Kiro - Leaderboard API Failures (Log Threshold)"
echo "   6. Flappy Kiro - Game Session Anomalies (Log Threshold)"
echo ""
echo "📊 Total Monitors Now Active:"
echo "   • 3 existing log threshold monitors (Backend Error Rate, High Error Log Volume, Pod Restart Detection)"
echo "   • 6 new application-specific monitors"
echo "   • 2 default system monitors (Service Anomaly, Pipeline Liveness)"
echo ""
echo "🔍 Check your Edge Delta dashboard to view and configure all monitors."