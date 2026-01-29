#!/bin/bash

# Quick Demo Setup Script
# Estimated cost: $0.55/hour
# Setup time: 15-20 minutes

set -e

echo "🎮 Flappy Kiro Demo Setup"
echo "========================="
echo "⚠️  WARNING: This will incur AWS charges (~$0.55/hour)"
echo "💰 Estimated cost for 4-hour demo: ~$2.20"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Demo setup cancelled."
    exit 1
fi

echo "🚀 Starting demo cluster creation..."
echo "⏱️  ETA: 15-20 minutes"

# Create EKS cluster
echo "1/6 Creating EKS cluster..."
eksctl create cluster --config-file eks-kiro-demo-config.yaml --profile kiro-eks-workshop

# Deploy cert-manager
echo "2/6 Installing cert-manager..."
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s

# Deploy AWS Load Balancer Controller
echo "3/6 Installing AWS Load Balancer Controller..."
kubectl apply -f flappy-kiro-k8s/k8s/aws-load-balancer-controller.yaml
kubectl apply -f ingressclass.yaml

# Deploy application
echo "4/6 Deploying Flappy Kiro application..."
kubectl apply -f flappy-kiro-k8s/k8s/
kubectl wait --for=condition=ready pod -l app=flappy-kiro-frontend -n flappy-kiro --timeout=300s

# Set up Edge Delta monitoring
echo "5/6 Setting up monitoring..."
helm repo add edgedelta https://helm.edgedelta.com
helm repo update
helm upgrade edgedelta edgedelta/edgedelta -i --version 2.11.0 \
  --set secretApiKey.value=b815a7ff-81eb-46e1-a07a-bc6baafd74e4 \
  --set edApiEndpoint="https://api.edgedelta.com" \
  -n edgedelta --create-namespace

# Create monitors
echo "6/6 Creating monitoring dashboards..."
./create-edgedelta-monitors.sh

echo ""
echo "✅ Demo setup complete!"
echo ""
echo "🎮 Game URL: $(kubectl get ingress flappy-kiro-ingress -n flappy-kiro -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "📊 Monitoring: https://app.edgedelta.com"
echo ""
echo "⚠️  IMPORTANT: Run './cleanup-demo.sh' when done to avoid charges!"
echo ""
echo "📋 Demo checklist:"
echo "  □ Test game functionality"
echo "  □ Show Kubernetes dashboard"
echo "  □ Show monitoring dashboard"
echo "  □ Take screenshots"
echo "  □ Record demo video"
echo "  □ CLEANUP RESOURCES"