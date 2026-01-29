#!/bin/bash

set -e

echo "🚀 Deploying Flappy Kiro microservices to Kubernetes"

# Check if kubectl is configured for the right cluster
CURRENT_CONTEXT=$(kubectl config current-context)
echo "📋 Current kubectl context: ${CURRENT_CONTEXT}"

if [[ ! "${CURRENT_CONTEXT}" =~ "eks-kiro-demo" ]]; then
    echo "⚠️  Warning: Current context doesn't seem to be the EKS cluster"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Navigate to k8s directory
cd ../k8s

# Install AWS Load Balancer Controller if not already installed
echo "🔧 Setting up AWS Load Balancer Controller..."

# Check if AWS Load Balancer Controller is already installed
if kubectl get deployment -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
    echo "✅ AWS Load Balancer Controller already installed"
else
    echo "📦 Installing AWS Load Balancer Controller..."
    
    # Apply RBAC resources
    kubectl apply -f aws-load-balancer-controller.yaml
    
    # Install using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=eks-kiro-demo \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=us-west-1 \
        --set vpcId=$(aws --profile kiro-eks-workshop ec2 describe-vpcs --filters "Name=tag:Name,Values=eksctl-eks-kiro-demo-cluster/VPC" --query "Vpcs[0].VpcId" --output text --region us-west-1)
fi

# Deploy application
echo "📦 Deploying Flappy Kiro application..."

# Create namespace
kubectl apply -f namespace.yaml

# Deploy backend
echo "🔧 Deploying backend..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# Deploy frontend
echo "🌐 Deploying frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Deploy ingress
echo "🌍 Deploying ingress..."
kubectl apply -f ingress.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/flappy-kiro-backend -n flappy-kiro
kubectl wait --for=condition=available --timeout=300s deployment/flappy-kiro-frontend -n flappy-kiro

# Show deployment status
echo "📊 Deployment Status:"
kubectl get pods -n flappy-kiro
echo ""
kubectl get services -n flappy-kiro
echo ""
kubectl get ingress -n flappy-kiro

# Get ALB URL
echo "⏳ Waiting for ALB to be provisioned (this may take a few minutes)..."
sleep 30

ALB_URL=$(kubectl get ingress flappy-kiro-ingress -n flappy-kiro -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$ALB_URL" ]; then
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo "🌐 Application URL: http://${ALB_URL}"
    echo ""
    echo "📋 Useful commands:"
    echo "   View pods:     kubectl get pods -n flappy-kiro"
    echo "   View logs:     kubectl logs -f deployment/flappy-kiro-backend -n flappy-kiro"
    echo "   View ingress:  kubectl get ingress -n flappy-kiro"
    echo "   Port forward:  kubectl port-forward svc/flappy-kiro-frontend 8080:80 -n flappy-kiro"
else
    echo ""
    echo "⚠️  ALB URL not yet available. Check ingress status:"
    echo "   kubectl get ingress -n flappy-kiro -w"
fi