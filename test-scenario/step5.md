## Modify application_v1alpha1_myapp.yaml

This YAML file defines the structure of our custom resource. Ensure it reflects the structure and default values we want for MyApp.

```
apiVersion: application.nbfc.io/v1alpha1
kind: MyApp
metadata:
  name: myapp-sample
spec:
  size: 2
  pods:
    - name: pod2
      image: ubuntu:latest
      command: ["sleep"]
      args: ["infinity"]
    - name: pod1
      image: nginx:latest
      containerPorts:
        - name: http
          containerPort: 80
    - name: pod3
      image: debian:latest
      command: ["sleep"]
      args: ["infinity"]
```{{copy}}
