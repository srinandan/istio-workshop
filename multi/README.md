## Summary 

In this lab, you will learn how to install and configure a multi-cluster mesh

# Table of Contents

* [How does it work?](#how)
* [Setup and Requirements](#setup-and-requirements)

## How does it work <a name="how"/>
NOTE: I think this is an area of Istio that is rapidly changing (improving). The statements below are true for Istio 1.0.

### Prerequisites

* Kubernetes v1.9 or higher; 1.10 is preferred.
* Helm 2.7.2 or higher
* Istio control plane installed on a Kubernetes cluster (which will be referred to as master)
* All pod CIDRs in every cluster must be routable to each other

## Setup and Requirements <a name="setup-and-requirements"/>

*WORK IN PROGRESS*

1. Complete Istio installation on the master cluster as described in the previous labs.

2. Configing the remote cluster
  - Create a new GKE cluster
  -  

3. Install a sample application in the remote cluster

Create a file hello.yaml with the following contents

```
apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: helloworld-v1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: helloworld
        version: v1
    spec:
      containers:
      - name: helloworld
        image: istio/examples-helloworld-v1
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
```

```
kubectl apply -f <(istioctl kube-inject -f hello.yaml)>  
```

## Testing the setup

Get the Cluster IP of the details application (from the master cluster)

```
kubectl get svc
```

OUTPUT:
```
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
details       ClusterIP   10.35.248.207   <none>        9080/TCP            18d
```

Access the bash shell in the helloworld application

```
kubectl exec -it helloworld-v1-c5c996c78-xw8d2 bash
```

Access the details IP with the cluster IP

```
curl 10.35.248.207:9080/details/0
```
OUTPUT:
```
{"id":0,"author":"William Shakespeare","year":1595,"type":"paperback","pages":200,"publisher":"PublisherA","language":"English","ISBN-10":"1234567890","ISBN-13":"123-1234567890"}
```

## Observations

* At the moment, DNS is the responsibility of the user (Istio does not provide a solution)
* There are a few options discussed in the community [here](https://groups.google.com/forum/#!topic/istio-users/MbG9DNT7Duk)