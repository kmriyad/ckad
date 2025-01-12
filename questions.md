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
You are tasked to create a secret and consume the secret in a pod using environment variables as follows:
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
You are tasked to create a ConfigMap and consume the ConfigMap in a pod using a volume mount.
#### Task
Please complete the following:
- Create a ConfigMap named some-config containing the key/value pair: key4/value4
- Start a pod named nginx-configmap containing a single container using the nginx Image, and mount the key you just created into the pod under directory /yet/another/path
### Question 6
#### Context
Your application's namespace requires a specific service account to be used.
#### Task
Update the appa deployment in the frontend namespace to run as the restrictedservice service account. The service account has already been created.



