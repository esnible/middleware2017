http://2017.middleware-conference.org/tutorials.html

Istio Service mesh for more robust, secure and easy to manage microservices

Priya Nagpurkar, IBM T. J. Watson Research Center 
Fabio Oliveira, IBM T. J. Watson Research Center

Abstract: Writing reliable, loosely coupled, production-grade applications based on microservices can be challenging. As monolithic applications are decomposed into microservices, software teams have to worry about the challenges inherent in integrating services in distributed systems: they must account for service discovery, load balancing, fault tolerance, end-to-end monitoring, dynamic routing for feature experimentation, and compliance and security.Inconsistent attempts at solving these challenges, cobbled together from libraries, scripts and Stack Overflow snippets leads to solutions that vary wildly across languages and runtimes, and have poor observability.

Google, IBM and Lyft joined forces to create the microservice mesh called Istio with the goal of providing a reliable substrate for microservice development and maintenance. Istio brings SDN concepts to microservices by transparently injecting a layer 7 proxy (data plane) between a service and the network and introducing a control plane to define and enforce policies. Istio provides fine grained control and observability while at the same time freeing up developers from the complexity of building distributed systems.

This tutorial will start with a quick overview of common best practices to build robust microservices, their embodiment in popular software components and finally the approach taken by istio. We will then introduce key istio concepts, discuss real-world use cases, and illustrate how istio enables traffic management, observability, policy enforcement through a hands-on session. We will end with a discussion on promising research directions like automated resiliency testing and tools and techniques for advanced DevOps.

Who can attend: Some familiarity with microservices, usage of docker containers, kubernetes. Preferably an account with IBM Bluemix Kubernetes cluster if they want to play along with the system in real time.
