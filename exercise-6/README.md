# Exercise 6 - Telemetry

Before we can look at the application's behavior let's generate load.

We exported _GATEWAY_URL_ in [Continue to Exercise 5 - Deploying a microservice application with Istio Proxies](../exercise-5/README.md).

```sh
while sleep 2; do curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage; done
```

The loop doesn't terminate.  We can open another window into our dev environment container using

```
docker exec -it devenv /bin/bash
```

To re-establish settings to talk to the IBM Cloud Kubernetes cluster,

```
bx cs cluster-config middleware17 # Use your own cluster name
```

## View guestbook telemetry data

### Grafana

Establish port forwarding from local port 3000 to the Grafana instance:
```sh
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana \
  -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
```

Browse to http://localhost:3000 and navigate to the Istio Dashboard.

### Zipkin
Establish port forwarding from local port 9411 to the Zipkin instance:
```sh
kubectl port-forward -n istio-system \
  $(kubectl get pod -n istio-system -l app=zipkin -o jsonpath='{.items[0].metadata.name}') \
  9411:9411 &
```

Browse to http://localhost:9411.

### Prometheus
Establish port forwarding from local port 9090 to the Prometheus instance:
```sh
kubectl -n istio-system port-forward \
  $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') \
  9090:9090 &
```

Browse to http://localhost:9090/graph, and in the “Expression” input box, enter: `request_count`. Click **Execute**.


### Service Graph
Establish port forwarding from local port 8088 to the Service Graph instance:
```sh
kubectl -n istio-system port-forward \
  $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') \
  8088:8088
```

Browse to http://localhost:8088/dotviz.

#### Mixer Log Stream

```sh
kubectl -n istio-system logs $(kubectl -n istio-system get pods -l istio=mixer -o jsonpath='{.items[0].metadata.name}') mixer | grep \"instance\":\"newlog.logentry.istio-system\"
```

#### [Continue to Exercise 7 - Request routing](../exercise-7/README.md)