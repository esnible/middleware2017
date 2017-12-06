# Exercise 2 - Deploying a microservice application to Kubernetes

### Deploy the Bookinfo service WITHOUT Istio

From the Docker instance we launched in [Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Container Service](../exercise-1/README.md):

```
cd /tmp/istio-0.2.12/samples/bookinfo/kube/
kubectl apply -f bookinfo.yaml
```

Verify that the pods were created. Repeat until the pods are _Running_.  (It may take a few minutes.)

```
kubectl get pods

NAME                             READY     STATUS    RESTARTS   AGE
details-v1-2124085770-hvk4h      1/1       Running   0          12s
productpage-v1-150936620-xv1j3   1/1       Running   0          11s
ratings-v1-2898728890-g4ctp      1/1       Running   0          12s
reviews-v1-459371037-6dr91       1/1       Running   0          12s
reviews-v2-2051293497-556kb      1/1       Running   0          12s
reviews-v3-418971697-zmcfp       1/1       Running   0          12s
```

Kubernetes will restart pods that crash.  Even if you explicitly _delete_ pods, it will recreate them
until the amount requested by the deployment (in this case 1 pod) exists.

Note the name of pod in your results.  Delete it:

```
kubectl delete pod ratings-v1-...
```

Kubernetes will automatically restart this pod for you. Verify that it restarted and reach the _Running_ state
using `kubectl get pods`.


All of the container output to _STDOUT_ and _STDERR_ from the restarted pod will be accessible as Kubernetes logs.

```
kubectl logs ratings-v1-...
```

#### [Continue to Exercise 3 - Inspecting a Kubernetes deployment](../exercise-3/README.md)