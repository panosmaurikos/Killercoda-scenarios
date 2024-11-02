Next, we modify the sample resource file ```config/samples/etherpad_v1alpha1_etherpadinstance.yaml```. This file provides an example of how to create an EtherpadInstance custom resource with specific configurations. By defining this sample, we can easily test and verify that our operator correctly handles EtherpadInstance resources.

In this file, we specify the desired settings for an EtherpadInstance, such as database connection details, storage options, and other configurations needed for the Etherpad application to run.

```
echo "
apiVersion: etherpad.etherpadinstance.io/v1alpha1
kind: EtherpadInstance
metadata:
  name: etherpadinstance-sample
spec:
  pods:
    - name: etherpad
      image: etherpad/etherpad:latest
      containerPorts:
        - containerPort: 9001
          protocol: TCP
      volumeMounts:
        - name: etherpad-storage
          mountPath: /opt/etherpad-lite/var
        - name: etherpad-settings
          mountPath: /opt/etherpad-lite/settings.json
          subPath: settings.json
      volumes:
        - name: etherpad-storage
          persistentVolumeClaim:
            claimName: etherpad-pvc
        - name: etherpad-settings
          configMap:
            name: etherpad-config
            items:
              - key: settings.json
                path: settings.json

    - name: mysql
      image: mysql:8
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: root_password
        - name: MYSQL_DATABASE
          value: etherpad_db
        - name: MYSQL_USER
          value: etherpad_user
        - name: MYSQL_PASSWORD
          value: etherpad_password
      containerPorts:
        - containerPort: 3306
          protocol: TCP
      volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-pvc
" > config/samples/etherpad_v1alpha1_etherpadinstance.yaml
```{{exec}}
