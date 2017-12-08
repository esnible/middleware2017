# Exercise 9 - Traffic Shifting

This exercise inspired by https://istio.io/docs/tasks/traffic-management/traffic-shifting.html

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

