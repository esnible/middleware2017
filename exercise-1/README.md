# Exercise 1 - Accessing a Kubernetes cluster with IBM Cloud Container Service

Your IBM Cloud paid account and your Kubernetes cluster have been pre-provisioned for you. Here are the steps to access your cluster:

### Use Docker image containing Kubernetes, Istio, and IBM Cloud CLIs

1. Install Docker if not already installed
- https://docs.docker.com/docker-for-mac/install/
- https://docs.docker.com/docker-for-windows/install/
- https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/

2. Run the demo image

From a system with Docker installed,

```
git clone git@github.ibm.com:snible/istio-clienv.git
cd istio-clienv
./scripts/build.sh
docker run -it --name devenv -p 8001:8001 -p 8080:8080 -p 8088:8088 middleware17/istioenv
```

The build should take about a minute and a half.

<!-- docker pull snible/middleware17/istioenv # first push my image to the Docker hub -->

This image includes the CLI _bx_, for accessing IBM Cloud, _kubectl_, for accessing Kubernetes,
and _istioctl_ for accessing Istio.  It also includes the Istio 0.2.12 download.

### (Alternate) Building your own command line environment

Follow the instructions at https://github.com/szihai/istio-workshop/blob/master/exercise-1/README.md to
install the tools on yourself.

### Access your cluster

To use the Kubernetes
that has been prepared for this tutorial you must log in to IBM Cloud.

```
bx login -a https://api.ng.bluemix.net # -u $BM_USER -o $BM_USER -p $BM_PASSWORD -s $BM_SPACE -c $BM_ACCOUNT_ID
bx cs region-set us-east
bx cs clusters
bx cs cluster-config middleware17 # Use your own cluster name
```

Cut-and-paste the configuration output by the previous step, or automatically apply it by doing

```
# Point `KUBECONFIG` to personal Kubernetes cluster on IBM Cloud
eval $(bx cs cluster-config $(bx cs clusters | tail -n 1 | awk '{print $1}') | grep export)
```

At this point _kubectl_ should be functional.  To verify,

```
kubectl get pods
```

### Access the Kubernetes web UI


Create a proxy to your Kubernetes API server.

```
# By using 0.0.0.0 instead of the default 127.0.0.1 the UI is available beyond the container
kubectl proxy --address='0.0.0.0' &
```

In a browser, go to http://localhost:8001/ui to access the API server UI.

It is also possible to use the IBM Cloud UI at https://console.bluemix.net/dashboard/
to view details of the Kubernetes nodes but this is beyond the scope of this tutorial.

#### [Continue to Exercise 2 - Deploying a microservice application to Kubernetes](../exercise-2/README.md)
