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

Possible output:
~~~
kubectl get pods 
NAME       READY   STATUS    RESTARTS   AGE
etherpad   1/1     Running   0          6m
mysql      1/1     Running   0          6m
controlplane $ kubectl logs etherpad 

> etherpad@2.2.6 prod /opt/etherpad-lite
> pnpm --filter ep_etherpad-lite run prod


> ep_etherpad-lite@2.2.6 prod /opt/etherpad-lite/src
> cross-env NODE_ENV=production node --require tsx/cjs node/server.ts

[2024-11-04T12:21:45.012] [INFO] settings - All relative paths will be interpreted relative to the identified Etherpad base dir: /opt/etherpad-lite
[2024-11-04T12:21:45.017] [INFO] settings - settings loaded from: /opt/etherpad-lite/settings.json
[2024-11-04T12:21:45.019] [INFO] settings - No credentials file found in /opt/etherpad-lite/credentials.json. Ignoring.
[2024-11-04T12:21:45.020] [WARN] settings - loglevel: INFO
[2024-11-04T12:21:45.021] [WARN] settings - logLayoutType: colored
[2024-11-04T12:21:45.021] [INFO] settings - Using skin "colibris" in dir: /opt/etherpad-lite/src/static/skins/colibris
[2024-11-04T12:21:45.022] [INFO] settings - Random string used for versioning assets: 981553d5
[2024-11-04T12:21:46.689] [INFO] server - Starting Etherpad...
[2024-11-04T12:21:46.881] [INFO] plugins - pnpm --version: 9.0.4
[2024-11-04T12:21:47.012] [INFO] plugins - check installed plugins for migration
[2024-11-04T12:21:47.013] [INFO] plugins - start migration of plugins in node_modules
[2024-11-04T12:21:48.098] [INFO] plugins - Loading plugin ep_etherpad-lite...
[2024-11-04T12:21:48.099] [INFO] plugins - Loaded 1 plugins
[2024-11-04T12:21:50.146] [WARN] settings - oidc-provider WARNING: Unsupported runtime. Use Node.js v18.x LTS, or a later LTS release.
[2024-11-04T12:21:51.908] [INFO] server - Installed plugins: 
[2024-11-04T12:21:51.911] [INFO] settings - Report bugs at https://github.com/ether/etherpad-lite/issues
[2024-11-04T12:21:51.912] [INFO] settings - Your Etherpad version is 2.2.6 (0c68ddc)
[2024-11-04T12:21:54.832] [INFO] http - HTTP server listening for connections
[2024-11-04T12:21:54.833] [INFO] settings - You can access your Etherpad instance at http://0.0.0.0:9001/
[2024-11-04T12:21:54.833] [INFO] settings - The plugin admin page is at http://0.0.0.0:9001/admin/plugins
[2024-11-04T12:21:54.833] [INFO] server - Etherpad is running

~~~

