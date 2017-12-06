# Notes on setting up and using Istio

## Setting up Bluemix

```
# If using free account
bx login -a https://api.ng.bluemix.net -u $BM_USER -o $BM_USER -p $BM_PASSWORD -s $BM_SPACE -c $BM_ACCOUNT_ID
# If using paid account
bx login --sso
bx cs init # Redo after each login if you change accounts
bx cs clusters
bx cs cluster-config mycluster-us # Use your own cluster name
export KUBECONFIG=/Users/snible/.bluemix/plugins/container-service/clusters/mycluster-us/kube-config-hou02-mycluster-us.yml
```

The Istio install instructions are at https://istio.io/docs/setup/kubernetes/quick-start.html

On OSX, don't follow them in the /tmp directory.  (For some reason, if run from _/tmp_ it will set
the owner to a non-existent user and fail the untar.   Using _/tmp/tmp_ is fine.)

```
curl -L https://git.io/getLatestIstio | sh -
```

If you are using the IBM cloud and want a private Docker registry see
https://console.bluemix.net/containers-kubernetes/home/registryGettingStarted?env_id=ibm%3Ayp%3Aus-south

bx plugin install container-registry -r Bluemix

# Envoy implements the service mesh

Verify the pilot pods are running
```bash
kubectl get pods --namespace istio-system | grep pilot
istio-pilot-1168925427-421l0       1/1       Running             0          1d
```

Contact the Envoy discovery service and ask for a description of the mesh

```
kubectl run --namespace istio-system -i --rm --restart=Never dummy --image=appropriate/curl istio-pilot:8080/v1/registration/
```

# Getting an app to run on Kubernetes

We will look at https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

```
curl https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-master-deployment.yaml \
   > redis-master-deployment.yaml
vi redis-master-deployment.yaml
kubectl apply -f <(istioctl kube-inject -f redis-master-deployment.yaml)
# Change "apiVersion: apps/v1beta2" to "apiVersion: apps/v1beta1" if using Kubernetes 1.7.x
# kubectl apply -f redis-master-deployment.yaml
kubectl apply -f https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-master-service.yaml
```

It starts, and we can see it with `kubectl get pods` and `kubectl get services`.  We can ask see it the way Envoy does.

```bash
kubectl run --namespace istio-system -i --rm --restart=Never dummy --image=appropriate/curl istio-pilot:8080/v1/registration/
...
  {
   "service-key": "redis-master.default.svc.cluster.local",
   "hosts": [
    {
     "ip_address": "172.30.63.222",
     "port": 6379
    }
   ]
  },

...
```

Now the slaves

```bash
curl https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-slave-deployment.yaml > redis-slave-deployment.yaml
vi redis-slave-deployment.yaml
# Change "apiVersion: apps/v1beta2" to "apiVersion: apps/v1beta1" if using Kubernetes 1.7.x
# kubectl apply -f redis-slave-deployment.yaml
kubectl apply -f <(istioctl kube-inject -f redis-slave-deployment.yaml)
kubectl apply -f https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-slave-service.yaml
curl https://kubernetes.io/docs/tutorials/stateless-application/guestbook/frontend-deployment.yaml > frontend-deployment.yaml
vi frontend-deployment.yaml
# Change "apiVersion: apps/v1beta2" to "apiVersion: apps/v1beta1" if using Kubernetes 1.7.x
# kubectl apply -f frontend-deployment.yaml
kubectl apply -f <(istioctl kube-inject -f frontend-deployment.yaml)
kubectl apply -f https://kubernetes.io/docs/tutorials/stateless-application/guestbook/frontend-service.yaml
bx cs workers <cluster-name or id>
export GATEWAY_URL=<public IP of the worker node>:<port of frontend>
export GATEWAY_URL=184.172.234.176:30637
```

At this point you should be able to visit $GATEWAY_URL and see the front end.

To see the metrics gathered by Prometheus:

```bash
kubectl port-forward $(kubectl get pods --namespace istio-system --selector app=zipkin --output jsonpath={.items[0].metadata.name}) --namespace istio-system 9411:9411
```

Surf to http://localhost:9411

# TODO go back and add name: http to the ports of all three .yaml files before deploying.

# Note.  This demo creates frontend as a NodePort, and if we contact it via that NodePort then the Istio Ingress isn't involved.  We should be using the Ingress's port, not the frontend's port.

# Troubleshooting

Looking at pods

```
kubectl exec --namespace istio-system -it istio-pilot-3881298009-9vnhq --container istio-proxy /bin/bash
```

# Set up Grafana

```
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl port-forward $(kubectl get pods --namespace istio-system --selector app=grafana --output jsonpath={.items[0].metadata.name}) --namespace istio-system 3000:3000
```

Then visit http://localhost:3000/dashboard/db/istio-dashboard
