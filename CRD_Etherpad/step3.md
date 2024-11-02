# Operator 

### Now, let’s look at how the operator actually works.


The Custom Resource Definition (CRD) adds a new resource type to the Kubernetes API, such as EtherpadInstance. This allows Kubernetes to recognize and accept resources of this type, with fields for user configuration, like database details and replica count.

As an example, we'll look at the EtherpadInstance resource, which includes settings like the MySQL connection details, storage configuration, and the number of replicas. When a user creates a custom resource (CR) based on this CRD, they specify their desired setup for an Etherpad instance using these fields.

The operator continuously monitors for changes in these custom resources and ensures the Kubernetes environment matches the desired state specified in the CR. This is managed by the controller, which runs a "reconciliation loop."

In each loop, the controller checks if the current state of the resources matches the desired state. If there’s any difference, it takes action to align them. For example, if an EtherpadInstance specifies a MySQL backend, the controller ensures both an Etherpad Pod and a MySQL Pod are running, and it creates a Service to enable communication between them.

This approach allows users to declaratively manage complex applications by simply defining the desired state, while the operator handles the details of keeping the environment in sync.

![image](https://github.com/user-attachments/assets/da2150cc-6f1e-4e44-9b7e-9c17e7cb9d2b)
