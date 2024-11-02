# Step 3: Setting Up the EtherpadInstance CRD Example 

To make the EtherpadInstance example we need to modify the following files in our project directory:
1) config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml
2) config/samples/etherpad_v1alpha1_etherpadinstance.yaml
3) internal/controller/etherpadinstance_controller.go
4) api/v1alpha1/etherpadinstance_types.go

First we make crd file:
```
echo "
apiVersion: application.nbfc.io/v1alpha1
kind: MyApp
metadata:
  name: myapp-sample
spec:
  size: 2
  pods:
    - name: pod2
      image: ubuntu:latest
      command: [\"sleep\"]
      args: [\"infinity\"]
    - name: pod1
      image: nginx:latest
      containerPorts:
        - name: http
          containerPort: 80
    - name: pod3
      image: debian:latest
      command: [\"sleep\"]
      args: [\"infinity\"]
" > myapp_sample.yaml
```
