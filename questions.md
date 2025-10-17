### Question 1 (4)
#### Context
You sometimes need to observe a pod's logs, and write those logs to a file for further analysis.
#### Task
Please complete the following:
Deploy the counter pod to the cluster using the provided YAML spec file at /opt/KDOB00201/counter-pod.yaml
Retrieve all currently available application logs from the running pod and store them in the file /opt/KDOB00201/log_output.txt, which has already been created
### Question 2 (4)
#### Context
A web application requires a specific version of redis to be used as a cache.
#### Task
Create a pod with the following characteristics, and leave it running when complete:
- The pod must run in the web namespace. The namespace has already been created
- The name of the pod should be cache
- Use the lfccncf/redis Image with the 3.2 tag
- Expose port 6379
### Question 3 (5)
#### Context
You are tasked to create a secret and consume the secret in a pod using environment variables as follows in the qtn3 namespace:
#### Task
- Create a secret named some-secret with a key/value pair: key1/value4
- Start an nginx pod named nginx-secret using container image nginx, and add an environment variable exposing the value of the secret key key1, using COOL_VARIABLE as the name for the environment variable inside the pod
### Question 4 (4)
#### Context
You are required to create a pod that requests a certain amount of CPU and memory, so it gets scheduled to a node that has those resources available.
#### Task
- Create a pod named nginx-resources in the pod-resources namespace that requests a minimum of 200m CPU and 64Mi memory for its container
- The pod should use the nginx Image
- The pod-resources namespace has already been created
### Question 5 (5)
#### Context
You are tasked to create a ConfigMap and consume the ConfigMap in a pod using a volume mount in the qtn5 namespace.
#### Task
Please complete the following:
- Create a ConfigMap named some-config containing the key/value pair: key4/value4
- Start a pod named nginx-configmap containing a single container using the nginx Image, and mount the key you just created into the pod under directory /yet/another/path
### Question 6 (5)
#### Context
Your application's namespace requires a specific service account to be used.
#### Task
Update the appa deployment in the frontend namespace to run as the restrictedservice service account. The service account has already been created.
### Question 7 (2)
#### Context
A pod is running on the cluster but it is not responding in the namespace qtn7.
##### Task
- The desired behavior is to have Kubernetes restart the pod when an endpoint returns an HTTP 500 on the /healthz endpoint. 
- The service, probe-http, should never send traffic to the pod while it is failing. 
- Please complete the following:
  - The application has an endpoint, /started, that will indicate if it can accept traffic by returning an HTTP 200. If the endpoint returns an HTTP 500, the application has not yet finished initialization
  - The application has another endpoint /healthz that will indicate if the application is still working as expected by        returning an HTTP 200. If the endpoint returns an HTTP 500 the application is no longer responsive
  - Configure the probe-http pod provided to use these endpoints
  - The probes should use port 8080
### Question 8 (2)
#### Context
It is always useful to look at the resources your applications are consuming in a cluster.
##### Task
From the pods running in namespace stress, write the name only of the pod that is consuming the most CPU to file /opt/KDOB00301/pod.txt, which has already been created
### Question 9 (3)
#### Context
Anytime a team needs to run a container on Kubernetes they will need to define a pod within which to run the container.
#### Task
Please complete the following:
- Create a YAML formatted pod manifest /opt/KDPD00101/pod1.yml to create a pod named app1 that runs a container named app1cont using Image lfccncf/arg-output with these command line arguments: -Q --dep test
- Create the pod with the kubectl command using the YAML file created in the previous step
- When the pod is running display summary data about the pod in JSON format using the kubectl command and redirect the output to a file named /opt/KDPD00101/out1.json

