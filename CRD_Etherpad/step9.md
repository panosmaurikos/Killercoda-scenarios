# Deploying the Controller on a Kubernetes Cluster

Once your controller is ready, you can build, package, and deploy it to any Kubernetes cluster. 
There are two primary methods for deploying your controller:

### 1) Direct Deployment with make deploy

- To build and push your controller image to the specified registry, run the following command:

~~~
make docker-build docker-push IMG=<some-registry>/<project-name>:tag
~~~

- Once the image is successfully built and pushed, deploy the controller to your Kubernetes cluster with the following command:

~~~
make deploy IMG=<some-registry>/<project-name>:tag
~~~

After deploying the controller,don’t forget to apply your Custom Resource (CR) file:

### 2) Deployment Using an Installer YAML

For a more reusable approach, you can create an installation YAML file that packages all necessary controller resources, including Custom Resource Definitions (CRDs), the Controller, and any required Custom Resources. To create the install.yaml, follow these steps:

- Build and push the controller image:
~~~
make docker-build docker-push IMG=<some-registry>/<project-name>:tag
~~~
- Generate the installer YAML file:
~~~
make build-installer IMG=<some-registry>/<project-name>:tag
~~~
- Apply the Installer YAML to the Cluster
~~~
kubectl apply -f dist/install.yaml
~~~
Finally, apply your Custom Resource file.
