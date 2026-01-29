#!/bin/bash

# Test script to generate activity for Edge Delta monitors
APP_URL="http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com"

echo "🎮 Testing Flappy Kiro application to generate monitoring data..."

# Test 1: Check application availability
echo "📊 Testing application availability..."
for i in {1..5}; do
    echo "Request $i:"
    curl -s -w "HTTP Status: %{http_code}, Response Time: %{time_total}s\n" -o /dev/null "$APP_URL"
    sleep 2
done

echo ""

# Test 2: Check backend health endpoint
echo "🔧 Testing backend health endpoint..."
for i in {1..3}; do
    echo "Health check $i:"
    curl -s -w "HTTP Status: %{http_code}, Response Time: %{time_total}s\n" "$APP_URL/health" | head -1
    sleep 1
done

echo ""

# Test 3: Test leaderboard API
echo "🏆 Testing leaderboard API..."
for i in {1..3}; do
    echo "Leaderboard request $i:"
    curl -s -w "HTTP Status: %{http_code}, Response Time: %{time_total}s\n" "$APP_URL/api/leaderboard" | head -1
    sleep 1
done

echo ""

# Test 4: Submit some test scores to generate activity
echo "📝 Submitting test scores..."
for i in {1..3}; do
    SCORE=$((RANDOM % 50 + 10))
    USERNAME="TestUser$i"
    DIFFICULTY="Easy"
    
    echo "Submitting score: $USERNAME - $SCORE ($DIFFICULTY)"
    curl -s -X POST "$APP_URL/api/score" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"score\":$SCORE,\"difficulty\":\"$DIFFICULTY\"}" \
        -w "HTTP Status: %{http_code}\n"
    sleep 1
done

echo ""

# Test 5: Check Kubernetes pod status
echo "🔍 Checking Kubernetes pod status..."
kubectl get pods -n flappy-kiro -o wide

echo ""

# Test 6: Check recent logs from backend pods
echo "📋 Checking recent backend logs..."
kubectl logs -n flappy-kiro -l app=flappy-kiro-backend --tail=10

echo ""

# Test 7: Check recent logs from frontend pods
echo "🌐 Checking recent frontend logs..."
kubectl logs -n flappy-kiro -l app=flappy-kiro-frontend --tail=10

echo ""

echo "✅ Monitoring test completed!"
echo ""
echo "📊 What this test generated:"
echo "   • HTTP requests to main application (availability monitoring)"
echo "   • Health check requests (backend health monitoring)"
echo "   • Leaderboard API calls (API performance monitoring)"
echo "   • Score submissions (application functionality monitoring)"
echo "   • Pod status checks (infrastructure monitoring)"
echo "   • Log generation (log threshold monitoring)"
echo ""
echo "🔍 Check your Edge Delta dashboard in a few minutes to see the monitoring data."