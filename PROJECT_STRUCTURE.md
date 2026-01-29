# Project Structure

```
flappy-kiro-cloud-platform/
├── README.md                           # Main project overview
├── LICENSE                             # MIT license
├── PROJECT_STRUCTURE.md                # This file
├── .gitignore                          # Git ignore rules
│
├── docs/                               # All documentation
│   ├── COMPLETE_PROJECT_DOCUMENTATION.md
│   ├── SIMPLE_ARCHITECTURE_GUIDE.md
│   ├── DEMO_STRATEGY.md
│   ├── COST_ANALYSIS_AND_CLEANUP.md
│   ├── QUICK_REFERENCE.md
│   └── EDGE_DELTA_MONITORING_SUMMARY.md
│
├── infrastructure/                     # Infrastructure as Code
│   ├── eks-kiro-demo-config.yaml      # EKS cluster configuration
│   ├── ingressclass.yaml              # Ingress class definition
│   ├── iam_policy.json                # IAM policies
│   └── v2_13_3_full.yaml              # Load balancer controller
│
├── kubernetes/                         # Kubernetes manifests
│   ├── namespace.yaml                  # Namespace definition
│   ├── backend-deployment.yaml        # Backend deployment
│   ├── backend-service.yaml           # Backend service
│   ├── frontend-deployment.yaml       # Frontend deployment
│   ├── frontend-service.yaml          # Frontend service
│   ├── ingress.yaml                   # ALB ingress configuration
│   └── aws-load-balancer-controller.yaml
│
├── application/                        # Application source code
│   ├── frontend/                       # Frontend application
│   │   ├── Dockerfile                  # Frontend container image
│   │   ├── index.html                  # Game HTML
│   │   ├── game.js                     # Game logic
│   │   └── nginx.conf                  # Nginx configuration
│   └── backend/                        # Backend API
│       ├── Dockerfile                  # Backend container image
│       ├── app.py                      # Flask application
│       └── requirements.txt           # Python dependencies
│
├── scripts/                            # Automation scripts
│   ├── setup-demo.sh                  # Demo environment setup
│   ├── cleanup-demo.sh                # Resource cleanup
│   ├── build-and-push.sh              # Container build/push
│   ├── deploy.sh                      # Application deployment
│   └── test-flappy-kiro-monitoring.sh # Monitoring tests
│
└── monitoring/                         # Monitoring configuration
    └── setup-monitors.sh               # Edge Delta monitor setup
```

## Key Files Explained

### Infrastructure
- **eks-kiro-demo-config.yaml**: Complete EKS cluster configuration
- **ingressclass.yaml**: AWS Load Balancer Controller ingress class
- **iam_policy.json**: IAM policies for AWS Load Balancer Controller

### Application
- **Frontend**: HTML5 game with Nginx serving static content
- **Backend**: Python Flask API with leaderboard functionality
- **Dockerfiles**: Multi-stage builds for optimized container images

### Kubernetes
- **Deployments**: Application workload definitions with health checks
- **Services**: Network access and load balancing configuration
- **Ingress**: AWS ALB integration for external access

### Monitoring
- **Edge Delta Integration**: 11 comprehensive monitors
- **OpenTelemetry**: Distributed tracing and metrics
- **Health Checks**: Application and infrastructure monitoring

### Scripts
- **Automation**: Complete deployment and cleanup automation
- **Testing**: Monitoring and functionality validation
- **DevOps**: CI/CD ready deployment scripts
