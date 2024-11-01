# Step 1: KubeBuilder Installation
To begin, we need to install KubeBuilder on our Kubernetes cluster. KubeBuilder is a powerful framework for building Kubernetes APIs and controllers. It's based on the Go programming language and provides tools to scaffold projects, generate code, and manage custom resources.Run the following commands:

```bash
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
```{{exec}}

# Create a project

First, let's create and navigate into a directory for our project. Then, we'll initialize it using KubeBuilder:

```bash
export GOPATH=$PWD
 echo $GOPATH
 mkdir $GOPATH/etherpadoperator
 cd $GOPATH/etherpadoperator
 go mod init etherpadinstance
 kubebuilder init --domain etherpadinstance.io

```{{exec}}

Next, to create a new API:

```bash
kubebuilder create api --group etherpad --version v1alpha1 --kind EtherpadInstance --image=ubuntu:latest --image-container-command="sleep,infinity" --image-container-port="22" --run-as-user="1001" --plugins="deploy-image/v1-alpha" --make=false
```{{exec}}

Install the CRDs into the cluster:

```bash
make install
```{{exec}}

For quick feedback and code-level debugging, let's run our controller:


```bash
make run
```{{exec}}

> **_NOTE:_**  This may take a few minutes 3-5 minutes, be patient.
