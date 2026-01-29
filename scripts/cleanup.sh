#!/bin/bash

set -e

echo "🧹 Cleaning up Flappy Kiro microservices from Kubernetes"

# Navigate to k8s directory
cd ../k8s

# Delete application resources
echo "🗑️  Deleting application resources..."
kubectl delete -f ingress.yaml --ignore-not-found=true
kubectl delete -f frontend-service.yaml --ignore-not-found=true
kubectl delete -f frontend-deployment.yaml --ignore-not-found=true
kubectl delete -f backend-service.yaml --ignore-not-found=true
kubectl delete -f backend-deployment.yaml --ignore-not-found=true

# Wait for resources to be deleted
echo "⏳ Waiting for resources to be deleted..."
sleep 10

# Delete namespace (this will delete any remaining resources)
kubectl delete -f namespace.yaml --ignore-not-found=true

# Optional: Clean up ECR repositories
read -p "🗑️  Do you want to delete ECR repositories? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    AWS_REGION="us-west-1"
    echo "🗑️  Deleting ECR repositories..."
    aws --profile kiro-eks-workshop ecr delete-repository --repository-name flappy-kiro-backend --region ${AWS_REGION} --force 2>/dev/null || echo "Backend repository not found"
    aws --profile kiro-eks-workshop ecr delete-repository --repository-name flappy-kiro-frontend --region ${AWS_REGION} --force 2>/dev/null || echo "Frontend repository not found"
fi

# Optional: Clean up AWS Load Balancer Controller
read -p "🗑️  Do you want to uninstall AWS Load Balancer Controller? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Uninstalling AWS Load Balancer Controller..."
    helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || echo "AWS Load Balancer Controller not found"
    kubectl delete -f aws-load-balancer-controller.yaml --ignore-not-found=true
fi

echo "✅ Cleanup completed!"