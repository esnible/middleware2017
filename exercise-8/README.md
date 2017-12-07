# Exercise 8 - Fault injection

This exercise inspired by https://istio.io/docs/concepts/traffic-management/fault-injection.html

While Envoy sidecar/proxy provides a host of failure recovery mechanisms to services running on Istio, it is still imperative to test the end-to-end failure recovery capability of the application as a whole. Misconfigured failure recovery policies (e.g., incompatible/restrictive timeouts across service calls) could result in continued unavailability of critical services in the application, resulting in poor user experience.

Operators can configure faults to be injected into requests that match specific criteria. Operators can further restrict the percentage of requests that should be subjected to faults. Two types of faults can be injected: delays and aborts. Delays are timing failures, mimicking increased network latency, or an overloaded upstream service. Aborts are crash failures that mimick failures in upstream services. Aborts usually manifest in the form of HTTP error codes, or TCP connection failures.

A route rule can specify one or more faults to inject while forwarding http requests to the rule’s corresponding request destination. The faults can be either delays or aborts.

The following example will introduce a 5 second delay in 10% of the requests to the “v1” version of the “reviews” microservice.

```
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: ratings-delay
spec:
  destination:
    name: reviews
  route:
  - labels:
      version: v1
  httpFault:
    delay:
      percent: 10
      fixedDelay: 5s
```

The other kind of fault, abort, can be used to prematurely terminate a request, for example, to simulate a failure.

The following example will return an HTTP 400 error code for 10% of the requests to the “ratings” service “v1”.

```
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: ratings-abort
spec:
   destination:
     name: ratings
   route:
   - labels:
       version: v1
   httpFault:
     abort:
       percent: 10
       httpStatus: 400
```

We could inject these faults by placing the YAML description in a file and using
`istioctl create routerule -f ...` to script the fault inject.  We use this technique to
script tests to ensure that our application runs when its dependent services are down or slow.

For this tutorial we will experiment interactively with fault injection and monitoring system behavior
in the presence of HTTP faults.

## A simple control panel for fault injection

Authorize and start the fault injection tool.

<!--
kubectl create clusterrole isankey-istio-system --verb=get,update,list,create,delete --resource=routerules
kubectl create clusterrolebinding isankey-istio-system 
-->

```
cd /tmp
./scripts/authorize.sh
kubectl run --namespace istio-system isankey2 --image-pull-policy=Always --image esnible/isankey2
kubectl expose deployment --namespace istio-system isankey2 --port 8088 --type=NodePort --name sankey-np
kubectl get services --namespace istio-system | grep sankey-np
export SANKEY_PORT=$(kubectl --namespace istio-system get service sankey-np  -o jsonpath='{.spec.ports[0].nodePort}')
echo Fault Inection Tool is at $GATEWAY_IP:$SANKEY_PORT
```

Open two browser windows.  Point one to `http://<gateway>:<port>/` and the other to `http://<gateway>:<port>/sankey.html`

You should see the usage graph on the second window.  Use the first window to start injecting errors and watch the second graph animate to show how the flow is changing.

If the load driver has stopped restart it to deliver some load to the application.

```sh
while sleep 2; do curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage; done
```

TODO incorporate book info steps https://istio.io/docs/tasks/traffic-management/traffic-shifting.html

#### Bibliography and next steps

https://developer.ibm.com/dwblog/2017/istio-ecosystem-weave-scope-zipkin-microservices/

