# Step 1: KubeBuilder Installation

To begin, we need to install KubeBuilder on our Kubernetes cluster. Run the following commands:

```bash
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
