# Setup Minikube Action

This GitHub Action sets up a Minikube cluster with optional Ingress and OLM (Operator Lifecycle Manager) support.

## Features

- 🚀 Sets up Minikube with configurable versions
- 🌐 Optional Ingress controller installation
- 📦 Optional OLM installation for operator management
- 🔧 Automatic port-forwarding setup
- 🌉 Background tunnel setup for LoadBalancer services
- ✅ Comprehensive verification and status reporting

## Usage

### Basic Setup

```yaml
- name: Setup Minikube
  uses: Apicurio/apicurio-github-actions/setup-minikube@main
```

### With Ingress

```yaml
- name: Setup Minikube with Ingress
  uses: Apicurio/apicurio-github-actions/setup-minikube@main
  with:
    ingress-enable: 'true'
```

### With OLM

```yaml
- name: Setup Minikube with OLM
  uses: Apicurio/apicurio-github-actions/setup-minikube@main
  with:
    olm-enable: 'true'
    olm-version: '0.32.0'
```

### Full Configuration

```yaml
- name: Setup Minikube
  uses: Apicurio/apicurio-github-actions/setup-minikube@main
  with:
    ingress-enable: 'true'
    olm-enable: 'true'
    olm-version: '0.32.0'
    minikube-version: 'v1.36.0'
    kubernetes-version: 'v1.33.3'
    driver: 'docker'
    start-args: '--force --memory=4096'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ingress-enable` | Install an Ingress controller | No | `false` |
| `olm-enable` | Install OLM | No | `false` |
| `olm-version` | OLM version to install | No | `0.32.0` |
| `minikube-version` | Minikube version to use | No | `v1.36.0` |
| `kubernetes-version` | Kubernetes version to use | No | `v1.33.3` |
| `driver` | Minikube driver to use | No | `docker` |
| `start-args` | Additional arguments to pass to minikube start | No | `--force` |

## Outputs

| Output | Description |
|--------|-------------|
| `minikube-status` | Status of the Minikube cluster |
| `kubernetes-version` | Version of Kubernetes running in Minikube |
| `cluster-ip` | IP address of the Minikube cluster |

## Example Workflow

```yaml
name: Test with Minikube
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Minikube
        id: minikube
        uses: Apicurio/apicurio-github-actions/setup-minikube@main
        with:
          ingress-enable: 'true'
          olm-enable: 'true'
      
      - name: Deploy application
        run: |
          kubectl apply -f k8s/
          kubectl wait --for=condition=ready pod -l app=myapp --timeout=300s
      
      - name: Test application
        run: |
          echo "Cluster IP: ${{ steps.minikube.outputs.cluster-ip }}"
          echo "Kubernetes version: ${{ steps.minikube.outputs.kubernetes-version }}"
          # Run your tests here
```

## What This Action Does

1. **Port-forwarding Setup**: Installs `socat` for proper port-forwarding support
2. **Minikube Installation**: Uses the `manusa/actions-setup-minikube` action to install and start Minikube
3. **Cluster Information**: Retrieves and outputs cluster status, Kubernetes version, and cluster IP
4. **Ingress Setup** (optional): Enables the Ingress addon and waits for the controller to be ready
5. **OLM Installation** (optional): Downloads and installs the specified version of OLM
6. **Tunnel Setup**: Starts a Minikube tunnel in the background for LoadBalancer service access
7. **Verification**: Verifies the setup by checking kubectl connectivity and listing system resources

## Notes

- The Minikube tunnel runs in the background for the duration of the job, enabling access to LoadBalancer services
- When Ingress is enabled, the action waits for the Ingress controller to be ready before proceeding
- When OLM is enabled, the action waits for both the OLM operator and catalog operator to be ready
- The action provides comprehensive logging with emojis for easy identification of different steps
- All timeouts are set to 300 seconds (5 minutes) to allow for slower environments

## Requirements

- Runs on Ubuntu runners (uses `apt-get` for package installation)
- Requires Docker to be available (default driver is `docker`)
- Internet access for downloading Minikube, Kubernetes, and OLM components
