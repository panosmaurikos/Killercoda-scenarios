# Step 6: Change the etherpadinstance_types.go file
In this step, we’ll modify etherpadinstance_types.go file, which defines the Go structs for the EtherpadInstance resource. This file is essential as it translates the schema in our CRD to Go code, specifying the fields that users can set in the EtherpadInstance custom resource.






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
      "port":

END
```{{exec}}



