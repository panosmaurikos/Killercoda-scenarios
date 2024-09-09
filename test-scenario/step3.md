In this step, we'll modify the myapp_controller.go file to implement the reconciliation logic that manages the lifecycle of MyApp resources. This is where we'll define how our custom resource should behave.

~~~
package controller

import (
        "context"
        "fmt"

        corev1 "k8s.io/api/core/v1"
        apierrors "k8s.io/apimachinery/pkg/api/errors"
        "k8s.io/apimachinery/pkg/api/meta"
        metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
        "k8s.io/apimachinery/pkg/runtime"
        "k8s.io/apimachinery/pkg/types"
        "k8s.io/apimachinery/pkg/util/intstr"
        "k8s.io/client-go/tools/record"
        applicationv1alpha1 "nbfc.io/api/v1alpha1"
        ctrl "sigs.k8s.io/controller-runtime"
        "sigs.k8s.io/controller-runtime/pkg/client"
        "sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
        "sigs.k8s.io/controller-runtime/pkg/log"
)

const myappFinalizer = "application.nbfc.io/finalizer"

// Definitions to manage status conditions
const (
        typeAvailableMyApp = "Available"
        typeDegradedMyApp  = "Degraded"
)

// MyAppReconciler reconciles a MyApp object
type MyAppReconciler struct {
        client.Client
        Scheme   *runtime.Scheme
        Recorder record.EventRecorder
}

//+kubebuilder:rbac:groups=application.nbfc.io,resources=myapps,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=application.nbfc.io,resources=myapps/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=application.nbfc.io,resources=myapps/finalizers,verbs=update
//+kubebuilder:rbac:groups=core,resources=events,verbs=create;patch
//+kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=core,resources=services,verbs=get;list;watch;create;update;patch;delete

