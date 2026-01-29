#!/bin/bash

set -e

# Configuration
AWS_REGION="us-west-1"
AWS_ACCOUNT_ID=$(aws --profile kiro-eks-workshop sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_REPO="flappy-kiro-backend"
FRONTEND_REPO="flappy-kiro-frontend"
IMAGE_TAG="v1.0.0"

echo "🚀 Building and pushing Flappy Kiro microservices to ECR"
echo "AWS Account: ${AWS_ACCOUNT_ID}"
echo "Region: ${AWS_REGION}"
echo "Registry: ${ECR_REGISTRY}"

# Authenticate Docker to ECR
echo "🔐 Authenticating Docker to ECR..."
aws --profile kiro-eks-workshop ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Create ECR repositories if they don't exist
echo "📦 Creating ECR repositories..."
aws --profile kiro-eks-workshop ecr create-repository --repository-name ${BACKEND_REPO} --region ${AWS_REGION} 2>/dev/null || echo "Backend repository already exists"
aws --profile kiro-eks-workshop ecr create-repository --repository-name ${FRONTEND_REPO} --region ${AWS_REGION} 2>/dev/null || echo "Frontend repository already exists"

# Build and push backend image
echo "🔨 Building backend image..."
cd ../backend
docker build -t ${BACKEND_REPO}:${IMAGE_TAG} .
docker tag ${BACKEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}
docker tag ${BACKEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${BACKEND_REPO}:latest

echo "📤 Pushing backend image..."
docker push ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}
docker push ${ECR_REGISTRY}/${BACKEND_REPO}:latest

# Build and push frontend image
echo "🔨 Building frontend image..."
cd ../frontend
docker build -t ${FRONTEND_REPO}:${IMAGE_TAG} .
docker tag ${FRONTEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}
docker tag ${FRONTEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${FRONTEND_REPO}:latest

echo "📤 Pushing frontend image..."
docker push ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}
docker push ${ECR_REGISTRY}/${FRONTEND_REPO}:latest

# Update Kubernetes manifests with image URIs
echo "📝 Updating Kubernetes manifests..."
cd ../k8s

# Update backend deployment
sed -i.bak "s|BACKEND_IMAGE_PLACEHOLDER|${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}|g" backend-deployment.yaml

# Update frontend deployment
sed -i.bak "s|FRONTEND_IMAGE_PLACEHOLDER|${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}|g" frontend-deployment.yaml

# Update AWS Load Balancer Controller with account ID
sed -i.bak "s|ACCOUNT_ID|${AWS_ACCOUNT_ID}|g" aws-load-balancer-controller.yaml

echo "✅ Build and push completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy to Kubernetes: ./deploy.sh"
echo "2. Check deployment status: kubectl get pods -n flappy-kiro"
echo "3. Get ALB URL: kubectl get ingress -n flappy-kiro"
echo ""
echo "🖼️  Images pushed:"
echo "   Backend:  ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}"
echo "   Frontend: ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}"