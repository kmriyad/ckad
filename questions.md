### Question 1
#### Context
You sometimes need to observe a pod's logs, and write those logs to a file for further analysis.
#### Task
Please complete the following:
Deploy the counter pod to the cluster using the provided YAML spec file at /opt/KDOB00201/counter-pod.yaml
Retrieve all currently available application logs from the running pod and store them in the file /opt/KDOB00201/log_output.txt, which has already been created
### Question 2
#### Context
A web application requires a specific version of redis to be used as a cache.
#### Task
Create a pod with the following characteristics, and leave it running when complete:
- The pod must run in the web namespace. The namespace has already been created
- The name of the pod should be cache
- Use the lfccncf/redis Image with the 3.2 tag
- Expose port 6379
### Question 3
#### Context
You are tasked to create a secret and consume the secret in a pod using environment variables as follows in the qtn3 namespace:
#### Task
- Create a secret named some-secret with a key/value pair: key1/value4
- Start an nginx pod named nginx-secret using container image nginx, and add an environment variable exposing the value of the secret key key1, using COOL_VARIABLE as the name for the environment variable inside the pod
### Question 4
#### Context
You are required to create a pod that requests a certain amount of CPU and memory, so it gets scheduled to a node that has those resources available.
#### Task
- Create a pod named nginx-resources in the pod-resources namespace that requests a minimum of 200m CPU and 2Gi memory for its container
- The pod should use the nginx Image
- The pod-resources namespace has already been created
### Question 5
#### Context
You are tasked to create a ConfigMap and consume the ConfigMap in a pod using a volume mount in the qtn5 namespace.
#### Task
Please complete the following:
- Create a ConfigMap named some-config containing the key/value pair: key4/value4
- Start a pod named nginx-configmap containing a single container using the nginx Image, and mount the key you just created into the pod under directory /yet/another/path
### Question 6
#### Context
Your application's namespace requires a specific service account to be used.
#### Task
Update the appa deployment in the frontend namespace to run as the restrictedservice service account. The service account has already been created.
### Question 7
#### Context
A pod is running on the cluster but it is not responding.
##### Task
- The desired behavior is to have Kubernetes restart the pod when an endpoint returns an HTTP 500 on the /healthz endpoint. 
- The service, probe-http, should never send traffic to the pod while it is failing. Please complete the following:
- The application has an endpoint, /started, that will indicate if it can accept traffic by returning an HTTP 200. If the endpoint returns an HTTP 500, the application has not yet finished initialization
- The application has another endpoint /healthz that will indicate if the application is still working as expected by returning an HTTP 200. If the endpoint returns an HTTP 500 the application is no longer responsive
- Configure the probe-http pod provided to use these endpoints
- The probes should use port 8080
### Question 8
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








