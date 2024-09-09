## Modify myapp_controller_test.go
Testing is crucial to ensure our controller behaves as expected. In this step, we modify myapp_controller_test.go to add test cases for the reconciliation logic.

```
package controller

import (
       "context"
       "fmt"
       "os"
       "time"

       //nolint:golint
       . "github.com/onsi/ginkgo/v2"
       . "github.com/onsi/gomega"
       appsv1 "k8s.io/api/apps/v1"
       corev1 "k8s.io/api/core/v1"
       "k8s.io/apimachinery/pkg/api/errors"
       metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
       "k8s.io/apimachinery/pkg/types"
       "sigs.k8s.io/controller-runtime/pkg/reconcile"

       applicationv1alpha1 "nbfc.io/api/v1alpha1"
)

var _ = Describe("MyApp controller", func() {
       Context("MyApp controller test", func() {

               const MyAppName = "test-myapp"

               ctx := context.Background()

               namespace := &corev1.Namespace{
                       ObjectMeta: metav1.ObjectMeta{
                               Name:      MyAppName,
                               Namespace: MyAppName,
                       },
               }

               typeNamespaceName := types.NamespacedName{
                       Name:      MyAppName,
                       Namespace: MyAppName,
               }
               myapp := &applicationv1alpha1.MyApp{}

               BeforeEach(func() {
                       By("Creating the Namespace to perform the tests")
                       err := k8sClient.Create(ctx, namespace)
                       Expect(err).To(Not(HaveOccurred()))

                       By("Setting the Image ENV VAR which stores the Operand image")
                       err = os.Setenv("MYAPP_IMAGE", "example.com/image:test")
                       Expect(err).To(Not(HaveOccurred()))

                       By("creating the custom resource for the Kind MyApp")
                       err = k8sClient.Get(ctx, typeNamespaceName, myapp)
                       if err != nil && errors.IsNotFound(err) {
                               // Let's mock our custom resource at the same way that we would
                               // apply on the cluster the manifest under config/samples
                               myapp := &applicationv1alpha1.MyApp{
                                       ObjectMeta: metav1.ObjectMeta{
                                               Name:      MyAppName,
                                               Namespace: namespace.Name,
                                       },
                                       Spec: applicationv1alpha1.MyAppSpec{
                                               Size:          1,
                                               ContainerPort: 22,
                                       },
                               }

                               err = k8sClient.Create(ctx, myapp)
                               Expect(err).To(Not(HaveOccurred()))
                       }
               })

               AfterEach(func() {
                       By("removing the custom resource for the Kind MyApp")
                       found := &applicationv1alpha1.MyApp{}
                       err := k8sClient.Get(ctx, typeNamespaceName, found)
                       Expect(err).To(Not(HaveOccurred()))

                       Eventually(func() error {
                               return k8sClient.Delete(context.TODO(), found)
                       }, 2*time.Minute, time.Second).Should(Succeed())

                       // TODO(user): Attention if you improve this code by adding other context test you MUST
                       // be aware of the current delete namespace limitations.
                       // More info: https://book.kubebuilder.io/reference/envtest.html#testing-considerations
                       By("Deleting the Namespace to perform the tests")
                       _ = k8sClient.Delete(ctx, namespace)

                       By("Removing the Image ENV VAR which stores the Operand image")
                       _ = os.Unsetenv("MYAPP_IMAGE")
               })

               It("should successfully reconcile a custom resource for MyApp", func() {
                       By("Checking if the custom resource was successfully created")
                       Eventually(func() error {
                               found := &applicationv1alpha1.MyApp{}
                               return k8sClient.Get(ctx, typeNamespaceName, found)
                       }, time.Minute, time.Second).Should(Succeed())

                       By("Reconciling the custom resource created")
                       myappReconciler := &MyAppReconciler{
                               Client: k8sClient,
                               Scheme: k8sClient.Scheme(),
                       }

                       _, err := myappReconciler.Reconcile(ctx, reconcile.Request{
                               NamespacedName: typeNamespaceName,
                       })
                       Expect(err).To(Not(HaveOccurred()))

                       By("Checking if Deployment was successfully created in the reconciliation")
                       Eventually(func() error {
                               found := &appsv1.Deployment{}
                               return k8sClient.Get(ctx, typeNamespaceName, found)
                       }, time.Minute, time.Second).Should(Succeed())

                       By("Checking the latest Status Condition added to the MyApp instance")
                       Eventually(func() error {
                               if myapp.Status.Conditions != nil &&
                                       len(myapp.Status.Conditions) != 0 {
                                       latestStatusCondition := myapp.Status.Conditions[len(myapp.Status.Conditions)-1]
                                       expectedLatestStatusCondition := metav1.Condition{
                                               Type:   typeAvailableMyApp,
                                               Status: metav1.ConditionTrue,
                                               Reason: "Reconciling",
                                               Message: fmt.Sprintf(
                                                       "Deployment for custom resource (%s) with %d replicas created successfully",
                                                       myapp.Name,
                                                       myapp.Spec.Size),
                                       }
                                       if latestStatusCondition != expectedLatestStatusCondition {
                                               return fmt.Errorf("The latest status condition added to the MyApp instance is not as expected")
                                       }
                               }
                               return nil
                       }, time.Minute, time.Second).Should(Succeed())
               })
       })
})

```{{copy}}
The test cases simulate different scenarios and check whether the controller reacts appropriately, such as creating or updating resources based on the state of the cluster.

