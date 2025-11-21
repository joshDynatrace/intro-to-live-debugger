#!/bin/bash

# Deploy Applications to K3s
# This script deploys both applications to K3s using pre-built images

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📥 Bugzapper will use pre-built image: jhendrick/bugzapper-game:latest"
echo "📥 TodoApp will use pre-built image: shinojosa/todoapp:1.0.1"

cd "$SCRIPT_DIR"

echo "🚀 Deploying applications to K3s..."

# Apply Kubernetes manifests
kubectl apply -f k8s/bugzapper-deployment.yaml
kubectl apply -f k8s/todoapp-deployment.yaml

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/bugzapper -n bugzapper
kubectl wait --for=condition=available --timeout=120s deployment/todoapp -n todoapp

echo ""
echo "✨ Deployment completed successfully!"
echo ""
echo "📋 Application URLs:"
echo "  - Bugzapper: http://localhost:30200"
echo "  - TodoApp:   http://localhost:30100"
echo ""
echo "🔍 Check deployment status:"
echo "  kubectl get pods -n bugzapper"
echo "  kubectl get pods -n todoapp"
echo "  kubectl get services -n bugzapper"
echo "  kubectl get services -n todoapp"
echo ""
echo "📊 View logs:"
echo "  kubectl logs -f deployment/bugzapper -n bugzapper"
echo "  kubectl logs -f deployment/todoapp -n todoapp"
