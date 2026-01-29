#!/bin/bash

# GitHub Push Script
# Run this after creating your GitHub repository

echo "🚀 Pushing Flappy Kiro Cloud Platform to GitHub..."

# Replace YOUR_USERNAME with your actual GitHub username
GITHUB_USERNAME="YOUR_USERNAME"
REPO_NAME="flappy-kiro-cloud-platform"

echo "📝 Make sure you've created the repository at:"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""

read -p "Have you created the GitHub repository? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please create the repository first at https://github.com/new"
    echo "Repository name: $REPO_NAME"
    echo "Description: Enterprise cloud gaming platform demonstrating Kubernetes, AWS, and DevOps best practices"
    echo "Make it Public and don't initialize with README"
    exit 1
fi

# Add remote origin
echo "🔗 Adding GitHub remote..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# Set main branch
echo "🌿 Setting main branch..."
git branch -M main

# Push to GitHub
echo "⬆️ Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Successfully pushed to GitHub!"
echo ""
echo "🎯 Your repository is now live at:"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "📋 Next steps:"
echo "1. Add repository topics: kubernetes, aws, devops, microservices, docker"
echo "2. Pin this repository to your GitHub profile"
echo "3. Add a professional description to your GitHub profile"
echo "4. Share on LinkedIn to showcase your skills!"
echo ""
echo "🌟 This repository demonstrates enterprise-level DevOps skills!"