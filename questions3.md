### Question 1 (5)
#### Context
Your application requires a database connection check before starting. The main application container should only start after confirming the database service is reachable.
#### Task
Please complete the following in the init-basic namespace (already created):
- Create a pod named app-with-init
- Add an init container named db-check using the busybox image that runs: sh -c "until nslookup db-service.init-basic.svc.cluster.local; do echo waiting for db; sleep 2; done"
- The main container should use the nginx image and be named app
- The init container must complete successfully before the main container starts
- A service named db-service has been pre-created in the namespace

### Question 2 (5)
#### Context
Your application requires a multi-step initialization process: first downloading a configuration file, then validating it, before the main application can start.
#### Task
Please complete the following in the init-multi namespace (already created):
- Create a pod named multi-init-pod with the following containers:
- Init container 1 (name: download) using busybox image: write "config_version=1.0" to /work-dir/config.txt
- Init container 2 (name: validate) using busybox image: check that /work-dir/config.txt contains "config_version" and exit 0 if valid
- Main container (name: app) using nginx image that mounts the shared volume at /etc/app-config
- Use an emptyDir volume named work-dir shared between all containers

### Question 3 (4)
#### Context
Security compliance requires that containers run as a specific non-root user with defined group permissions.
#### Task
Please complete the following in the security-user namespace (already created):
- Create a pod named secure-pod using the busybox image with command: sh -c "id && sleep 3600"
- Configure the pod security context with:
  - runAsUser: 1000
  - runAsGroup: 3000
  - fsGroup: 2000
- Write the output of the id command to /opt/KDSEC00101/user-info.txt after the pod is running

### Question 4 (6)
#### Context
A network application requires the NET_BIND_SERVICE capability to bind to privileged ports, but for security reasons all other capabilities should be dropped.
#### Task
Please complete the following in the security-caps namespace (already created):
- Create a pod named cap-pod using the nginx image
- Configure the container security context to:
  - Drop ALL capabilities
  - Add only the NET_BIND_SERVICE capability
- The pod must be running successfully
- Write the effective capabilities to /opt/KDSEC00201/capabilities.txt (you can exec into the pod and cat /proc/1/status | grep Cap)

### Question 5 (5)
#### Context
Your frontend application pods should preferably be scheduled on the same nodes as cache pods for reduced latency.
#### Task
Please complete the following in the affinity namespace (already created):
- Cache pods with label app=cache are already running in the namespace
- Create a deployment named frontend with 2 replicas using the nginx image
- Configure podAffinity with preferredDuringSchedulingIgnoredDuringExecution to prefer nodes running pods with label app=cache
- The topologyKey should be kubernetes.io/hostname
- Verify the frontend pods are scheduled (they should run even if no cache pods exist, but prefer cache pod nodes)

### Question 6 (6)
#### Context
Your database replicas must be spread across different nodes to ensure high availability. No two database pods should run on the same node.
#### Task
Please complete the following in the anti-affinity namespace (already created):
- Create a deployment named db-spread with 3 replicas using the nginx image
- Add label app=database to the pod template
- Configure podAntiAffinity with requiredDuringSchedulingIgnoredDuringExecution
- The anti-affinity rule should prevent pods with label app=database from being on the same node (topologyKey: kubernetes.io/hostname)
- If running on a single-node cluster, document in /opt/KDAFF00201/observations.txt why only 1 pod can be scheduled

### Question 7 (4)
#### Context
Your application has a slow startup process that takes up to 60 seconds to initialize. During this time, the liveness probe should not kill the container.
#### Task
Please complete the following in the startup-probe namespace (already created):
- Create a pod named slow-start using the nginx image
- Configure a startupProbe with:
  - httpGet on path / and port 80
  - failureThreshold: 30
  - periodSeconds: 2
- Configure a livenessProbe with:
  - httpGet on path / and port 80
  - periodSeconds: 10
- The startup probe gives the app 60 seconds to start (30 * 2s) before liveness checks begin

