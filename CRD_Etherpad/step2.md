~~~
.
|-- Dockerfile
|-- Makefile
|-- PROJECT
|-- README.md
|-- api
|   `-- v1alpha1
|       |-- etherpadinstance_types.go
|       `-- groupversion_info.go
|-- bin
|   |-- controller-gen -> /root/etherpadoperator/bin/controller-gen-v0.16.4
|   `-- controller-gen-v0.16.4
|-- cmd
|   `-- main.go
|-- config
|   |-- crd
|   |   |-- bases
|   |   |   `-- etherpad.etherpadinstance.io_etherpadinstances.yaml
|   |   |-- kustomization.yaml
|   |   `-- kustomizeconfig.yaml
|   |-- default
|   |   |-- kustomization.yaml
|   |   |-- manager_metrics_patch.yaml
|   |   `-- metrics_service.yaml
|   |-- manager
|   |   |-- kustomization.yaml
|   |   `-- manager.yaml
|   |-- network-policy
|   |   |-- allow-metrics-traffic.yaml
|   |   `-- kustomization.yaml
|   |-- prometheus
|   |   |-- kustomization.yaml
|   |   `-- monitor.yaml
|   |-- rbac
|   |   |-- etherpadinstance_editor_role.yaml
|   |   |-- etherpadinstance_viewer_role.yaml
|   |   |-- kustomization.yaml
|   |   |-- leader_election_role.yaml
|   |   |-- leader_election_role_binding.yaml
|   |   |-- metrics_auth_role.yaml
|   |   |-- metrics_auth_role_binding.yaml
|   |   |-- metrics_reader_role.yaml
|   |   |-- role.yaml
|   |   |-- role_binding.yaml
|   |   `-- service_account.yaml
|   `-- samples
|       |-- etherpad_v1alpha1_etherpadinstance.yaml
|       `-- kustomization.yaml
|-- go.mod
|-- go.sum
|-- hack
|   `-- boilerplate.go.txt
|-- internal
|   `-- controller
|       |-- etherpadinstance_controller.go
|       |-- etherpadinstance_controller_test.go
|       `-- suite_test.go
`-- test
    |-- e2e
    |   |-- e2e_suite_test.go
    |   `-- e2e_test.go
    `-- utils
        `-- utils.go
~~~
