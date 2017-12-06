# Exercise 3 - Inspecting a Kubernetes deployment

### Using the Kubernetes dashboard to inspect your system

We performed `kubectl proxy --address='0.0.0.0'` from the Docker instance we launched in [Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Container Service](../exercise-1/README.md).  As long as the _proxy_ is running we can access the Kubernetes UI at http://localhost:8001/ui

### Inspecting the pods

TODO

### Inspecting the services

TODO

### Accessing Bookinfo

Although we created an Ingress to expose Bookinfo to the outside world it is an Istio Ingress and we aren't
yet ready to show the use of an Ingress.

For now we will use a temporary random IP and port to view the running Bookinfo sample.

```
kubectl expose service productpage --type=NodePort --target-port=9080 --type=NodePort --name productpage-np
# Record the port number between 9080 and TCP, e.g. 9080:32276/TCP would be port 32276
kubectl get services | grep productpage-np
# Record the public IP
bx cs workers middleware17
```

Point your browser to `<public-IP>:<nodeport>/productpage`.  You should see the Bookinfo UI there.  We will be
using this UI for further experiments.

<!--
Any web services on any pod can be exposed locally.  The Docker instance running the tutorial environment has port 8080 exposed.  Let's 

```
# localhost:8080 will respond as if it was productpage-v1:9080
kubectl port-forward productpage-v1-150936620-xv1j3 8080:9080
curl localhost:8080
```

TODO unfortunately the browser can't see productpage because the port-forward binds to 127.0.0.1, not 0.0.0.0.

-->

#### [Continue to Exercise 4 - Installing Istio](../exercise-4/README.md)