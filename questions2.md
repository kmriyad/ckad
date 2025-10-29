### Question 1 (4)
#### Context
Your organization needs to run a logging agent on every node in the cluster to collect system logs.
#### Task
Please complete the following:
- Create a DaemonSet named log-collector in the logging namespace
- Use the fluentd:v1.14 image
- Mount the host path /var/log to the container path /var/log with read-only access
- Verify that one pod is running on each node in the cluster

### Question 2 (4)
#### Context
A node has been tainted for special workloads, and you need to schedule a pod that can tolerate this taint.
#### Task
Please complete the following:
- A node in the cluster has the taint workload=special:NoSchedule (this has been pre-configured)
- Create a pod named special-app in the default namespace
- Use the nginx image
- Add a toleration so the pod can schedule on the tainted node
- Verify the pod is running on the tainted node

### Question 3 (4)
#### Context
Your application requires SSD storage and should only run on nodes with SSD disks.
#### Task
Please complete the following:
- Nodes with SSD storage have been labeled with disktype=ssd (this has been pre-configured)
- Create a deployment named fast-app in the default namespace with 2 replicas
- Use the nginx image
- Configure requiredDuringSchedulingIgnoredDuringExecution node affinity to require disktype=ssd
- Verify all pods are scheduled on nodes with the disktype=ssd label

### Question 4 (5)
#### Context
Your application requires stable network identities for database clustering.
#### Task
Please complete the following:
- Create a headless service named db-service in the stateful namespace with selector app=db, port 80
- Create a StatefulSet named db in the stateful namespace with 3 replicas
- Use the nginx image (simulating a database)
- Configure the pod template with label app=db and containerPort 80
- The StatefulSet should use the db-service as its serviceName
- Verify stable DNS names are available: db-0.db-service.stateful.svc.cluster.local, db-1.db-service.stateful.svc.cluster.local, db-2.db-service.stateful.svc.cluster.local

### Question 5 (5)
#### Context
Each instance of your stateful application needs its own persistent storage that survives pod deletion.
#### Task
Please complete the following:
- Create a StatefulSet named data-app in the stateful namespace with 2 replicas
- Use the busybox image with command: sh -c "echo $(hostname) > /data/id.txt && sleep 3600"
- Use volumeClaimTemplates to request 1Gi of storage with accessMode ReadWriteOnce
- Mount the volume at /data in the container
- Verify each pod has its own PersistentVolumeClaim
- Delete one pod and verify its data persists when the pod is recreated

### Question 6 (5)
#### Context
You need to manage the lifecycle of a StatefulSet including scaling and updates.
#### Task
Please complete the following:
- Scale the existing StatefulSet db from Question 4 to 5 replicas
- Update the StatefulSet image to nginx:1.24
- Observe that pods are created/updated in order (db-0, db-1, db-2, db-3, db-4)
- Scale the StatefulSet back down to 3 replicas
- Store your observations about the ordering behavior in the file /opt/KDST00301/observations.txt

### Question 7 (4)
#### Context
A service account needs permission to list pods in its namespace.
#### Task
Please complete the following:
- Create a Role named pod-reader in the rbac-test namespace
- The Role should allow get, list, and watch operations on pods
- Create a ServiceAccount named app-sa in the rbac-test namespace
- Create a RoleBinding named read-pods that binds the pod-reader Role to the app-sa ServiceAccount

### Question 8 (5)
#### Context
A monitoring tool needs to read node information across the entire cluster.
#### Task
Please complete the following:
- Create a ClusterRole named node-reader that allows get and list operations on nodes
- Create a ServiceAccount named monitor-sa in the monitoring namespace
- Create a ClusterRoleBinding named read-nodes that binds the node-reader ClusterRole to the monitor-sa ServiceAccount
- Verify the ServiceAccount has the correct permissions using kubectl auth can-i

### Question 9 (6)
#### Context
A pod should be able to read ConfigMaps but must not have access to Secrets for security reasons.
#### Task
Please complete the following:
- Create a ServiceAccount named limited-sa in the secure namespace
- Create a Role named configmap-reader that allows get and list operations on configmaps only
- Create a RoleBinding named read-configmaps binding the Role to the ServiceAccount
- Create a pod named limited-pod in the secure namespace using the nginx image
- Configure the pod to use the limited-sa ServiceAccount
- Test and document the permissions in /opt/KDRBAC00301/test-results.txt by showing the pod can access ConfigMaps but not Secrets

### Question 10 (5)
#### Context
An application pod is failing because it lacks permissions to create ConfigMaps, which it needs for its operation.
#### Task
Please complete the following:
- A pod named app-broken in the debug namespace is failing due to insufficient permissions
- The pod uses ServiceAccount app-service-account (already created)
- Create a Role that grants the necessary permissions to create ConfigMaps
- Create a RoleBinding to fix the permission issue
- Verify the pod can now successfully create ConfigMaps

