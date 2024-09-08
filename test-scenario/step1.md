# Step 1: KubeBuilder Installation

To begin, we need to install KubeBuilder on our Kubernetes cluster. Run the following commands:

```
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
```{{exec}}

Create a project

First, let's create and navigate into a directory for our project. Then, we'll initialize it using KubeBuilder:
```
export GOPATH=$PWD
echo $GOPATH
mkdir $GOPATH/operator
cd $GOPATH/operator
go mod init nbfc.io
kubebuilder init --domain=nbfc.io
```{{exec}}
Next, to create a new API.
```
kubebuilder create api --group application --version v1alpha1 --kind MyApp --image=ubuntu:latest --image-container-command="sleep,infinity" --image-container-port="22" --run-as-user="1001" --plugins="deploy-image/v1-alpha" --make=false
```{{exec}}

Install the CRDs into the cluster:
```
make install
```{{exec}}
For quick feedback and code-level debugging, let's run our controller:
~~~
make run
~~~{{exec}}
