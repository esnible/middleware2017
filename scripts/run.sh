#!/bin/bash
#

set -o errexit

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Running locally doesn't work because we don't have credentials in the image to talk to our cluster
# docker run isankey2

# We must deploy into the istio-system namespace so that we will have access to the istio-pilot service
# We must use a custom secret to read from the private registry so we cannot use kubectl run
kubectl run --namespace istio-system isankey2 --image-pull-policy=Always --image esnible/isankey2

#cat $SCRIPTDIR/isankey2.yaml | \
#   sed "s/NAMESPACE/$DOCKER_NAMESPACE/" | \
#   sed "s/REGISTRY/$DOCKER_REGISTRY/" | \
#   kubectl apply -f -

# kubectl expose pod istio-analytics --port 8088
echo Next, do
echo kubectl port-forward --namespace istio-system $(kubectl get pods --namespace istio-system --selector run=isankey2 --output jsonpath={.items[0].metadata.name}) 8088:8088 '&'
