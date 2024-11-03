## Deploying the Custom Resource and verify the Deployment 
After the changes, make sure we run the make command to update the generate files and apply the changes.
~~~
make run
~~~
Deploy the CR file , the CRD and configmap file to Kubernetes cluster:
~~~
kubectl apply -f config/samples/etherpad_v1alpha1_etherpadinstance.yaml

kubectl apply -f config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml
~~~

```
echo "

 ```{{exec}}
```

Then we check if the pods are running.

~~~
kubectl get pods -A 
kubectl describe pods <podsname>
kubectl logs etherpad
~~~

