# Step 3: Setting Up the EtherpadInstance CRD Example 

To make the EtherpadInstance example we need to modify the following files in our project directory:
1) config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml
2) config/samples/etherpad_v1alpha1_etherpadinstance.yaml
3) internal/controller/etherpadinstance_controller.go
4) api/v1alpha1/etherpadinstance_types.go


First, we modify the CRD file config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml by running the following command.
The CRD file defines the schema for our EtherpadInstance resource, informing Kubernetes about the structure and constraints of this custom resource.
```
cat > config/crd/bases/etherpad.etherpadinstance.io_etherpadinstances.yaml << 'EOF' 
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: etherpadinstances.etherpad.etherpadinstance.io
spec:
  group: etherpad.etherpadinstance.io
  names:
    kind: EtherpadInstance
    listKind: EtherpadInstanceList
    plural: etherpadinstances
    singular: etherpadinstance
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        description: EtherpadInstance is the Schema for the EtherpadInstance API
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            description: EtherpadInstanceSpec defines the desired state of EtherpadInstance
            properties:
              size:
                type: integer
                format: int32
              containerPort:
                type: integer
                format: int32
              configMap:
                properties:
                  name:
                    type: string
                  items:
                    type: array
                    items:
                      properties:
                        key:
                          type: string
                        path:
                          type: string
                      required:
                      - key
                      - path
                      type: object
                required:
                - name
                type: object
              pods:
                type: array
                items:
                  properties:
                    name:
                      type: string
                    image:
                      type: string
                    command:
                      type: array
                      items:
                        type: string
                    args:
                      type: array
                      items:
                        type: string
                    containerPorts:
                      type: array
                      items:
                        properties:
                          containerPort:
                            type: integer
                            format: int32
                          protocol:
                            type: string
                        required:
                        - containerPort
                        type: object
                    env:
                      type: array
                      items:
                        properties:
                          name:
                            type: string
                          value:
                            type: string
                        required:
                        - name
                        type: object
                    volumeMounts:
                      type: array
                      items:
                        properties:
                          name:
                            type: string
                          mountPath:
                            type: string
                          subPath:
                            type: string
                        required:
                        - name
                        - mountPath
                        type: object
                    volumes:
                      type: array
                      items:
                        properties:
                          name:
                            type: string
                          persistentVolumeClaim:
                            properties:
                              claimName:
                                type: string
                            required:
                            - claimName
                            type: object
                          configMap:
                            properties:
                              name:
                                type: string
                              items:
                                type: array
                                items:
                                  properties:
                                    key:
                                      type: string
                                    path:
                                      type: string
                                  required:
                                  - key
                                  - path
                                  type: object
                            required:
                            - name
                            type: object
                        required:
                        - name
                        type: object
                  required:
                  - name
                  - image
                  type: object
            type: object
          status:
            properties:
              conditions:
                type: array
                items:
                  type: object
                  properties:
                    type:
                      type: string
                    status:
                      type: string
                    lastTransitionTime:
                      type: string
                    reason:
                      type: string
                    message:
                      type: string
              nodes:
                type: array
                items:
                  type: string
            type: object
        type: object
    served: true
    storage: true
EOF 
```{{exec}}
