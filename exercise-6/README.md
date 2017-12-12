# Exercise 6 - Request routing

These steps are based on the Istio documentation at https://istio.io/docs/tasks/traffic-management/request-routing.html

## Bookinfo

![Book Info structure](withistio.svg)

If you access Bookinfo several times, you’ll notice that sometimes the output contains star ratings. This is because without an explicit default version set, Istio will route requests to all available versions of a service in a random fashion.

![Black stars in UI](blackstars.png)

*reload a few times*

![Red stars in UI](blackstars.png)

## Content-based routing

Because the BookInfo sample deploys 3 versions of the reviews microservice, we need to set a default route. 

Set the default version for all microservices to v1.

```
cd /tmp/istio-0.2.12
istioctl create -f samples/bookinfo/kube/route-rule-all-v1.yaml
```

You can display the routes that are defined:

```
istioctl get routerules -o yaml
```

```
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: details-default
  namespace: default
  ...
spec:
  destination:
    name: details
  precedence: 1
  route:
  - labels:
      version: v1
---
...
```

Since rule propagation to the proxies is asynchronous, you should wait a few seconds for the rules to propagate to all pods before attempting to access the application.

Open the BookInfo URL (http://$GATEWAY_URL/productpage) in your browser
You should see the BookInfo application productpage displayed. Notice that the _productpage_ is displayed with no rating stars since _reviews:v1_ does not access the ratings service.

Route a specific user to _reviews:v2_

Lets enable the ratings service for test user “jason” by routing productpage traffic to _reviews:v2_ instances.

```
istioctl create -f samples/bookinfo/kube/route-rule-reviews-test-v2.yaml
```

Log in as user “jason” at the _productpage_ web page.

You should now see ratings (1-5 stars) next to each review. Notice that if you log in as any other user, you will continue to see reviews:v1.

## Understanding what happened

In this task, you used Istio to send 100% of the traffic to the v1 version of each of the BookInfo services. You then set a rule to selectively send traffic to version v2 of the reviews service based on a header (i.e., a user cookie) in a request.

Once the v2 version has been tested to our satisfaction, we could use Istio to send traffic from all users to v2, optionally in a gradual fashion.

### Rules Configuration

Istio provides a simple Domain-specific language (DSL) to control how API calls and layer-4 traffic flow across various services in the application deployment. The DSL allows the operator to configure service-level properties such as circuit breakers, timeouts, retries, as well as set up common continuous deployment tasks such as canary rollouts, A/B testing, staged rollouts with %-based traffic splits, etc. See [Istio's routing rules reference](https://istio.io/docs/reference/config/traffic-rules/) for detailed information.

For example, a simple rule to send 100% of incoming traffic for a “reviews” service to version “v1” can be described using the Rules DSL as follows:

```
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: reviews-default
spec:
  destination:
    name: reviews
  route:
  - labels:
      version: v1
    weight: 100
```

The destination is the name of the service to which the traffic is being routed. The route labels identify the specific service instances that will recieve traffic. For example, in a Kubernetes deployment of Istio, the route label “version: v1” indicates that only pods containing the label “version: v1” will receive traffic.

Rules can be configured using the _istioctl_ CLI.

# Route Rules

Route rules control how requests are routed within an Istio service mesh. For example, a route rule could route requests to different versions of a service. Requests can be routed based on the source and destination, HTTP header fields, and weights associated with individual service versions.

You may qualify rules by destination, or by source and headers.  Rules also let us inject fault tolerance
behavior, such as retries and timeouts.  We can inject faults to test that our logic handles fault conditions.

# Istio Sidecar implementation

Without Istio, outbound traffic is sent to a Kubernetes Service, and the load balancer on that service
directs traffic to the pod instances that implement the service.

Under Istio, an instance of Envoy running in the sidecar has cached this information.  Envoy gets this
information from the Istio Pilot.  Pilot acts as an Envoy Discovery Service.  The sidecars poll
`http://istio-pilot:8080/v1/registration/`.

We can't contact that address directly -- it isn't exposed outside the cluster.  For debugging purposes we
sometimes need to test how networking behaves inside the cluster.  I use the public Docker image
_appropriate/curl_ for that.

Contact the Envoy discovery service and ask for a description of the mesh:

```
kubectl run --namespace istio-system -i --rm --restart=Never dummy --image=appropriate/curl istio-pilot:8080/v1/registration/
```

The output of this command will be a JSON description of the system.

## Cleanup

Remove the application routing rules.

```
istioctl delete -f samples/bookinfo/kube/route-rule-all-v1.yaml
istioctl delete -f samples/bookinfo/kube/route-rule-reviews-test-v2.yaml
```

#### [Continue to Exercise 7 - Telemetry](../exercise-7/README.md)