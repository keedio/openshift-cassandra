# Openshift- Cassandra


Proof of concept with Apache Cassandra on OpenShift 3.4. 
2 pods that represents the Cassandra's ring.

## Quick start

Firs of all, you should have persistent storage assigned.

1. Create a new OpenShift project

2. Import the templates in your OpenShift project throw the UI. Once yo have do it, the build and deployment should start automatically.

3. Once the deployment has finished, create a route throw the UI.
## Template.yaml
In this template, there are two objects:
*	ImageStream: brings toghether a set of ‘n’ tagged container images in Docker format, so each time a new build is released, it will be tagged as ‘latest’. It’s similar than an image repository.
*	BuildConfig:  configuration that’s will receive a Dockerfile as input and will generate a container image as output, this image will be used later to generating the pods

## Deploy.yaml

In this template, there are the objects bellow:

*	PersistentVolumeClaim: it allows us to request for persistent storage for our data. It’s important to provide a name in order to associate it later (inside the deploy) to the logic volume, where Cassandra will store such data, in our case /var/lib/cassabdra/data
*	DeploymentConfig: configuration that we want to attach to our deployment, it’s consist of several attributes:
*	Replicas: number of pods for our deployment (ring nodes)
*	Containers: over this attribute we attach the base image of our containers, it allows us different options (among others)
*	Command: script or command that we want execute on the container start, in our case will be the one that modifies the Cassandra’s configuration file(docker-entrypoint.sh)
*	Env: it allows us to defining environment variables inside the container
*	Ports: published ports by the container
*	volumeMounts: logical volumes which will be generated inside the container
*	triggers: will be responsible of executing a new deploy if the base image has changed or if the deploys configuration has changed to.
* Services: we’ll need two services:
*	Cassandra-peers: this service will be used for the seeds to starting the gossip-protocol, thus, we’ll attached the ports 7000 and 7001, moreover we will indicate it throw the clusterIP = none attribute that it’s a headless service, that’s to say, we don’t 
*	Cassandra-cql: this service will be exposed to the outside, for that their type attribute must take the LoadBalancer or NodePort value, service’s port will be 9042 and finally we will indicate that the nodePort (the port for which the service will listen to the outside) Is of the range [30000-32767], this way we get it to be routed by the latter from the outside to our cql service. For more information on how OpenShift does this I recommend visiting: https://docs.openshift.com/container-platform/3.4/install_config/routing_from_edge_lb.html and https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport

## Openshift UI

From the UI, we can test our solution:

![alt tag](https://drive.google.com/file/d/0B8zS_2D73-OjZnI4SjE5Z2w1aUU/view?usp=sharing)

