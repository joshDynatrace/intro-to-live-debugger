# Kubernetes Deployment Guide

This directory contains Kubernetes manifests and deployment scripts for running the bugzapper and todoapp applications on K3s.

## Quick Start

### 1. Install K3s

Run the K3s installation script:

```bash
./deploy-k3s.sh
```

This will:
- Install K3s lightweight Kubernetes
- Configure kubectl access
- Set up the kubeconfig file

### 2. Deploy Applications

Build and deploy both applications:

```bash
./deploy-apps.sh
```

This will:
- Build Docker images for bugzapper and todoapp
- Import images to K3s
- Deploy both applications with Kubernetes manifests
- Expose services via NodePort

### 3. Access Applications

Once deployed, access the applications at:

- **Bugzapper**: http://localhost:30001
- **TodoApp**: http://localhost:30002

## Manual Deployment

If you prefer to deploy manually:

### Build Docker Images

```bash
# Build bugzapper
cd bugzapper
docker build -t bugzapper:latest .

# Build todoapp
cd todoapp
docker build -t todoapp:latest .
```

### Import Images to K3s

```bash
# Import bugzapper
docker save bugzapper:latest | sudo k3s ctr images import -

# Import todoapp
docker save todoapp:latest | sudo k3s ctr images import -
```

### Deploy to Kubernetes

```bash
# Deploy bugzapper
kubectl apply -f k8s/bugzapper-deployment.yaml

# Deploy todoapp
kubectl apply -f k8s/todoapp-deployment.yaml
```

## Kubernetes Resources

### Bugzapper
- **Deployment**: 1 replica, port 3000
- **Service**: NodePort 30001
- **Image**: bugzapper:latest

### TodoApp
- **Deployment**: 1 replica, port 8080
- **Service**: NodePort 30002
- **Image**: todoapp:latest

## Useful Commands

### Check Deployment Status
```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

### View Logs
```bash
# Bugzapper logs
kubectl logs -f deployment/bugzapper

# TodoApp logs
kubectl logs -f deployment/todoapp
```

### Describe Resources
```bash
kubectl describe deployment bugzapper
kubectl describe service bugzapper
kubectl describe pod <pod-name>
```

### Update Deployments
```bash
# After rebuilding images, restart deployments
kubectl rollout restart deployment/bugzapper
kubectl rollout restart deployment/todoapp
```

### Delete Deployments
```bash
kubectl delete -f k8s/bugzapper-deployment.yaml
kubectl delete -f k8s/todoapp-deployment.yaml
```

## Uninstall K3s

To completely remove K3s:

```bash
/usr/local/bin/k3s-uninstall.sh
```

## Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl get pods

# View pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### Image pull issues
K3s uses containerd, so Docker images need to be imported:
```bash
docker save <image-name>:latest | sudo k3s ctr images import -
```

### Port conflicts
If NodePorts 30001 or 30002 are in use, edit the service definitions in the YAML files to use different ports.

## Architecture

```
┌─────────────────────────────────────────┐
│            K3s Cluster                   │
│                                          │
│  ┌────────────────┐  ┌────────────────┐ │
│  │   Bugzapper    │  │    TodoApp     │ │
│  │                │  │                │ │
│  │  Pod: 3000     │  │  Pod: 8080     │ │
│  │  Service:      │  │  Service:      │ │
│  │  NodePort      │  │  NodePort      │ │
│  │  30001         │  │  30002         │ │
│  └────────────────┘  └────────────────┘ │
│                                          │
└─────────────────────────────────────────┘
         │                    │
         ▼                    ▼
   localhost:30001      localhost:30002
```
