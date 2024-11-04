## Deploying the Custom Resource and verify the Deployment 
After the changes,apply the crd file.
~~~
kubectl apply -f config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml
~~~
Check if the controller is working.
~~~
make run
~~~

Deploy the CR file, to Kubernetes cluster:

~~~
kubectl apply -f config/samples/etherpad_v1alpha1_etherpadinstance.yaml
~~~ 

Create and apply config file.

``` 
tee etherpad-config.yaml << 'END'

apiVersion: v1
kind: ConfigMap
metadata:
  name: etherpad-config
data:
  settings.json: |
    {
      "title": "Etherpad",
      "favicon": "favicon.ico",
      "skinName": "colibris",
      "ip": "0.0.0.0",
      "port": 9001,
      "dbType": "mysql",
      "dbSettings": {
        "host": "mysql-service",
        "user": "etherpad_user",
        "password": "etherpad_password",
        "database": "etherpad_db",
        "charset": "utf8mb4"
      },
      "defaultPadText": "Welcome to Etherpad!\n",
      "padOptions": {
        "noColors": false,
        "showControls": true,
        "showChat": true,
        "showLineNumbers": true,
        "useMonospaceFont": false,
        "userName": false,
        "userColor": false,
        "rtl": false,
        "alwaysShowChat": false,
        "chatAndUsers": false,
        "lang": "en-gb"
      },
      "users": {
        "admin": {
          "password": "admin-password",
          "is_admin": true
        },
        "user1": {
          "password": "user1-password",
          "is_admin": false
        },
        "user2": {
          "password": "user2-password",
          "is_admin": false
        }
      },
      "requireSession": true,
      "requireAuthentication": true,
      "editOnly": false
    }

END
```{{exec}}

~~~
kubectl apply -f etherpad-config.yaml
~~~

Then we check if the pods are running.

~~~
kubectl get pods -A 
kubectl describe pods <podsname>
kubectl logs etherpad
~~~

