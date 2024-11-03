# Step 6: Change the etherpadinstance_types.go file
In this step, we’ll modify etherpadinstance_types.go file, which defines the Go structs for the EtherpadInstance resource. 
This file is essential as it translates the schema in our CRD to Go code, specifying the fields that users can set in the EtherpadInstance custom resource.

``` 
tee api/v1alpha1/etherpadinstance_types.go << 'END'

package v1alpha1

import (
        corev1 "k8s.io/api/core/v1"
        metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ConfigMap defines the configuration for the Etherpad instance's ConfigMap
type ConfigMapSpec struct {
        Name  string          `json:"name"`
        Items []ConfigMapItem `json:"items,omitempty"`
}

// ConfigMapItem defines an item in the ConfigMap
type ConfigMapItem struct {
        Key  string `json:"key"`
        Path string `json:"path"`
}

// EtherpadInstanceSpec defines the desired state of EtherpadInstance
type EtherpadInstanceSpec struct {
        Size          int32          `json:"size,omitempty"`
        ContainerPort int32          `json:"containerPort,omitempty"`
        Pods          []PodSpec      `json:"pods,omitempty"`
        ConfigMap     *ConfigMapSpec `json:"configMap,omitempty"`
}

// PodSpec defines the desired state of a Pod
type PodSpec struct {
        Name           string                 `json:"name"`
        Image          string                 `json:"image"`
        Command        []string               `json:"command,omitempty"`
        Args           []string               `json:"args,omitempty"`
        ContainerPorts []corev1.ContainerPort `json:"containerPorts,omitempty"`
        Env            []corev1.EnvVar        `json:"env,omitempty"`
        VolumeMounts   []corev1.VolumeMount   `json:"volumeMounts,omitempty"`
        Volumes        []corev1.Volume        `json:"volumes,omitempty"`
}



END
```{{exec}}
