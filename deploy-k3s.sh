#!/bin/bash

# K3s Quick Deploy Script
# This script installs K3s on your system and sets up kubectl access

set -e

echo "🚀 Starting K3s installation..."

# Check if running with sufficient privileges
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  This script requires sudo privileges to install K3s"
    echo "Re-running with sudo..."
    sudo bash "$0" "$@"
    exit $?
fi

# Install K3s
echo "📦 Installing K3s..."
curl -sfL https://get.k3s.io | sh -

# Wait for K3s to be ready
echo "⏳ Waiting for K3s to be ready..."
sleep 10

# Check K3s status
echo "✅ Checking K3s service status..."
systemctl status k3s --no-pager || true

# Set up kubectl access for the current user
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "🔧 Setting up kubectl access for user: $ACTUAL_USER"

# Create .kube directory if it doesn't exist
if [ ! -d "$ACTUAL_HOME/.kube" ]; then
    mkdir -p "$ACTUAL_HOME/.kube"
    chown $ACTUAL_USER:$(id -gn $ACTUAL_USER) "$ACTUAL_HOME/.kube"
fi

# Copy kubeconfig
cp /etc/rancher/k3s/k3s.yaml "$ACTUAL_HOME/.kube/config"
chown $ACTUAL_USER:$(id -gn $ACTUAL_USER) "$ACTUAL_HOME/.kube/config"
chmod 600 "$ACTUAL_HOME/.kube/config"

echo ""
echo "✨ K3s installation completed successfully!"
echo ""
echo "📋 Useful information:"
echo "  - K3s service: systemctl status k3s"
echo "  - Kubeconfig: $ACTUAL_HOME/.kube/config"
echo "  - Uninstall: /usr/local/bin/k3s-uninstall.sh"
echo ""
echo "🔍 Verifying cluster access..."

# Switch to actual user for kubectl commands
su - $ACTUAL_USER -c "kubectl get nodes"

echo ""
echo "🎉 K3s is ready! You can now deploy your applications."
