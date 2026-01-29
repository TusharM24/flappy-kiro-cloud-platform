#!/bin/bash

# Demo Cleanup Script
# Removes all AWS resources to stop charges

set -e

echo "🧹 Flappy Kiro Demo Cleanup"
echo "==========================="
echo "This will delete ALL demo resources to stop AWS charges."
echo ""
read -p "Are you sure? This cannot be undone! (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 1
fi

echo "🗑️  Starting cleanup process..."

# Delete application resources first
echo "1/4 Deleting application resources..."
kubectl delete namespace flappy-kiro --ignore-not-found=true

# Delete Edge Delta
echo "2/4 Removing monitoring..."
helm uninstall edgedelta -n edgedelta --ignore-not-found
kubectl delete namespace edgedelta --ignore-not-found=true

# Delete cert-manager
echo "3/4 Removing cert-manager..."
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml --ignore-not-found=true

# Delete EKS cluster (this removes load balancers, node groups, etc.)
echo "4/4 Deleting EKS cluster..."
echo "⏱️  This may take 10-15 minutes..."
eksctl delete cluster --name eks-kiro-demo --profile kiro-eks-workshop

echo ""
echo "✅ Cleanup complete!"
echo "💰 AWS charges should stop within the hour."
echo ""
echo "📊 Final cost check:"
echo "  - Run: aws --profile kiro-eks-workshop eks list-clusters"
echo "  - Should return: empty list"
echo "  - Run: aws --profile kiro-eks-workshop elbv2 describe-load-balancers"
echo "  - Should return: empty list"