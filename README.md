## Introduction
An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

It is a great way of handling an incoming request, whether to add or modify fields or deny the request as per the rules/configuration defined.

There are two types of admission webhooks: **Mutating webhook** & **Validation webhook**.

I'm going to create a mutating webhook that will inject a label to certain pods upon creation. (AKA mutaing)

## Installation (local)

Create a kind cluster:

```bash
kind create cluster --name webhook --image kindest/node:v1.20.2
```

## TLS certificate notes for Webhook
To extend the native functionalities, these admission webhook controllers call a custom-configured HTTP callback (webhook server) for additional checks. But the API server only communicates over HTTPS with the admission webhook servers and needs TLS cert’s CA information.

This poses a problem for how we handle this webhook server certificate and how to pass CA information to the API server automatically.

I created a script for generating tls certs and CA.
```bash
cd tls
./tls-generator.sh

# populate caBundle (webhook-config.yaml)
base64 ca.crt

# populate tls cert & key (webhook-server.yaml)
base64 webhook-server.crt
base64 webhook-server.key 
```

## Mutating webhook
A custom [admission webhook server](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#what-are-admission-webhooks)  is just a simple HTTP server with TLS that exposes endpoints for mutation and validation.

The implementation details are in the `webhook-server-src` folder.

## Deployment

```bash
# deploy webhook server
kubectl apply -f webhook-server-yaml

# deploy webhook config
kubectl apply -f webhook-config.yaml

# test webhook
kubectl apply -f test-pod.yaml

# check if the custom label exists
kubectl get pods --show-labels
```
