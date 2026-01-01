# Kubernetes Deployment Guide

Deploy the Home Manager development environment to a Talos Kubernetes cluster with SSH access via Tailscale.

## Prerequisites

1. **Talos Kubernetes Cluster**: Running and accessible via `kubectl`
2. **Tailscale Operator**: Already installed on the cluster
3. **Container Registry Access**: GitHub Container Registry (ghcr.io) authentication
4. **Environment Variables**: Prepared `.env` file with required variables

## Deployment Steps

### 1. Build and Push Container Image

```bash
# Build the Docker image
docker build -t ghcr.io/<your-github-username>/home-manager-dev:v1.0 .

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u <your-github-username> --password-stdin

# Push the image
docker push ghcr.io/<your-github-username>/home-manager-dev:v1.0
```

### 2. Update StatefulSet Image

Edit `statefulset.yaml` and replace `<username>` with your GitHub username:

```yaml
image: ghcr.io/<your-github-username>/home-manager-dev:v1.0
```

### 3. Create Environment Secret

**Option A: From file**
```bash
kubectl create secret generic dev-env-secret \
  --namespace=dev-environment \
  --from-file=.env=../.env \
  --dry-run=client -o yaml | kubectl apply -f -
```

**Option B: Edit secret.yaml directly**
Edit `secret.yaml` and add your environment variables, then:
```bash
kubectl apply -f secret.yaml
```

### 4. Deploy to Kubernetes

Apply the manifests in order:

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Create secret (if not done in step 3)
kubectl apply -f secret.yaml

# Deploy the StatefulSet
kubectl apply -f statefulset.yaml

# Create services
kubectl apply -f service.yaml
kubectl apply -f tailscale-service.yaml
```

**Or apply all at once:**
```bash
kubectl apply -f .
```

### 5. Monitor Deployment

```bash
# Watch pod status
kubectl get pods -n dev-environment -w

# View initialization logs (5-10 minutes on first boot)
kubectl logs -n dev-environment home-manager-dev-0 -f

# Check services
kubectl get svc -n dev-environment
```

### 6. Get Tailscale Hostname

```bash
# Check the LoadBalancer service for Tailscale hostname
kubectl get svc home-manager-dev-tailscale -n dev-environment

# Or check Tailscale admin console for the new device
# It should appear as: home-manager-dev
```

### 7. SSH Access

Once the pod is ready and Tailscale has provisioned:

```bash
# SSH to the container (password: dev)
ssh jack@home-manager-dev.<your-tailnet>.ts.net
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod events
kubectl describe pod home-manager-dev-0 -n dev-environment

# Check logs
kubectl logs home-manager-dev-0 -n dev-environment
```

### Tailscale Not Exposing Service

```bash
# Check Tailscale operator logs
kubectl logs -n tailscale -l app=operator

# Verify LoadBalancer service
kubectl describe svc home-manager-dev-tailscale -n dev-environment
```

### Storage Issues

```bash
# Check PVC status
kubectl get pvc -n dev-environment

# Check StorageClass
kubectl get storageclass
```

### SSH Connection Refused

```bash
# Test from within cluster first
kubectl exec -n dev-environment home-manager-dev-0 -- ss -tlnp | grep 22

# Check if SSH is running
kubectl exec -n dev-environment home-manager-dev-0 -- ps aux | grep sshd
```

## Updating the Environment

### Rebuild Home Manager Config

```bash
# SSH into the container
ssh jack@home-manager-dev.<your-tailnet>.ts.net

# Rebuild home-manager
home-manager switch --flake ~/.config/home-manager#jack
```

### Update Container Image

```bash
# Build and push new version
docker build -t ghcr.io/<username>/home-manager-dev:v1.1 .
docker push ghcr.io/<username>/home-manager-dev:v1.1

# Update StatefulSet
kubectl set image statefulset/home-manager-dev \
  dev-env=ghcr.io/<username>/home-manager-dev:v1.1 \
  -n dev-environment

# Or edit the StatefulSet directly
kubectl edit statefulset home-manager-dev -n dev-environment
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f .

# Or delete namespace (removes everything)
kubectl delete namespace dev-environment
```

## Notes

- **First Boot**: Takes 5-10 minutes while Nix installs packages and Home Manager initializes
- **Subsequent Boots**: Fast, state is preserved in the PVC
- **Password**: Default SSH password is `dev` (set in Dockerfile)
- **Persistent Data**: All data in `/home/jack` persists across pod restarts
- **Resources**: Container requests 2Gi RAM / 1 CPU, limits at 4Gi RAM / 2 CPU
