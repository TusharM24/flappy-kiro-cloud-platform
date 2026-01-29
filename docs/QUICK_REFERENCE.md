# Quick Reference Guide - Flappy Kiro

## 🔗 Important URLs & Credentials

### Application Access
- **Game URL**: http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com
- **Health Check**: http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com/health
- **Leaderboard API**: http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com/api/leaderboard

### Edge Delta Monitoring
- **Organization ID**: 761fa92b-2ac9-4fdc-b07b-247c2b379816
- **API Token**: 5a809497-42ca-489a-944e-87730207c355
- **Dashboard**: https://app.edgedelta.com (login required)

### AWS Resources
- **EKS Cluster**: eks-kiro-demo
- **Region**: us-west-1
- **Profile**: kiro-eks-workshop

---

## ⚡ Essential Commands

### Check Everything is Running
```bash
# Check all pods across all namespaces
kubectl get pods --all-namespaces

# Check application pods specifically
kubectl get pods -n flappy-kiro

# Check ingress and get ALB URL
kubectl get ingress -n flappy-kiro

# Test the application
curl -I http://k8s-flappyki-flappyki-15011faced-599969868.us-west-1.elb.amazonaws.com
```

### Monitoring Commands
```bash
# Check Edge Delta agents
kubectl get pods -n edgedelta

# View Edge Delta logs
kubectl logs -n edgedelta -l app=edgedelta

# Run monitoring test
./test-flappy-kiro-monitoring.sh

# Create additional monitors
./create-edgedelta-monitors.sh
```

### Troubleshooting Commands
```bash
# Check pod details
kubectl describe pod [pod-name] -n flappy-kiro

# View pod logs
kubectl logs [pod-name] -n flappy-kiro

# Check load balancer controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check ingress details
kubectl describe ingress flappy-kiro-ingress -n flappy-kiro
```

### AWS Commands (with profile)
```bash
# List EKS clusters
aws --profile kiro-eks-workshop eks list-clusters

# Check load balancers
aws --profile kiro-eks-workshop elbv2 describe-load-balancers

# Check target groups
aws --profile kiro-eks-workshop elbv2 describe-target-groups
```

---

## 📁 Project File Structure

```
.
├── eks-kiro-demo-config.yaml              # EKS cluster configuration
├── create-edgedelta-monitors.sh           # Monitor creation script
├── test-flappy-kiro-monitoring.sh         # Application testing script
├── COMPLETE_PROJECT_DOCUMENTATION.md      # Full documentation
├── SIMPLE_ARCHITECTURE_GUIDE.md           # Simple explanations
├── QUICK_REFERENCE.md                     # This file
├── EDGE_DELTA_MONITORING_SUMMARY.md       # Monitoring details
│
├── flappy-kiro/                           # Original game (standalone)
│   ├── frontend/
│   │   ├── index.html
│   │   └── game.js
│   ├── backend/
│   │   ├── app.py
│   │   └── requirements.txt
│   └── start.sh
│
└── flappy-kiro-k8s/                       # Kubernetes version
    ├── frontend/
    │   ├── Dockerfile
    │   ├── index.html
    │   ├── game.js
    │   └── nginx.conf
    ├── backend/
    │   ├── Dockerfile
    │   ├── app.py
    │   └── requirements.txt
    ├── k8s/                               # Kubernetes manifests
    │   ├── namespace.yaml
    │   ├── backend-deployment.yaml
    │   ├── backend-service.yaml
    │   ├── frontend-deployment.yaml
    │   ├── frontend-service.yaml
    │   ├── ingress.yaml
    │   └── aws-load-balancer-controller.yaml
    └── scripts/
        ├── build-and-push.sh
        ├── deploy.sh
        └── cleanup.sh
```

---

## 🎯 Current Status Summary

### ✅ What's Working
- **EKS Cluster**: eks-kiro-demo (3 nodes, running)
- **Application**: 4 pods running (2 frontend, 2 backend)
- **Load Balancer**: ALB active and routing traffic
- **Monitoring**: 11 Edge Delta monitors active
- **Game**: Fully playable with leaderboard

### 📊 Resource Usage
- **Pods**: 24 total across all namespaces
- **Namespaces**: flappy-kiro, edgedelta, kube-system, cert-manager
- **Services**: 2 (frontend NodePort, backend ClusterIP)
- **Ingress**: 1 (ALB configuration)

### 🔍 Monitoring Coverage
- **Log Monitors**: 6 (errors, performance, API failures)
- **Metric Monitors**: 2 (CPU, memory usage)
- **Infrastructure Monitors**: 3 (restarts, anomalies, system health)

---

## 🚨 Emergency Procedures

### If the Game is Down
```bash
# 1. Check pod status
kubectl get pods -n flappy-kiro

# 2. Check ingress
kubectl get ingress -n flappy-kiro

# 3. Check load balancer controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller --tail=10

# 4. Restart pods if needed
kubectl rollout restart deployment/flappy-kiro-frontend -n flappy-kiro
kubectl rollout restart deployment/flappy-kiro-backend -n flappy-kiro
```

### If Monitoring is Not Working
```bash
# 1. Check Edge Delta pods
kubectl get pods -n edgedelta

# 2. Check Edge Delta logs
kubectl logs -n edgedelta -l app=edgedelta --tail=20

# 3. Restart Edge Delta if needed
kubectl rollout restart daemonset/edgedelta -n edgedelta
```

### If You Need to Rebuild Everything
```bash
# 1. Delete the application
kubectl delete namespace flappy-kiro

# 2. Redeploy
kubectl apply -f flappy-kiro-k8s/k8s/

# 3. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=flappy-kiro-frontend -n flappy-kiro --timeout=300s
```

---

## 📞 Support Information

### Key Metrics to Monitor
- **Response Time**: Should be < 100ms
- **Error Rate**: Should be < 1%
- **Pod Restarts**: Should be 0
- **CPU Usage**: Should be < 80%
- **Memory Usage**: Should be < 512MB per pod

### When to Be Concerned
- ❌ Pods showing "CrashLoopBackOff"
- ❌ Ingress showing no ADDRESS
- ❌ Response time > 5 seconds
- ❌ Multiple pod restarts
- ❌ Edge Delta monitors showing "Alert" status

### Success Indicators
- ✅ All pods showing "Running" status
- ✅ Ingress has ALB address
- ✅ Game loads in < 2 seconds
- ✅ Leaderboard saves scores
- ✅ Monitoring shows "No Data" or "OK" status

---

## 🎮 Game Instructions

### How to Play
1. Go to the game URL
2. Select difficulty (Easy/Medium/Hard)
3. Click "Start Game"
4. Press SPACEBAR to make Ghosty jump
5. Avoid walls and ground
6. Submit your score with a username

### Scoring System
- **Easy**: Slower speed, bigger gaps
- **Medium**: Normal speed, medium gaps  
- **Hard**: Fast speed, smaller gaps
- Each wall passed = 1 point

This reference guide contains everything you need to manage and troubleshoot your Flappy Kiro deployment!