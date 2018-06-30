## Summary 
In this lab, you will learn how to expand the service mesh to include VM. Mesh expansion refers to a pattern where the Istio control plane (Pilot, Mixer & Citadel) are on Kubernetes and the sidecar envoy is on VMs. With this pattern you can bring workloads running on VMs into the Istio Service Mesh. 

# Table of Contents
1. [Pre-requisites](#prereq)
2. [Setup a GCE Instance](#gce) 
3. [Testing the mesh expansion setup](#meshtest)
4. [Access services in the mesh](#access)

## Pre-requisites <a name="prereq"/>
In order to complete this lab, you should have completed the instructions in the Istio Workshop.

## Setup a GCE Instance <a name="gce"/>
Create a new GCE instance. Let's call it `meshexpand` (this name will be used later).

1. Create a new Instance
* Zone: us-west1-a (this will be needed later)
* Name: meshexpand
* Boot Disk: Google Drawfork Ubuntu 16.04
* Allow HTTP and HTTPS traffic

<img src="../media/istio.png"/>

2. In the Google Cloud Shell, run the following commands
   - Generate ssh keys
     ```
     ssh-keygen -t rsa -b 4096 -C "youremail"
     ```
   - Add ssh key
     ```
     ssh-add ~/.ssh/id_rsa
     ```
     NOTE: if you get the error "Could not open a connection to your authentication agent.", then run 
     ```
     eval `ssh-agent -s`
     ```
   - Test ssh connection
     ```
     ssh vmUser@vmIP
     ```
     NOTE: If your ssh times out, ssh port (22) is probably blocked. Then run the following commands
     ```
     gcloud compute firewall-rules create open-22 --allow tcp:22 --source-ranges 0.0.0.0/0 --target-tags open-22
     ```
     ```
     gcloud compute instances add-tags meshexpand --tags open-22
     ```
3. Enable the Kuernetes cluster for mesh expansion

```
kubectl apply -f install/kubernetes/mesh-expansion.yaml
```
OUTPUT:
```
service "istio-pilot-ilb" created
service "dns-ilb" created
service "mixer-ilb" created
service "citadel-ilb" created
```

Confirm that the load balancers are running and that they have EXTERNAL-IP values:

```
kubectl get services -n istio-system
```

Caution: The EXTERNAL-IP column might show `<pending>` until the services are fully up and running. Do not proceed with the installation until they have EXTERNAL-IP values.

4. Export environment variables
```
export GCP_OPTS="--zone {zone} --project {project}"
export SERVICE_NAMESPACE=default
```
5. Generate the cluster configuration file
```
install/tools/setupMeshEx.sh generateClusterEnv {clustername}
```
This command creates a file named cluster.env in the current directory that contains a single line in the form:
```
ISTIO_SERVICE_CIDR=10.35.240.0/20
ISTIO_SYSTEM_NAMESPACE=istio-system
CONTROL_PLANE_AUTH_POLICY=MUTUAL_TLS
```

6. Generate the DNS configuration file
```
install/tools/setupMeshEx.sh generateDnsmasq
```
OUTPUT:
```
Generated Dnsmaq config file 'kubedns'. Install it in /etc/dnsmasq.d and restart dnsmasq.
install/tools/setupMeshEx.sh machineSetup does this for you.
```
7. Setup the GCE instance (note this only works for GCE)
```
install/tools/setupMeshEx.sh gceMachineSetup meshexpand
```
Here, `meshexpand` is the VM name.

OUTPUT:
```
......lot of lines
Selecting previously unselected package host.
(Reading database ... 98786 files and directories currently installed.)
Preparing to unpack .../host_1%3a9.10.3.dfsg.P4-8ubuntu1.10_all.deb ...
Unpacking host (1:9.10.3.dfsg.P4-8ubuntu1.10) ...
Setting up host (1:9.10.3.dfsg.P4-8ubuntu1.10) ...
*** Restarting istio proxy...
```
8. Complete the setup
Login to the VM and enable the certs to be read by users

```
chmod +r /etc/certs/*.pem
```

Restart istio-proxy and the node-agent
```
systemctl restart istio
systemctl restart istio-auth-node-agent
```

Create a user. The sidecar does not intercept traffic from root. To test our setup, we will create a new user

```
groupadd meshexpand
useradd meshexpand -g meshexpand -m -d /opt/meshexpand
```

## Testing the mesh expansion setup <a name="meshtest"/>

Run the command
```
host istio-pilot.istio-system
```
OUTPUT:
```
istio-pilot.istio-system has address 10.138.0.18
```

Run the command
```
host istio-pilot.istio-system.svc.cluster.local.
```
OUTPUT:
```
istio-pilot.istio-system.svc.cluster.local has address 10.35.244.91
```

Run the command
```
curl 'http://istio-pilot.istio-system:8080/v1/registration/istio-pilot.istio-system.svc.cluster.local|http-discovery'
```
OUTPUT:
```
{
  "hosts": [
   {
    "ip_address": "10.32.0.7",
    "port": 15007,
    "tags": {
     "az": "us-west1/us-west1-a"
    }
   }
  ]
 }
```
## Access services in the mesh <a name="access"/>
Access the details service from the VM.
```
curl details.default.svc.cluster.local:9080/details/0 -v
```
OUTPUT:
```
*   Trying 10.35.255.72...
* Connected to details.default.svc.cluster.local (10.35.255.72) port 9080 (#0)
> GET /details/0 HTTP/1.1
> Host: details.default.svc.cluster.local:9080
> User-Agent: curl/7.47.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< content-type: application/json
< server: envoy
< date: Sat, 30 Jun 2018 17:45:27 GMT
< content-length: 178
< x-envoy-upstream-service-time: 15
< 
* Connection #0 to host details.default.svc.cluster.local left intact
{"id":0,"author":"William Shakespeare","year":1595,"type":"paperback","pages":200,"publisher":"PublisherA","language":"English","ISBN-10":"1234567890","ISBN-13":"123-1234567890"}
```

At this point, you have added this VM into the mesh. This VM can access services in the mesh as if that VM were in Kubernetes.