### Question 8 (5)
#### Context
Your production deployment needs to maintain minimum availability during voluntary disruptions like node maintenance.
#### Task
Please complete the following in the pdb namespace (already created):
- A deployment named critical-app with 3 replicas is already running with label app=critical
- Create a PodDisruptionBudget named critical-pdb
- Configure it to ensure at least 2 pods are always available (minAvailable: 2)
- The PDB should select pods with label app=critical
- Document in /opt/KDPDB00101/pdb-status.txt the output of: kubectl get pdb critical-pdb -n pdb

### Question 9 (5)
#### Context
Critical system pods should have higher scheduling priority and can preempt lower-priority pods when resources are scarce.
#### Task
Please complete the following:
- Create a PriorityClass named high-priority with value 1000000 and globalDefault: false
- Create a PriorityClass named low-priority with value 100 and globalDefault: false
- In the priority namespace (already created), create a pod named critical-pod using nginx image with priorityClassName: high-priority
- Write the priority class values to /opt/KDPRI00101/priorities.txt in format: "high-priority: 1000000\nlow-priority: 100"

### Question 10 (5)
#### Context
Your application needs access to configuration from multiple sources (ConfigMap, Secret, and pod metadata) in a single directory.
#### Task
Please complete the following in the projected namespace (already created):
- A ConfigMap named app-config with key config.yaml containing "setting: value1" exists
- A Secret named app-secret with key credentials containing "password123" exists
- Create a pod named projected-pod using nginx image
- Configure a projected volume that combines:
  - The ConfigMap app-config
  - The Secret app-secret
  - downwardAPI exposing the pod's labels as a file named labels
- Mount the projected volume at /etc/projected

### Question 11 (4)
#### Context
Your application needs fast temporary storage backed by memory (tmpfs) with a size limit to prevent memory exhaustion.
#### Task
Please complete the following in the emptydir namespace (already created):
- Create a pod named memory-pod using busybox image with command: sh -c "dd if=/dev/zero of=/cache/testfile bs=1M count=32 && sleep 3600"
- Configure an emptyDir volume with:
  - medium: Memory
  - sizeLimit: 64Mi
- Mount the volume at /cache
- The pod should run successfully (32MB write to 64MB limit)

### Question 12 (6)
#### Context
A production pod is misbehaving but you cannot restart it. You need to debug it using an ephemeral debug container.
#### Task
Please complete the following in the debug namespace (already created):
- A pod named target-pod is running (nginx container without shell utilities)
- Use kubectl debug to attach an ephemeral container to target-pod:
  - Container name: debugger
  - Image: busybox
  - The container should share the process namespace with the target
- Alternatively, create a copy of the pod with a debug container if ephemeral containers are not supported
- Write the command you used to /opt/KDEPH00101/debug-command.txt
- Write the output of ps aux (or similar) from inside the debug container to /opt/KDEPH00101/process-list.txt

### Question 13 (5)
#### Context
You need to implement a canary deployment strategy where 25% of traffic goes to a new version while 75% goes to the stable version.
#### Task
Please complete the following in the canary namespace (already created):
- Create a deployment named app-stable with 3 replicas using nginx:1.24 image
- Add labels: app=myapp, version=stable to the pod template
- Create a deployment named app-canary with 1 replica using nginx:1.25 image
- Add labels: app=myapp, version=canary to the pod template
- Create a Service named myapp-service that routes to ALL pods with label app=myapp (both stable and canary)
- The service should expose port 80

### Question 14 (5)
#### Context
Users are reporting that a service is not reachable. The pods appear to be running but traffic is not being routed correctly.
#### Task
Please complete the following in the svc-debug namespace (already created):
- A deployment named web-app and a service named web-service exist but the service has no endpoints
- Investigate and fix the issue (hint: label selector mismatch)
- Document the issue you found in /opt/KDSVC00101/issue.txt
- Verify the service has endpoints after the fix
- Write the output of kubectl get endpoints web-service -n svc-debug to /opt/KDSVC00101/endpoints.txt