All of the files you need to work with have been created, empty, for your convenience
### Question 10 (7)
#### Context
Run deployment
#### Task
Create a new deployment for running nginx with the following parameters:
- Run the deployment in the kdpd00201 namespace. The namespace has already been created
- Name the deployment nginx and configure with 3 replicas
- Configure the pod with a container image of lfccncf/nginx:1.12.2-alpine
- Set an environment variable of NGINX_PORT=80 
- Expose that port for the container above
### Question 11 (6)
#### Context
As a Kubernetes application developer you will often find yourself needing to update a running application.
#### Task
Please complete the following:
- Update the webapp deployment in the kdpd00202 namespace with a maxSurge of 4 and a maxUnavailable of 10%
- Perform a rolling update of the webapp deployment, changing the lfccncf/nginx Image version to 1.13
- Roll back the webapp deployment to the previous version
### Question 12 (7)
#### Context
Given a container that writes a log file in format A and a container that converts log files from format A to format B, create a deployment that runs both containers such that the log files from the first container are converted by the second container, emitting logs in format B.
#### Task
Create a deployment named deployment-007 in the default namespace, that:
- Includes a primary lfccncf/busybox:1 container, named logger-123
- Includes a sidecar lfccncf/fluentd:v0.12 container, named adaptor-dev
- Mounts a shared volume /tmp/log on both containers, which does not persist when the pod is deleted
- Instructs the logger-123 container to run the command
    while true; do
        echo "i luv cncf" >> /tmp/log/input.log;
        sleep 10;
    done
- which should output logs to /tmp/log/input.log in plain text format, with example values:
    i luv cncf
    i luv cncf
    i luv cncf
- The adaptor-dev sidecar container should read /tmp/log/input.log and output the data to /tmp/log/output.* in Fluentd JSON format. Note that no knowledge of Fluentd is required to complete this task: all you will need to achieve this is to create the ConfigMap from the spec file provided at /opt/KDMC00102/fluentd-configmap.yaml, and mount that ConfigMap to /fluentd/etc in the adaptor-dev sidecar container
### Question 13 (4)
#### Context
Developers occasionally need to run pods that run periodically.
#### Task
Follow the steps below to create a pod that will start at a predetermined time and which runs to completion only once each time it is started:
- Create a YAML formatted Kubernetes manifest /opt/KDPD00301/periodic.yaml that runs the following shell command: uname in a single busybox container. 
- The command should run every minute and must complete within 17 seconds or be terminated by Kubernetes. 
- The CronJob name and container name should both be hello
- Create the resource in the above manifest and verify that the job executes successfully at least once
### Question 14 (6)
#### Context
You have been tasked with scaling an existing deployment for availability, and creating a service to expose the deployment within your infrastructure.
#### Task
Start with the deployment named kdsn00101-deployment which has already been deployed to the namespace kdsn00101. Edit it to:
- Add the tier=dmz key/value label to the pod template metadata to identify the pod for the service definition
- Have 4 replicas
Next, create and deploy in namespace kdsn00101 a service that accomplishes the following:
- Exposes the service on TCP port 8080
- Is mapped to the pods defined by the specification of kdsn00101-deployment
- Is of type NodePort
- Has a name of cherry
### Question 15 (3)
#### Context
A container within the poller pod is hard-coded to connect the nginxsvc service on port 60. As this port changes to 9090 an additional container needs to be added to the poller pod which adapts the container to connect to this new port. This should be realized as an ambassador container within the pod.
#### Task
- Update the nginxsvc service to serve on port 9090
- Add an HAproxy container named ambassador bound to port 60 to the poller pod and deploy the enhanced pod. - Use the Image haproxy and inject the configuration located at /opt/KDMC00101/haproxy.cfg with a ConfigMap named haproxy-config, mounted into the container so that haproxy.cfg is available at /usr/local/etc/haproxy/haproxy.cfg. 
- Ensure that you update the args of the poller container to connect to localhost instead of nginxsvc so that the connection is correctly proxied to the new service endpoint. 
- You must not modify the port of the endpoint in poller's args. 
- The spec file used to create the initial poller pod is available in /opt/KDMC00101/poller.yaml
### Question 16 (9)
#### Context
Your application needs persistent storage that survives pod restarts and rescheduling. You have been tasked with creating a PersistentVolumeClaim and mounting it in a pod to store application data.
#### Task
Complete the following tasks in the storage namespace (already created):
- Create a PersistentVolumeClaim named app-pvc with the following specifications:
  - Request 2Gi of storage
  - Use accessMode ReadWriteOnce
  - Use storageClassName standard (if available) or leave unspecified to use default
