## Deploying the Custom Resource and verify the Deployment 
After the changes, make sure we run the make command to update the generate files and apply the changes.
~~~
make run
~~~
Deploy the application_v1alpha1_myapp.yaml file and CRD to our Kubernetes cluster:
~~~
kubectl apply -f application_v1alpha1_myapp.yaml

kubectl apply -f 
~~~

Then we check if the deployments are running.

~~~
kubectl get pods -A 
~~~