### Question 11 (4)
#### Context
You need to run a one-time batch job that processes data and completes.
#### Task
Please complete the following:
- Create a Job named data-processor in the batch namespace
- Use the busybox image with command: sh -c "echo Processing data... && sleep 10 && echo Done > /tmp/result.txt"
- The Job should complete successfully once
- After completion, store the job status (Complete/Failed) in /opt/KDJOB00101/status.txt

### Question 12 (4)
#### Context
You need to process multiple items in parallel using a Job.
#### Task
Please complete the following:
- Create a Job named parallel-processor in the batch namespace
- Configure parallelism: 3 and completions: 9
- Use the busybox image with command: sh -c "echo Processing item $HOSTNAME && sleep 5"
- Verify that 3 pods run concurrently until 9 total completions are reached

### Question 13 (4)
#### Context
A batch job should have limits on retries and total execution time to prevent runaway processes.
#### Task
Please complete the following:
- Create a Job named timeout-job in the batch namespace
- Use the busybox image with command: sh -c "sleep 60"
- Set backoffLimit: 2
- Set activeDeadlineSeconds: 30
- Document the timeout behavior in /opt/KDJOB00301/behavior.txt explaining what happens when the job exceeds the deadline

### Question 14 (5)
#### Context
You need to limit resource consumption in a namespace to prevent resource exhaustion.
#### Task
Please complete the following:
- Create a namespace named quota-test
- Create a ResourceQuota in the namespace with these limits: pods: "3", requests.cpu: "1", requests.memory: "1Gi"
- Create 2 pods within the quota limits (each requesting 200m CPU and 256Mi memory)
- Attempt to create additional pods that would exceed the quota
- Document the quota enforcement behavior in /opt/KDRES00101/quota-test.txt

### Question 15 (5)
#### Context
You want to set default resource requests and limits for all pods in a namespace.
#### Task
Please complete the following:
- Create a namespace named limits-test
- Create a LimitRange in the namespace with:
  - default request: 100m CPU, 128Mi memory
  - default limit: 200m CPU, 256Mi memory
  - min: 50m CPU, 64Mi memory
  - max: 500m CPU, 512Mi memory
- Create a pod named test-pod using nginx image without specifying resource requests/limits
- Verify the default values are automatically applied to the pod

### Question 16 (5)
#### Context
Your application needs to automatically scale based on CPU utilization.
#### Task
Please complete the following:
- Create a deployment named scalable-app in the autoscale namespace with 1 replica
- Use the nginx image
- Set container resource request: 100m CPU
- Create a HorizontalPodAutoscaler targeting the deployment with:
  - Target CPU utilization: 50%
  - Min replicas: 1
  - Max replicas: 5
- Document the HPA configuration in /opt/KDHPA00101/scaling.txt
Note: Actual scaling behavior depends on metrics-server being installed. If not available, focus on correct HPA configuration.

### Question 17 (6)
#### Context
You need to expose multiple applications through a single load balancer using path-based routing.
#### Task
Please complete the following:
- Create a deployment named app1 in the ingress-test namespace with 2 replicas using the nginxdemos/hello image
- Create a ClusterIP service named app1-service exposing port 80
- Create a deployment named app2 in the ingress-test namespace with 2 replicas using the nginxdemos/hello image
- Create a ClusterIP service named app2-service exposing port 80
- Create an Ingress named path-ingress with:
  - Host: test.example.com
  - Path /app1 routes to app1-service:80
  - Path /app2 routes to app2-service:80

### Question 18 (5)
#### Context
Your application needs HTTPS access with TLS termination at the Ingress.
#### Task
Please complete the following:
- A TLS Secret named tls-secret has been created in the ingress-test namespace (pre-configured)
- Create an Ingress named secure-ingress in the ingress-test namespace with:
  - Host: secure.example.com
  - TLS configuration using tls-secret
  - Route all paths to app1-service from Question 17 on port 80

### Question 19 (7)
#### Context
A deployment has multiple issues preventing it from running successfully. You need to identify and fix all problems.
#### Task
Please complete the following:
- A deployment named broken-app in the troubleshoot2 namespace has been created but pods are not running
- The deployment has multiple issues including:
  - Incorrect image tag
  - Missing required ConfigMap
  - Insufficient memory limit causing OOMKill
  - Incorrect liveness probe configuration
- Identify ALL issues and fix them
- Document each issue you found in /opt/KDTROUBLE00101/issues.txt (one issue per line)
- The deployment should have 2/2 replicas running when complete

### Question 20 (8)
#### Context
You need to extract specific information from the cluster using kubectl and JSONPath queries.
#### Task
Please complete the following:
- Write all node names sorted alphabetically to /opt/KDCLI00101/node-info.txt (one per line)
- Write all pods in namespace resource-check with their CPU requests to /opt/KDCLI00101/pod-resources.txt in format "podname: CPUrequest" (one per line)
- Write names of all pods across all namespaces that have a priorityClassName set to /opt/KDCLI00101/high-priority.txt (one per line)
- Write all services with type=NodePort to /opt/KDCLI00101/service-endpoints.txt in JSON format showing name, namespace, and nodePort values