- Create a pod named storage-pod that:
  - Uses the nginx image
  - Mounts the PersistentVolumeClaim app-pvc at /usr/share/nginx/html
  - Has a label app=storage
- Verify the PVC is bound and the pod is running
### Question 17 (4)
#### Context
Applications can fail to deploy due to configuration errors. Troubleshooting deployment failures is a critical skill for Kubernetes developers.
#### Task
A deployment named web-app in the namespace troubleshoot has been created but the pods are failing to start due to an incorrect container image being specified. Complete the following:
- Investigate the deployment in the troubleshoot namespace to identify why the pods are not running
- Fix the deployment to use the correct image: nginx:1.24.0
- Verify that the deployment becomes available with at least 2 ready replicas
### Question 18 (6)
#### Context
Network policies in Kubernetes allow you to control traffic flow between pods. Proper network segmentation is crucial for security in a microservices architecture.
#### Task
You have rolled out a new pod to your infrastructure and now you need to allow it to communicate with the proxy and storage pods but nothing else. Complete the following in the kdsn00201 namespace:
- A pod named kdsn00201-newpod is already running in the kdsn00201 namespace
- Pods named proxy and storage are also running in the same namespace
- NetworkPolicy resources named allow-proxy and allow-storage have already been created
- Edit the kdsn00201-newpod to add the appropriate labels so that it matches the network policies
- The required labels are: app=restricted for allow-proxy policy, and app=restricted for allow-storage policy
- Verify that the pod is running with the correct labels applied

Note: You should not create, modify, or delete any network policies. Only modify the pod labels.
### Question 19 (6)
#### Context
A user has reported an application is unreachable due to a failing livenessProbe. You need to identify the broken pod, capture diagnostic information, and fix the issue.
#### Task
Perform the following tasks:
- Find the broken pod and store its name and namespace to /opt/KDOB00401/broken.txt in the format: `<namespace>/<pod>` (e.g., `qa/my-pod`)
- Store the associated error events to a file /opt/KDOB00401/error.txt using the `kubectl describe` command with `-o wide` output specifier
- Fix the livenessProbe issue so the pod runs successfully
- The associated deployment could be running in any of the following namespaces: qa, test, production, alan

Both output files (/opt/KDOB00401/broken.txt and /opt/KDOB00401/error.txt) have already been created.
### Question 20 (8)
#### Context
A project that you are working on has a requirement for persistent data to be available using hostPath volumes. This involves creating storage on a specific node, defining a PersistentVolume, and binding it to a pod through a PersistentVolumeClaim.
#### Task
Perform the following tasks to set up persistent storage:
- Create a directory /opt/KDSP00101/data on the cluster node (use the local node if running single-node, or any worker node in multi-node setup)
- Create a file at /opt/KDSP00101/data/index.html with the content: `Acct=Finance`
- Create a PersistentVolume named task-pv-volume with the following specifications:
  - Use hostPath type pointing to /opt/KDSP00101/data
  - Allocate 3Gi capacity
  - Access mode: ReadWriteOnce
  - StorageClassName: exam
- Create a PersistentVolumeClaim named task-pv-claim with the following specifications:
  - Request at least 100Mi of storage
  - Access mode: ReadWriteOnce
  - StorageClassName: exam
- Create a pod named storage-app that:
  - Uses the nginx image
  - Has label app=my-storage-app
  - Mounts the PVC task-pv-claim to /usr/share/nginx/html
- Verify that the pod can access the index.html file

Note: If your cluster has multiple nodes, you may need to SSH to a worker node to create the directory and file. Ensure you return to the control plane node after completing the node-specific work.













