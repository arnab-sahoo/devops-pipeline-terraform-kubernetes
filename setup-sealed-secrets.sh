#!/bin/bash
# setup-sealed-secrets.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Sealed Secrets Controller${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if kubeseal is installed
if ! command -v kubeseal &> /dev/null; then
    echo -e "${YELLOW}kubeseal is not installed. Installing...${NC}"
    
    # Download and install kubeseal
    KUBESEAL_VERSION="0.24.0"
    wget -q https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
    tar -xzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
    sudo mv kubeseal /usr/local/bin/
    rm kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
    
    echo -e "${GREEN}kubeseal installed successfully${NC}"
fi

# Install Sealed Secrets Controller
echo -e "${YELLOW}Installing Sealed Secrets Controller...${NC}"
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Wait for the controller to be ready
echo -e "${YELLOW}Waiting for Sealed Secrets Controller to be ready...${NC}"
kubectl wait --for=condition=ready pod -l name=sealed-secrets-controller -n kube-system --timeout=300s

echo -e "${GREEN}Sealed Secrets Controller is ready!${NC}"

# Create a sample secret and seal it
echo -e "${YELLOW}Creating example sealed secret...${NC}"

# Create namespace if it doesn't exist
kubectl create namespace sealed-secrets-example --dry-run=client -o yaml | kubectl apply -f -

# Create a regular secret
kubectl create secret generic example-secret \
  --from-literal=username=admin \
  --from-literal=password=supersecret123 \
  --namespace=sealed-secrets-example \
  --dry-run=client -o yaml > example-secret.yaml

# Seal the secret
kubeseal -f example-secret.yaml -w example-sealed-secret.yaml

echo -e "${GREEN}Example sealed secret created: example-sealed-secret.yaml${NC}"

# Apply the sealed secret
kubectl apply -f example-sealed-secret.yaml

# Verify the secret was created
echo -e "${YELLOW}Verifying sealed secret deployment...${NC}"
kubectl get sealedsecrets -n sealed-secrets-example
kubectl get secrets -n sealed-secrets-example

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}To create your own sealed secrets:${NC}"
echo "1. Create a regular secret YAML file"
echo "2. Use 'kubeseal -f secret.yaml -w sealedsecret.yaml' to seal it"
echo "3. Commit the sealed secret to your repository"
echo "4. Apply it with 'kubectl apply -f sealedsecret.yaml'"

# Clean up temporary files
rm -f example-secret.yaml

echo -e "${GREEN}Remember to delete example-secret.yaml and keep example-sealed-secret.yaml safe!${NC}"