### Question 15 (7)
#### Context
You are implementing network segmentation for a three-tier application (frontend, backend, database). Each tier should only communicate with adjacent tiers.
#### Task
Please complete the following in the netpol-tiers namespace (already created):
- Pods with labels tier=frontend, tier=backend, and tier=database already exist
- Create a NetworkPolicy named frontend-policy that:
  - Applies to pods with tier=frontend
  - Allows ingress from any source (external traffic)
  - Allows egress only to pods with tier=backend
- Create a NetworkPolicy named backend-policy that:
  - Applies to pods with tier=backend
  - Allows ingress only from pods with tier=frontend
  - Allows egress only to pods with tier=database
- Create a NetworkPolicy named database-policy that:
  - Applies to pods with tier=database
  - Allows ingress only from pods with tier=backend
  - Denies all egress

### Question 16 (4)
#### Context
Your legacy application cannot handle multiple versions running simultaneously during updates and requires all old pods to terminate before new ones start.
#### Task
Please complete the following in the recreate namespace (already created):
- A deployment named legacy-app exists with RollingUpdate strategy
- Update the deployment to use Recreate strategy instead
- Update the image from nginx:1.24 to nginx:1.25
- Document the behavior you observed during the update in /opt/KDDEP00101/update-behavior.txt (all pods terminated before new ones started)

### Question 17 (5)
#### Context
A pod is in a CrashLoopBackOff state due to misconfigured probes. The application starts slowly but the probes are killing it before it's ready.
#### Task
Please complete the following in the probe-fix namespace (already created):
- A pod named broken-probe exists but keeps restarting
- Investigate the probe configuration using kubectl describe
- Fix the probe configuration so the pod runs successfully
- The application needs at least 30 seconds to start
- Document what was wrong and how you fixed it in /opt/KDCOMB00101/fix-description.txt

### Question 18 (7)
#### Context
A deployment has multiple configuration issues preventing pods from running. You need to identify and fix ALL issues.
#### Task
Please complete the following in the multi-debug namespace (already created):
- A deployment named buggy-app is failing to run
- The deployment has at least 4 different issues:
  - Image pull error (wrong image name/tag)
  - Security context preventing container from running
  - Resource limits too restrictive (OOMKilled)
  - Missing ConfigMap volume mount
- Fix ALL issues in the deployment
- Document each issue you found (one per line) in /opt/KDDEBUG00101/issues-found.txt
- The deployment should have 2/2 replicas running when complete

### Question 19 (4)
#### Context
You need to generate custom reports showing pod information in a specific format for monitoring purposes.
#### Task
Please complete the following:
- Write all pods in the report namespace to /opt/KDCLI00201/pod-report.txt using custom-columns format showing: NAME, NODE, IP, STATUS (column headers required)
- Write all pods across ALL namespaces that have restartCount > 0 to /opt/KDCLI00201/restarts.txt showing: NAMESPACE, NAME, RESTARTS (use jsonpath or custom-columns)
- Write all nodes with their allocatable CPU and memory to /opt/KDCLI00201/node-capacity.txt in format: "nodename: cpu=X, memory=Y"

### Question 20 (8)
#### Context
Deploy a complete, production-ready application with all recommended Kubernetes best practices.
#### Task
Please complete the following in the production namespace (already created):
- Create a deployment named production-app with 3 replicas using nginx image
- The deployment must include:
  - An init container (name: init-check) that verifies a ConfigMap named app-config exists
  - Security context: runAsNonRoot: true, runAsUser: 1000
  - Resource requests: cpu=100m, memory=128Mi
  - Resource limits: cpu=200m, memory=256Mi
  - startupProbe: httpGet on / port 80, failureThreshold=30, periodSeconds=2
  - livenessProbe: httpGet on / port 80, periodSeconds=10
  - readinessProbe: httpGet on / port 80, periodSeconds=5
- Create the ConfigMap app-config with key status=ready
- Create a PodDisruptionBudget named production-pdb with minAvailable: 2
- Create a Service named production-service of type ClusterIP exposing port 80

Note: The nginx image runs as root by default. You may need to use an image that supports non-root (like nginxinc/nginx-unprivileged) or adjust the security context accordingly.
