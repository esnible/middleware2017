# Exercise 4 - Installing Istio

### Clean up
 
Start with a clean slate by deleting all bookinfo from the cluster.

```sh
cd /tmp/istio-0.2.12/samples/bookinfo/kube/
kubectl apply -f bookinfo.yaml
```

### Install Istio on the Kubernetes cluster

The tutorial environment already includes the Istio client and the Istio infrastructure deployment files.
If you do not have the client, follow the download instructions at https://github.com/szihai/istio-workshop/blob/master/exercise-5/README.md

Change the directory to the Istio file location.

```
cd /tmp/istio-0.2.12
```

Install Istio on the Kubernetes cluster.

```
kubectl apply -f install/kubernetes/istio.yaml
```

TODO Add the istio.yaml that fixes the ingress-absent-from-traces to image.  Name it istio-fix.yaml

### Install Add-ons for Grafana, Prometheus, and Zipkin

```sh
kubectl apply -f install/kubernetes/addons/zipkin.yaml
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl apply -f install/kubernetes/addons/prometheus.yaml
kubectl apply -f install/kubernetes/addons/servicegraph.yaml
```

### View the Istio system deployments

Istio is deployed in a separate Kubernetes namespace _istio-system_.

```sh
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
```

#### [Continue to Exercise 5 - Deploying a microservice application with Istio Proxies](../exercise-5/README.md)