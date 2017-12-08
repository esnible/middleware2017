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

## Traffic Shifting

We will now gradually migrate traffic from an old to new version of a service. With Istio, we can migrate the traffic in a gradual fashion by using a sequence of rules with weights less than 100 to migrate traffic in steps, for example 10, 20, 30, … 100%. For simplicity this task will migrate the traffic from reviews:v1 to reviews:v3 in just two steps: 50%, 100%.

### Weight-based version routing

Set the default version for all microservices to v1.

```
istioctl create -f samples/bookinfo/kube/route-rule-all-v1.yaml
```

Confirm v1 is the active version of the reviews service by opening http://$GATEWAY_URL/productpage in your browser.

You should see the BookInfo application productpage displayed. Notice that the productpage is displayed with no rating stars since reviews:v1 does not access the ratings service.

Note: If you previously ran the request routing task, you may need to either log out as test user “jason” or delete the test rules that were created exclusively for him:

```
istioctl delete routerule reviews-test-v2
```

First, transfer 50% of the traffic from reviews:v1 to reviews:v3 with the following command:

```
istioctl replace -f samples/bookinfo/kube/route-rule-reviews-50-v3.yaml
```

Notice that we are using istioctl *replace* instead of _create_.

Refresh the productpage in your browser and you should now see red colored star ratings approximately 50% of the time.

Note: With the current Envoy sidecar implementation, you may need to refresh the productpage very many times to see the proper distribution. It may require 15 refreshes or more before you see any change. You can modify the rules to route 90% of the traffic to v3 to see red stars more often.

When version v3 of the reviews microservice is considered stable, we can route 100% of the traffic to reviews:v3:

```
istioctl replace -f samples/bookinfo/kube/route-rule-reviews-v3.yaml
```

You can now log into the productpage as any user and you should always see book reviews with red colored star ratings for each review.

## Understanding what happened

In this task we migrated traffic from an old to new version of the reviews service using Istio’s weighted routing feature. Note that this is very different than version migration using deployment features of container orchestration platforms, which use instance scaling to manage the traffic. With Istio, we can allow the two versions of the reviews service to scale up and down independently, without affecting the traffic distribution between them. For more about version routing with autoscaling, check out Canary Deployments using Istio.


#### Bibliography and next steps

https://developer.ibm.com/dwblog/2017/istio-ecosystem-weave-scope-zipkin-microservices/