func (r *MyAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
        log := log.FromContext(ctx)

        myapp := &applicationv1alpha1.MyApp{}
        err := r.Get(ctx, req.NamespacedName, myapp)
        if err != nil {
                if apierrors.IsNotFound(err) {
                        log.Info("myapp resource not found. Ignoring since object must be deleted")
                        return ctrl.Result{}, nil
                }
                log.Error(err, "Failed to get myapp")
                return ctrl.Result{}, err
        }

        if myapp.Status.Conditions == nil || len(myapp.Status.Conditions) == 0 {
                meta.SetStatusCondition(&myapp.Status.Conditions, metav1.Condition{Type: typeAvailableMyApp, Status: metav1.ConditionUnknown, Reason: "Reconciling", Message: "Starting reconciliation"})
                if err = r.Status().Update(ctx, myapp); err != nil {
                        log.Error(err, "Failed to update MyApp status")
                        return ctrl.Result{}, err
                }

                if err := r.Get(ctx, req.NamespacedName, myapp); err != nil {
                        log.Error(err, "Failed to re-fetch myapp")
                        return ctrl.Result{}, err
                }
        }

        if !controllerutil.ContainsFinalizer(myapp, myappFinalizer) {
                log.Info("Adding Finalizer for MyApp")
                if ok := controllerutil.AddFinalizer(myapp, myappFinalizer); !ok {
                        log.Error(err, "Failed to add finalizer into the custom resource")
                        return ctrl.Result{Requeue: true}, nil
                }

                if err = r.Update(ctx, myapp); err != nil {
                        log.Error(err, "Failed to update custom resource to add finalizer")
                        return ctrl.Result{}, err
                }
        }

        isMyAppMarkedToBeDeleted := myapp.GetDeletionTimestamp() != nil
        if isMyAppMarkedToBeDeleted {
                if controllerutil.ContainsFinalizer(myapp, myappFinalizer) {
                        log.Info("Performing Finalizer Operations for MyApp before delete CR")

                        meta.SetStatusCondition(&myapp.Status.Conditions, metav1.Condition{Type: typeDegradedMyApp,
                                Status: metav1.ConditionUnknown, Reason: "Finalizing",
                                Message: fmt.Sprintf("Performing finalizer operations for the custom resource: %s ", myapp.Name)})

                        if err := r.Status().Update(ctx, myapp); err != nil {
                                log.Error(err, "Failed to update MyApp status")
                                return ctrl.Result{}, err
                        }

                        r.doFinalizerOperationsForMyApp(myapp)

                        if err := r.Get(ctx, req.NamespacedName, myapp); err != nil {
                                log.Error(err, "Failed to re-fetch myapp")
                                return ctrl.Result{}, err
                        }

                        meta.SetStatusCondition(&myapp.Status.Conditions, metav1.Condition{Type: typeDegradedMyApp,
                                Status: metav1.ConditionTrue, Reason: "Finalizing",
                                Message: fmt.Sprintf("Finalizer operations for custom resource %s name were successfully accomplished", myapp.Name)})

                        if err := r.Status().Update(ctx, myapp); err != nil {
                                log.Error(err, "Failed to update MyApp status")
                                return ctrl.Result{}, err
                        }

                        log.Info("Removing Finalizer for MyApp after successfully perform the operations")
                        if ok := controllerutil.RemoveFinalizer(myapp, myappFinalizer); !ok {
                                log.Error(err, "Failed to remove finalizer for MyApp")
                                return ctrl.Result{Requeue: true}, nil
                        }

                        if err := r.Update(ctx, myapp); err != nil {
                                log.Error(err, "Failed to remove finalizer for MyApp")
                                return ctrl.Result{}, err
                        }
                }
                return ctrl.Result{}, nil
        }

        podList := &corev1.PodList{}
        listOpts := []client.ListOption{
                client.InNamespace(myapp.Namespace),
                client.MatchingLabels(labelsForMyApp(myapp.Name)),
        }
        if err = r.List(ctx, podList, listOpts...); err != nil {
                log.Error(err, "Failed to list pods", "MyApp.Namespace", myapp.Namespace, "MyApp.Name", myapp.Name)
                return ctrl.Result{}, err
        }
        podNames := getPodNames(podList.Items)

        if !equalSlices(podNames, myapp.Status.Nodes) {
                myapp.Status.Nodes = podNames
                if err := r.Status().Update(ctx, myapp); err != nil {
                        log.Error(err, "Failed to update MyApp status")
                        return ctrl.Result{}, err
                }
        }

        for _, podSpec := range myapp.Spec.Pods {
                foundPod := &corev1.Pod{}
                err = r.Get(ctx, types.NamespacedName{Name: podSpec.Name, Namespace: myapp.Namespace}, foundPod)
                if err != nil && apierrors.IsNotFound(err) {
                        pod := &corev1.Pod{
                                ObjectMeta: metav1.ObjectMeta{
                                        Name:      podSpec.Name,
                                        Namespace: myapp.Namespace,
                                        Labels:    labelsForMyApp(myapp.Name),
                                },
                                Spec: corev1.PodSpec{
                                        Containers: []corev1.Container{{
                                                Name:    podSpec.Name,
                                                Image:   podSpec.Image,
                                                Command: podSpec.Command,
                                                Args:    podSpec.Args,
                                                Ports:   podSpec.ContainerPorts,
                                        }},
                                },
                        }

                        if err := ctrl.SetControllerReference(myapp, pod, r.Scheme); err != nil {
                                log.Error(err, "Failed to set controller reference", "Pod.Namespace", pod.Namespace, "Pod.Name", pod.Name)
                                return ctrl.Result{}, err
                        }

                        log.Info("Creating a new Pod", "Pod.Namespace", pod.Namespace, "Pod.Name", pod.Name)
                        if err = r.Create(ctx, pod); err != nil {
                                log.Error(err, "Failed to create new Pod", "Pod.Namespace", pod.Namespace, "Pod.Name", pod.Name)
                                return ctrl.Result{}, err
                        }

                        if err := r.Get(ctx, req.NamespacedName, myapp); err != nil {
                                log.Error(err, "Failed to re-fetch myapp")
                                return ctrl.Result{}, err
                        }

                        meta.SetStatusCondition(&myapp.Status.Conditions, metav1.Condition{Type: typeAvailableMyApp,
                                Status: metav1.ConditionTrue, Reason: "Reconciling",
                                Message: fmt.Sprintf("Pod %s for custom resource %s created successfully", pod.Name, myapp.Name)})

                        if err := r.Status().Update(ctx, myapp); err != nil {
                                log.Error(err, "Failed to update MyApp status")
                                return ctrl.Result{}, err
                        }

                        // Check if the pod exposes any ports and create Services
                        for _, containerPort := range podSpec.ContainerPorts {
                                serviceName := fmt.Sprintf("%s-service", podSpec.Name) // Set a fixed name for the Service
                                service := &corev1.Service{
                                        ObjectMeta: metav1.ObjectMeta{
                                                Name:      serviceName,
                                                Namespace: myapp.Namespace,
                                                Labels:    labelsForMyApp(myapp.Name),
                                        },
                                        Spec: corev1.ServiceSpec{
                                                Selector: labelsForMyApp(myapp.Name),
                                                Ports: []corev1.ServicePort{{
                                                        Name:       containerPort.Name,
                                                        Port:       containerPort.ContainerPort,
                                                        TargetPort: intstr.FromInt(int(containerPort.ContainerPort)),
                                                }},
                                        },
                                }

                                if err := ctrl.SetControllerReference(myapp, service, r.Scheme); err != nil {
                                        log.Error(err, "Failed to set controller reference", "Service.Namespace", service.Namespace, "Service.Name", service.Name)
                                        return ctrl.Result{}, err
                                }

                                log.Info("Creating a new Service", "Service.Namespace", service.Namespace, "Service.Name", service.Name)
                                if err = r.Create(ctx, service); err != nil {
                                        log.Error(err, "Failed to create new Service", "Service.Namespace", service.Namespace, "Service.Name", service.Name)
                                        return ctrl.Result{}, err
                                }
                        }
                } else if err != nil {
                        log.Error(err, "Failed to get Pod")
                        return ctrl.Result{}, err
                }
        }

        return ctrl.Result{}, nil
}

func (r *MyAppReconciler) doFinalizerOperationsForMyApp(cr *applicationv1alpha1.MyApp) {
        // Add the cleanup steps that the finalizer should perform here
        log := log.FromContext(context.Background())
        log.Info("Successfully finalized custom resource")
}

func (r *MyAppReconciler) SetupWithManager(mgr ctrl.Manager) error {
        return ctrl.NewControllerManagedBy(mgr).
                For(&applicationv1alpha1.MyApp{}).
                Owns(&corev1.Pod{}).
                Owns(&corev1.Service{}). // Ensure the controller watches Services
                Complete(r)
}

func labelsForMyApp(name string) map[string]string {
        return map[string]string{"app": "myapp", "myapp_cr": name}
}

func getPodNames(pods []corev1.Pod) []string {
        var podNames []string
        for _, pod := range pods {
                podNames = append(podNames, pod.Name)
        }
        return podNames
}

func equalSlices(a, b []string) bool {
        if len(a) != len(b) {
                return false
        }
        for i := range a {
                if a[i] != b[i] {
                        return false
                }
        }
        return true
}
~~~
