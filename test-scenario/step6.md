## Modify myapp_types.go

This file defines the schema and validation for our custom resource. Ensure it aligns with the desired specification and status definitions for MyApp.

```
package v1alpha1

import (
        corev1 "k8s.io/api/core/v1"
        metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// MyAppSpec defines the desired state of MyApp
type MyAppSpec struct {
        Size          int32     `json:"size,omitempty"`
        ContainerPort int32     `json:"containerPort,omitempty"`
        Pods          []PodSpec `json:"pods,omitempty"`
}

// PodSpec defines the desired state of a Pod
type PodSpec struct {
        Name           string                 `json:"name"`
        Image          string                 `json:"image"`
        Command        []string               `json:"command,omitempty"`
        Args           []string               `json:"args,omitempty"`
        ContainerPorts []corev1.ContainerPort `json:"containerPorts,omitempty"`
}

// MyAppStatus defines the observed state of MyApp
type MyAppStatus struct {
        Conditions []metav1.Condition `json:"conditions,omitempty" patchStrategy:"merge" patchMergeKey:"type" protobuf:"bytes,1,rep,name=conditions"`
        Nodes      []string           `json:"nodes,omitempty"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// MyApp is the Schema for the myapps API
type MyApp struct {
        metav1.TypeMeta   `json:",inline"`
        metav1.ObjectMeta `json:"metadata,omitempty"`

        Spec   MyAppSpec   `json:"spec,omitempty"`
        Status MyAppStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// MyAppList contains a list of MyApp
type MyAppList struct {
        metav1.TypeMeta `json:",inline"`
        metav1.ListMeta `json:"metadata,omitempty"`
        Items           []MyApp `json:"items"`
}

func init() {
        SchemeBuilder.Register(&MyApp{}, &MyAppList{})
}
```{{copy}}
