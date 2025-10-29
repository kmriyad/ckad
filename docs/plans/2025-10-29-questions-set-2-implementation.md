# CKAD Questions Set 2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create 20 CKAD practice questions covering advanced topics (DaemonSets, StatefulSets, RBAC, Jobs, resource management, Ingress, troubleshooting) with automated setup and evaluation scripts.

**Architecture:** Three-file system matching existing Set 1 pattern: questions2.md for question content, setup2.sh for environment preparation, evaluate2.sh for automated grading.

**Tech Stack:** Markdown, Bash, Kubernetes, kubectl

---

## Task 1: Create questions2.md structure

**Files:**
- Create: `questions2.md`

**Step 1: Create questions2.md with Section 1 (DaemonSets & Node Scheduling)**

Create the file with Questions 1-3:

```markdown
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
```

**Step 2: Add Section 2 (StatefulSets) to questions2.md**

Append Questions 4-6:

```markdown
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
```

**Step 3: Add Section 3 (RBAC) to questions2.md**

Append Questions 7-10:

```markdown
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
```

**Step 4: Add Section 4 (Jobs) to questions2.md**

Append Questions 11-13:

```markdown
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
```

**Step 5: Add Section 5 (Resource Management) to questions2.md**

Append Questions 14-16:

```markdown
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
```

**Step 6: Add Section 6 (Ingress) to questions2.md**

Append Questions 17-18:

```markdown
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
```

**Step 7: Add Section 7 (Advanced Troubleshooting) to questions2.md**

Append Questions 19-20:

```markdown
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
```

**Step 8: Commit questions2.md**

```bash
git add questions2.md
git commit -m "Add questions2.md with 20 CKAD practice questions

Questions cover advanced topics:
- DaemonSets and node scheduling (Q1-3)
- StatefulSets with persistent storage (Q4-6)
- RBAC roles and permissions (Q7-10)
- Jobs and parallelism (Q11-13)
- Resource quotas and limits (Q14-16)
- Ingress and TLS (Q17-18)
- Advanced troubleshooting and kubectl (Q19-20)

Total: 100 points

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 2: Create setup2.sh structure and Questions 1-3 setup

**Files:**
- Create: `scripts/setup2.sh`

**Step 1: Create setup2.sh with header and Questions 1-3 setup**

```bash
#!/usr/bin/env bash

########################################
# CKAD Exam Simulation Setup Script - Set 2
# This script sets up the environment for questions in questions2.md
# It creates necessary directories, files, and Kubernetes resources.
#########################################

# Setup for Question 1 starts
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'logging' created for Question 1"
# Setup for Question 1 ends

# Setup for Question 2 starts

# Get the first available node (worker node if available, otherwise control-plane)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Apply taint to the node
kubectl taint node "$NODE_NAME" workload=special:NoSchedule --overwrite

echo "Taint 'workload=special:NoSchedule' applied to node $NODE_NAME for Question 2"
# Setup for Question 2 ends

# Setup for Question 3 starts

# Label at least one node with disktype=ssd
# Use the same node or first available node
kubectl label node "$NODE_NAME" disktype=ssd --overwrite

echo "Label 'disktype=ssd' applied to node $NODE_NAME for Question 3"
# Setup for Question 3 ends
```

**Step 2: Add Questions 4-6 setup (StatefulSets)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 4 starts
kubectl create namespace stateful --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'stateful' created for Questions 4-6"
# Setup for Question 4 ends

# Setup for Question 5 starts
# Namespace already created in Q4
# No additional setup needed
# Setup for Question 5 ends

# Setup for Question 6 starts
mkdir -p /opt/KDST00301
touch /opt/KDST00301/observations.txt

echo "Created /opt/KDST00301/observations.txt for Question 6"
# Setup for Question 6 ends
```

**Step 3: Add Questions 7-10 setup (RBAC)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 7 starts
kubectl create namespace rbac-test --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'rbac-test' created for Question 7"
# Setup for Question 7 ends

# Setup for Question 8 starts
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'monitoring' created for Question 8"
# Setup for Question 8 ends

# Setup for Question 9 starts
kubectl create namespace secure --dry-run=client -o yaml | kubectl apply -f -

# Create test ConfigMap and Secret for verification
kubectl create configmap test-config --from-literal=key=value -n secure
kubectl create secret generic test-secret --from-literal=password=secret123 -n secure

mkdir -p /opt/KDRBAC00301
touch /opt/KDRBAC00301/test-results.txt

echo "Namespace 'secure' created with test ConfigMap and Secret for Question 9"
echo "Created /opt/KDRBAC00301/test-results.txt"
# Setup for Question 9 ends

# Setup for Question 10 starts
kubectl create namespace debug --dry-run=client -o yaml | kubectl apply -f -

# Create ServiceAccount
kubectl create serviceaccount app-service-account -n debug

# Create a pod that will fail due to lack of permissions
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-broken
  namespace: debug
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: bitnami/kubectl:latest
    command: ["sh", "-c"]
    args:
      - |
        while true; do
          kubectl create configmap test-cm --from-literal=test=value -n debug || echo "Permission denied"
          sleep 10
        done
EOF

echo "Namespace 'debug' created with broken RBAC scenario for Question 10"
# Setup for Question 10 ends
```

**Step 4: Add Questions 11-13 setup (Jobs)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 11 starts
kubectl create namespace batch --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /opt/KDJOB00101
touch /opt/KDJOB00101/status.txt

echo "Namespace 'batch' created for Questions 11-13"
echo "Created /opt/KDJOB00101/status.txt"
# Setup for Question 11 ends

# Setup for Question 12 starts
# Namespace already created in Q11
# Setup for Question 12 ends

# Setup for Question 13 starts
mkdir -p /opt/KDJOB00301
touch /opt/KDJOB00301/behavior.txt

echo "Created /opt/KDJOB00301/behavior.txt"
# Setup for Question 13 ends
```

**Step 5: Add Questions 14-16 setup (Resource Management)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 14 starts
mkdir -p /opt/KDRES00101
touch /opt/KDRES00101/quota-test.txt

echo "Created /opt/KDRES00101/quota-test.txt for Question 14"
# Setup for Question 14 ends

# Setup for Question 15 starts
# No files needed, students create everything
# Setup for Question 15 ends

# Setup for Question 16 starts
kubectl create namespace autoscale --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /opt/KDHPA00101
touch /opt/KDHPA00101/scaling.txt

echo "Namespace 'autoscale' created for Question 16"
echo "Created /opt/KDHPA00101/scaling.txt"
# Setup for Question 16 ends
```

**Step 6: Add Questions 17-18 setup (Ingress)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 17 starts
kubectl create namespace ingress-test --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'ingress-test' created for Questions 17-18"
# Setup for Question 17 ends

# Setup for Question 18 starts

# Create a self-signed TLS certificate for testing
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=secure.example.com/O=CKAD"

# Create TLS Secret
kubectl create secret tls tls-secret \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n ingress-test

# Clean up temporary files
rm -f /tmp/tls.key /tmp/tls.crt

echo "TLS Secret 'tls-secret' created for Question 18"
# Setup for Question 18 ends
```

**Step 7: Add Questions 19-20 setup (Advanced Troubleshooting)**

Append to `scripts/setup2.sh`:

```bash
# Setup for Question 19 starts
kubectl create namespace troubleshoot2 --dry-run=client -o yaml | kubectl apply -f -

# Create a broken deployment with multiple issues
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-wrong-name
  namespace: troubleshoot2
data:
  config: "value"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  namespace: troubleshoot2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-app
  template:
    metadata:
      labels:
        app: broken-app
    spec:
      containers:
      - name: app
        image: nginx:invalid-tag-999
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "32Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /wrong-health-path
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 5
        env:
        - name: CONFIG_DATA
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: config
EOF

mkdir -p /opt/KDTROUBLE00101
touch /opt/KDTROUBLE00101/issues.txt

echo "Namespace 'troubleshoot2' created with intentionally broken deployment for Question 19"
echo "Created /opt/KDTROUBLE00101/issues.txt"
# Setup for Question 19 ends

# Setup for Question 20 starts
kubectl create namespace resource-check --dry-run=client -o yaml | kubectl apply -f -

# Create pods with various configurations for kubectl exercises
kubectl run pod1 --image=nginx -n resource-check -- sleep 3600
kubectl set resources deployment pod1 -n resource-check --requests=cpu=100m
kubectl run pod2 --image=nginx -n resource-check -- sleep 3600
kubectl set resources deployment pod2 -n resource-check --requests=cpu=200m
kubectl run pod3 --image=nginx -n resource-check -- sleep 3600
kubectl set resources deployment pod3 -n resource-check --requests=cpu=150m

# Create a pod with priority class
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: priority-pod
  namespace: default
spec:
  priorityClassName: system-cluster-critical
  containers:
  - name: nginx
    image: nginx
EOF

# Create services with NodePort
kubectl create deployment svc-app1 --image=nginx -n default
kubectl expose deployment svc-app1 --type=NodePort --port=80 -n default

kubectl create deployment svc-app2 --image=nginx -n default
kubectl expose deployment svc-app2 --type=NodePort --port=80 -n default

mkdir -p /opt/KDCLI00101
touch /opt/KDCLI00101/node-info.txt
touch /opt/KDCLI00101/pod-resources.txt
touch /opt/KDCLI00101/high-priority.txt
touch /opt/KDCLI00101/service-endpoints.txt

echo "Namespace 'resource-check' created with test pods for Question 20"
echo "Created /opt/KDCLI00101/ output files"
# Setup for Question 20 ends

echo ""
echo "=========================================="
echo "Setup complete for CKAD Practice Set 2!"
echo "=========================================="
```

**Step 8: Make setup2.sh executable and commit**

```bash
chmod +x scripts/setup2.sh
git add scripts/setup2.sh
git commit -m "Add setup2.sh for CKAD questions set 2

Creates all required namespaces, files, and Kubernetes resources
for 20 questions covering advanced CKAD topics.

Setup includes:
- Node taints and labels for scheduling
- Namespaces for all questions
- RBAC test scenarios
- Broken deployments for troubleshooting
- TLS certificates for Ingress
- Test resources for kubectl exercises

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 3: Create evaluate2.sh with Questions 1-5 evaluation

**Files:**
- Create: `scripts/evaluate2.sh`

**Step 1: Create evaluate2.sh with header and scoring setup**

```bash
#!/usr/bin/env bash
########################################
# CKAD Practice Set 2 Evaluation Script
# This script evaluates student responses to questions in questions2.md
# It checks for the existence and correctness of Kubernetes resources.
#########################################

# Initialize score tracking
TOTAL_SCORE=0
MAX_SCORE=0
```

**Step 2: Add Question 1 evaluation (DaemonSet)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 1 starts

echo "=== Evaluating Question 1 ==="

# Check if DaemonSet exists
DS_NAME=$(kubectl get daemonset log-collector -n logging -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DS_NAME" ]]; then
    echo "❌ FAIL: DaemonSet 'log-collector' does not exist in namespace 'logging'"
    Q1_DS_SCORE=0
else
    echo "✅ PASS: DaemonSet 'log-collector' exists"
    Q1_DS_SCORE=1
fi

# Check image
DS_IMAGE=$(kubectl get daemonset log-collector -n logging -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

if [[ "$DS_IMAGE" == "fluentd:v1.14" ]]; then
    echo "✅ PASS: Correct image 'fluentd:v1.14'"
    Q1_IMAGE_SCORE=1
else
    echo "❌ FAIL: Incorrect image: $DS_IMAGE (expected: fluentd:v1.14)"
    Q1_IMAGE_SCORE=0
fi

# Check host path mount
HOST_PATH=$(kubectl get daemonset log-collector -n logging -o jsonpath='{.spec.template.spec.volumes[?(@.hostPath.path=="/var/log")].hostPath.path}' 2>/dev/null)
MOUNT_PATH=$(kubectl get daemonset log-collector -n logging -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/var/log")].mountPath}' 2>/dev/null)
READ_ONLY=$(kubectl get daemonset log-collector -n logging -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/var/log")].readOnly}' 2>/dev/null)

if [[ "$HOST_PATH" == "/var/log" ]] && [[ "$MOUNT_PATH" == "/var/log" ]] && [[ "$READ_ONLY" == "true" ]]; then
    echo "✅ PASS: Host path /var/log mounted correctly as read-only"
    Q1_MOUNT_SCORE=1
else
    echo "❌ FAIL: Host path mount not configured correctly"
    Q1_MOUNT_SCORE=0
fi

# Check pod count matches node count
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
POD_COUNT=$(kubectl get pods -n logging -l app=log-collector --no-headers 2>/dev/null | wc -l | tr -d ' ')

if [[ "$POD_COUNT" -eq "$NODE_COUNT" ]]; then
    echo "✅ PASS: DaemonSet running on all $NODE_COUNT nodes"
    Q1_COUNT_SCORE=1
else
    echo "❌ FAIL: Pod count ($POD_COUNT) does not match node count ($NODE_COUNT)"
    Q1_COUNT_SCORE=0
fi

Q1_TOTAL=$((Q1_DS_SCORE + Q1_IMAGE_SCORE + Q1_MOUNT_SCORE + Q1_COUNT_SCORE))
echo "Question 1 Score: $Q1_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q1_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 1 ends
```

**Step 3: Add Question 2 evaluation (Taints and Tolerations)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 2 starts

echo "=== Evaluating Question 2 ==="

# Check if pod exists
POD_NAME=$(kubectl get pod special-app -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod special-app -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'special-app' does not exist"
    Q2_POD_SCORE=0
    Q2_TOLERATION_SCORE=0
    Q2_NODE_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'special-app' exists but is not running (status: $POD_STATUS)"
    Q2_POD_SCORE=0
    Q2_TOLERATION_SCORE=0
    Q2_NODE_SCORE=0
else
    echo "✅ PASS: Pod 'special-app' is running"
    Q2_POD_SCORE=1

    # Check toleration
    TOLERATION=$(kubectl get pod special-app -o jsonpath='{.spec.tolerations[?(@.key=="workload")].effect}' 2>/dev/null)

    if [[ "$TOLERATION" == "NoSchedule" ]]; then
        echo "✅ PASS: Pod has correct toleration for workload=special:NoSchedule"
        Q2_TOLERATION_SCORE=2
    else
        echo "❌ FAIL: Pod does not have correct toleration"
        Q2_TOLERATION_SCORE=0
    fi

    # Check if pod is on tainted node
    POD_NODE=$(kubectl get pod special-app -o jsonpath='{.spec.nodeName}' 2>/dev/null)
    TAINTED_NODE=$(kubectl get nodes -o jsonpath='{.items[?(@.spec.taints[*].key=="workload")].metadata.name}' 2>/dev/null | awk '{print $1}')

    if [[ "$POD_NODE" == "$TAINTED_NODE" ]]; then
        echo "✅ PASS: Pod scheduled on tainted node $TAINTED_NODE"
        Q2_NODE_SCORE=1
    else
        echo "❌ FAIL: Pod not scheduled on tainted node (pod on: $POD_NODE, tainted node: $TAINTED_NODE)"
        Q2_NODE_SCORE=0
    fi
fi

Q2_TOTAL=$((Q2_POD_SCORE + Q2_TOLERATION_SCORE + Q2_NODE_SCORE))
echo "Question 2 Score: $Q2_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q2_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 2 ends
```

**Step 4: Add Question 3 evaluation (Node Affinity)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 3 starts

echo "=== Evaluating Question 3 ==="

# Check if deployment exists
DEPLOY_NAME=$(kubectl get deployment fast-app -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOY_NAME" ]]; then
    echo "❌ FAIL: Deployment 'fast-app' does not exist"
    Q3_DEPLOY_SCORE=0
    Q3_REPLICAS_SCORE=0
    Q3_AFFINITY_SCORE=0
    Q3_PLACEMENT_SCORE=0
else
    echo "✅ PASS: Deployment 'fast-app' exists"
    Q3_DEPLOY_SCORE=1

    # Check replicas
    REPLICAS=$(kubectl get deployment fast-app -o jsonpath='{.spec.replicas}' 2>/dev/null)
    READY_REPLICAS=$(kubectl get deployment fast-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)

    if [[ "$REPLICAS" == "2" ]] && [[ "$READY_REPLICAS" == "2" ]]; then
        echo "✅ PASS: Deployment has 2 replicas and all are ready"
        Q3_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: Deployment replicas incorrect (expected: 2, actual: $REPLICAS, ready: $READY_REPLICAS)"
        Q3_REPLICAS_SCORE=0
    fi

    # Check node affinity
    AFFINITY_KEY=$(kubectl get deployment fast-app -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key}' 2>/dev/null)
    AFFINITY_VALUE=$(kubectl get deployment fast-app -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}' 2>/dev/null)

    if [[ "$AFFINITY_KEY" == "disktype" ]] && [[ "$AFFINITY_VALUE" == "ssd" ]]; then
        echo "✅ PASS: Node affinity configured for disktype=ssd"
        Q3_AFFINITY_SCORE=1
    else
        echo "❌ FAIL: Node affinity not configured correctly"
        Q3_AFFINITY_SCORE=0
    fi

    # Check all pods on labeled nodes
    PODS_ON_LABELED_NODES=$(kubectl get pods -l app=fast-app -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' 2>/dev/null | while read node; do kubectl get node "$node" -o jsonpath='{.metadata.labels.disktype}'; echo; done | grep -c "ssd")
    TOTAL_PODS=$(kubectl get pods -l app=fast-app --no-headers 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$PODS_ON_LABELED_NODES" == "$TOTAL_PODS" ]] && [[ "$TOTAL_PODS" == "2" ]]; then
        echo "✅ PASS: All pods scheduled on nodes with disktype=ssd label"
        Q3_PLACEMENT_SCORE=1
    else
        echo "❌ FAIL: Not all pods on labeled nodes"
        Q3_PLACEMENT_SCORE=0
    fi
fi

Q3_TOTAL=$((Q3_DEPLOY_SCORE + Q3_REPLICAS_SCORE + Q3_AFFINITY_SCORE + Q3_PLACEMENT_SCORE))
echo "Question 3 Score: $Q3_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q3_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 3 ends
```

**Step 5: Add Question 4 evaluation (StatefulSet with Headless Service)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 4 starts

echo "=== Evaluating Question 4 ==="

# Check headless service
SVC_NAME=$(kubectl get service db-service -n stateful -o jsonpath='{.metadata.name}' 2>/dev/null)
CLUSTER_IP=$(kubectl get service db-service -n stateful -o jsonpath='{.spec.clusterIP}' 2>/dev/null)

if [[ -z "$SVC_NAME" ]]; then
    echo "❌ FAIL: Service 'db-service' does not exist in namespace 'stateful'"
    Q4_SVC_SCORE=0
elif [[ "$CLUSTER_IP" != "None" ]]; then
    echo "❌ FAIL: Service 'db-service' is not headless (clusterIP should be None)"
    Q4_SVC_SCORE=0
else
    echo "✅ PASS: Headless service 'db-service' exists"
    Q4_SVC_SCORE=1
fi

# Check StatefulSet
STS_NAME=$(kubectl get statefulset db -n stateful -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$STS_NAME" ]]; then
    echo "❌ FAIL: StatefulSet 'db' does not exist in namespace 'stateful'"
    Q4_STS_SCORE=0
    Q4_REPLICAS_SCORE=0
    Q4_SERVICE_NAME_SCORE=0
    Q4_DNS_SCORE=0
else
    echo "✅ PASS: StatefulSet 'db' exists"
    Q4_STS_SCORE=1

    # Check replicas
    STS_REPLICAS=$(kubectl get statefulset db -n stateful -o jsonpath='{.spec.replicas}' 2>/dev/null)
    READY_REPLICAS=$(kubectl get statefulset db -n stateful -o jsonpath='{.status.readyReplicas}' 2>/dev/null)

    if [[ "$STS_REPLICAS" == "3" ]] && [[ "$READY_REPLICAS" == "3" ]]; then
        echo "✅ PASS: StatefulSet has 3 replicas and all are ready"
        Q4_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: StatefulSet replicas incorrect (expected: 3, actual: $STS_REPLICAS, ready: $READY_REPLICAS)"
        Q4_REPLICAS_SCORE=0
    fi

    # Check serviceName
    SERVICE_NAME=$(kubectl get statefulset db -n stateful -o jsonpath='{.spec.serviceName}' 2>/dev/null)

    if [[ "$SERVICE_NAME" == "db-service" ]]; then
        echo "✅ PASS: StatefulSet uses service 'db-service'"
        Q4_SERVICE_NAME_SCORE=1
    else
        echo "❌ FAIL: StatefulSet serviceName incorrect (expected: db-service, actual: $SERVICE_NAME)"
        Q4_SERVICE_NAME_SCORE=0
    fi

    # Check stable pod names
    POD_NAMES=$(kubectl get pods -n stateful -l app=db -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort)
    EXPECTED_NAMES=$(echo -e "db-0\ndb-1\ndb-2")

    if [[ "$POD_NAMES" == "$EXPECTED_NAMES" ]]; then
        echo "✅ PASS: StatefulSet pods have stable names (db-0, db-1, db-2)"
        Q4_DNS_SCORE=1
    else
        echo "❌ FAIL: StatefulSet pod names incorrect"
        Q4_DNS_SCORE=0
    fi
fi

Q4_TOTAL=$((Q4_SVC_SCORE + Q4_STS_SCORE + Q4_REPLICAS_SCORE + Q4_SERVICE_NAME_SCORE + Q4_DNS_SCORE))
echo "Question 4 Score: $Q4_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q4_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 4 ends
```

**Step 6: Add Question 5 evaluation (StatefulSet with Storage)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 5 starts

echo "=== Evaluating Question 5 ==="

# Check StatefulSet
STS_NAME=$(kubectl get statefulset data-app -n stateful -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$STS_NAME" ]]; then
    echo "❌ FAIL: StatefulSet 'data-app' does not exist in namespace 'stateful'"
    Q5_STS_SCORE=0
    Q5_VCT_SCORE=0
    Q5_PVC_SCORE=0
    Q5_DATA_SCORE=0
else
    echo "✅ PASS: StatefulSet 'data-app' exists"
    Q5_STS_SCORE=1

    # Check volumeClaimTemplates
    VCT_EXISTS=$(kubectl get statefulset data-app -n stateful -o jsonpath='{.spec.volumeClaimTemplates}' 2>/dev/null)
    STORAGE_REQUEST=$(kubectl get statefulset data-app -n stateful -o jsonpath='{.spec.volumeClaimTemplates[0].spec.resources.requests.storage}' 2>/dev/null)

    if [[ -n "$VCT_EXISTS" ]] && [[ "$STORAGE_REQUEST" == "1Gi" ]]; then
        echo "✅ PASS: StatefulSet has volumeClaimTemplates requesting 1Gi"
        Q5_VCT_SCORE=2
    else
        echo "❌ FAIL: volumeClaimTemplates not configured correctly"
        Q5_VCT_SCORE=0
    fi

    # Check PVCs created
    PVC_COUNT=$(kubectl get pvc -n stateful -l app=data-app 2>/dev/null | grep -c "data-app" || echo "0")

    if [[ "$PVC_COUNT" -ge "2" ]]; then
        echo "✅ PASS: PVCs created for StatefulSet pods"
        Q5_PVC_SCORE=1
    else
        echo "❌ FAIL: Expected at least 2 PVCs, found $PVC_COUNT"
        Q5_PVC_SCORE=0
    fi

    # Check data persistence (pods have written their hostname)
    POD_0_DATA=$(kubectl exec data-app-0 -n stateful -- cat /data/id.txt 2>/dev/null)

    if [[ "$POD_0_DATA" == "data-app-0" ]]; then
        echo "✅ PASS: Data persisted correctly"
        Q5_DATA_SCORE=1
    else
        echo "❌ FAIL: Data not persisted correctly"
        Q5_DATA_SCORE=0
    fi
fi

Q5_TOTAL=$((Q5_STS_SCORE + Q5_VCT_SCORE + Q5_PVC_SCORE + Q5_DATA_SCORE))
echo "Question 5 Score: $Q5_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q5_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 5 ends
```

**Step 7: Commit evaluate2.sh progress**

```bash
git add scripts/evaluate2.sh
git commit -m "Add evaluate2.sh with Questions 1-5 evaluation

Evaluation logic for:
- Q1: DaemonSet creation and configuration
- Q2: Taints and tolerations
- Q3: Node affinity
- Q4: StatefulSet with headless service
- Q5: StatefulSet with persistent storage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 4: Complete evaluate2.sh with Questions 6-10 (StatefulSets & RBAC)

**Files:**
- Modify: `scripts/evaluate2.sh`

**Step 1: Add Question 6 evaluation (StatefulSet Scaling)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 6 starts

echo "=== Evaluating Question 6 ==="

# Check StatefulSet replica count (should be scaled back to 3)
STS_REPLICAS=$(kubectl get statefulset db -n stateful -o jsonpath='{.spec.replicas}' 2>/dev/null)

if [[ "$STS_REPLICAS" == "3" ]]; then
    echo "✅ PASS: StatefulSet 'db' scaled to 3 replicas"
    Q6_SCALE_SCORE=2
else
    echo "❌ FAIL: StatefulSet not at correct replica count (expected: 3, actual: $STS_REPLICAS)"
    Q6_SCALE_SCORE=0
fi

# Check image updated
STS_IMAGE=$(kubectl get statefulset db -n stateful -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

if [[ "$STS_IMAGE" == "nginx:1.24" ]]; then
    echo "✅ PASS: StatefulSet image updated to nginx:1.24"
    Q6_IMAGE_SCORE=2
else
    echo "❌ FAIL: StatefulSet image not updated (expected: nginx:1.24, actual: $STS_IMAGE)"
    Q6_IMAGE_SCORE=0
fi

# Check observations file
OBS_FILE="/opt/KDST00301/observations.txt"

if [[ ! -f "$OBS_FILE" ]]; then
    echo "❌ FAIL: Observations file not found at $OBS_FILE"
    Q6_OBS_SCORE=0
elif [[ ! -s "$OBS_FILE" ]]; then
    echo "❌ FAIL: Observations file is empty"
    Q6_OBS_SCORE=0
else
    echo "✅ PASS: Observations file exists with content"
    Q6_OBS_SCORE=1
fi

Q6_TOTAL=$((Q6_SCALE_SCORE + Q6_IMAGE_SCORE + Q6_OBS_SCORE))
echo "Question 6 Score: $Q6_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q6_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 6 ends
```

**Step 2: Add Question 7 evaluation (Role and RoleBinding)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 7 starts

echo "=== Evaluating Question 7 ==="

# Check Role
ROLE_NAME=$(kubectl get role pod-reader -n rbac-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$ROLE_NAME" ]]; then
    echo "❌ FAIL: Role 'pod-reader' does not exist in namespace 'rbac-test'"
    Q7_ROLE_SCORE=0
else
    echo "✅ PASS: Role 'pod-reader' exists"

    # Check Role permissions
    VERBS=$(kubectl get role pod-reader -n rbac-test -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)

    if [[ "$VERBS" == *"get"* ]] && [[ "$VERBS" == *"list"* ]] && [[ "$VERBS" == *"watch"* ]]; then
        echo "✅ PASS: Role has correct permissions (get, list, watch)"
        Q7_ROLE_SCORE=1
    else
        echo "❌ FAIL: Role permissions incorrect"
        Q7_ROLE_SCORE=0
    fi
fi

# Check ServiceAccount
SA_NAME=$(kubectl get serviceaccount app-sa -n rbac-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$SA_NAME" == "app-sa" ]]; then
    echo "✅ PASS: ServiceAccount 'app-sa' exists"
    Q7_SA_SCORE=1
else
    echo "❌ FAIL: ServiceAccount 'app-sa' does not exist"
    Q7_SA_SCORE=0
fi

# Check RoleBinding
RB_NAME=$(kubectl get rolebinding read-pods -n rbac-test -o jsonpath='{.metadata.name}' 2>/dev/null)
RB_ROLE=$(kubectl get rolebinding read-pods -n rbac-test -o jsonpath='{.roleRef.name}' 2>/dev/null)
RB_SA=$(kubectl get rolebinding read-pods -n rbac-test -o jsonpath='{.subjects[0].name}' 2>/dev/null)

if [[ "$RB_NAME" == "read-pods" ]] && [[ "$RB_ROLE" == "pod-reader" ]] && [[ "$RB_SA" == "app-sa" ]]; then
    echo "✅ PASS: RoleBinding correctly binds Role to ServiceAccount"
    Q7_RB_SCORE=2
else
    echo "❌ FAIL: RoleBinding not configured correctly"
    Q7_RB_SCORE=0
fi

Q7_TOTAL=$((Q7_ROLE_SCORE + Q7_SA_SCORE + Q7_RB_SCORE))
echo "Question 7 Score: $Q7_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q7_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 7 ends
```

**Step 3: Add Question 8 evaluation (ClusterRole)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 8 starts

echo "=== Evaluating Question 8 ==="

# Check ClusterRole
CR_NAME=$(kubectl get clusterrole node-reader -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$CR_NAME" ]]; then
    echo "❌ FAIL: ClusterRole 'node-reader' does not exist"
    Q8_CR_SCORE=0
else
    echo "✅ PASS: ClusterRole 'node-reader' exists"

    # Check permissions
    VERBS=$(kubectl get clusterrole node-reader -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)
    RESOURCES=$(kubectl get clusterrole node-reader -o jsonpath='{.rules[0].resources[0]}' 2>/dev/null)

    if [[ "$VERBS" == *"get"* ]] && [[ "$VERBS" == *"list"* ]] && [[ "$RESOURCES" == "nodes" ]]; then
        echo "✅ PASS: ClusterRole has correct permissions for nodes"
        Q8_CR_SCORE=2
    else
        echo "❌ FAIL: ClusterRole permissions incorrect"
        Q8_CR_SCORE=0
    fi
fi

# Check ServiceAccount
SA_NAME=$(kubectl get serviceaccount monitor-sa -n monitoring -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$SA_NAME" == "monitor-sa" ]]; then
    echo "✅ PASS: ServiceAccount 'monitor-sa' exists in namespace 'monitoring'"
    Q8_SA_SCORE=1
else
    echo "❌ FAIL: ServiceAccount 'monitor-sa' does not exist"
    Q8_SA_SCORE=0
fi

# Check ClusterRoleBinding
CRB_NAME=$(kubectl get clusterrolebinding read-nodes -o jsonpath='{.metadata.name}' 2>/dev/null)
CRB_ROLE=$(kubectl get clusterrolebinding read-nodes -o jsonpath='{.roleRef.name}' 2>/dev/null)
CRB_SA=$(kubectl get clusterrolebinding read-nodes -o jsonpath='{.subjects[0].name}' 2>/dev/null)

if [[ "$CRB_NAME" == "read-nodes" ]] && [[ "$CRB_ROLE" == "node-reader" ]] && [[ "$CRB_SA" == "monitor-sa" ]]; then
    echo "✅ PASS: ClusterRoleBinding correctly configured"
    Q8_CRB_SCORE=2
else
    echo "❌ FAIL: ClusterRoleBinding not configured correctly"
    Q8_CRB_SCORE=0
fi

Q8_TOTAL=$((Q8_CR_SCORE + Q8_SA_SCORE + Q8_CRB_SCORE))
echo "Question 8 Score: $Q8_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q8_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 8 ends
```

**Step 4: Add Question 9 evaluation (Limited ServiceAccount)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 9 starts

echo "=== Evaluating Question 9 ==="

# Check ServiceAccount
SA_NAME=$(kubectl get serviceaccount limited-sa -n secure -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$SA_NAME" == "limited-sa" ]]; then
    echo "✅ PASS: ServiceAccount 'limited-sa' exists"
    Q9_SA_SCORE=1
else
    echo "❌ FAIL: ServiceAccount 'limited-sa' does not exist"
    Q9_SA_SCORE=0
fi

# Check Role
ROLE_NAME=$(kubectl get role configmap-reader -n secure -o jsonpath='{.metadata.name}' 2>/dev/null)
RESOURCES=$(kubectl get role configmap-reader -n secure -o jsonpath='{.rules[0].resources[0]}' 2>/dev/null)

if [[ "$ROLE_NAME" == "configmap-reader" ]] && [[ "$RESOURCES" == "configmaps" ]]; then
    echo "✅ PASS: Role 'configmap-reader' exists with correct resources"
    Q9_ROLE_SCORE=1
else
    echo "❌ FAIL: Role not configured correctly"
    Q9_ROLE_SCORE=0
fi

# Check RoleBinding
RB_NAME=$(kubectl get rolebinding read-configmaps -n secure -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$RB_NAME" == "read-configmaps" ]]; then
    echo "✅ PASS: RoleBinding 'read-configmaps' exists"
    Q9_RB_SCORE=1
else
    echo "❌ FAIL: RoleBinding does not exist"
    Q9_RB_SCORE=0
fi

# Check Pod
POD_NAME=$(kubectl get pod limited-pod -n secure -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_SA=$(kubectl get pod limited-pod -n secure -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)

if [[ "$POD_NAME" == "limited-pod" ]] && [[ "$POD_SA" == "limited-sa" ]]; then
    echo "✅ PASS: Pod 'limited-pod' uses ServiceAccount 'limited-sa'"
    Q9_POD_SCORE=2
else
    echo "❌ FAIL: Pod not configured correctly"
    Q9_POD_SCORE=0
fi

# Check test results file
TEST_FILE="/opt/KDRBAC00301/test-results.txt"

if [[ -f "$TEST_FILE" ]] && [[ -s "$TEST_FILE" ]]; then
    echo "✅ PASS: Test results file exists with content"
    Q9_TEST_SCORE=1
else
    echo "❌ FAIL: Test results file missing or empty"
    Q9_TEST_SCORE=0
fi

Q9_TOTAL=$((Q9_SA_SCORE + Q9_ROLE_SCORE + Q9_RB_SCORE + Q9_POD_SCORE + Q9_TEST_SCORE))
echo "Question 9 Score: $Q9_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q9_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))

# Evaluation for Question 9 ends
```

**Step 5: Add Question 10 evaluation (Debug RBAC)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 10 starts

echo "=== Evaluating Question 10 ==="

# Check if Role was created
ROLE_NAME=$(kubectl get role -n debug -o jsonpath='{.items[?(@.rules[*].resources[0]=="configmaps")].metadata.name}' 2>/dev/null)

if [[ -n "$ROLE_NAME" ]]; then
    echo "✅ PASS: Role created for ConfigMap permissions"

    # Check if Role has create permission
    VERBS=$(kubectl get role "$ROLE_NAME" -n debug -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)

    if [[ "$VERBS" == *"create"* ]]; then
        echo "✅ PASS: Role includes 'create' permission"
        Q10_ROLE_SCORE=2
    else
        echo "❌ FAIL: Role missing 'create' permission"
        Q10_ROLE_SCORE=0
    fi
else
    echo "❌ FAIL: No Role found with ConfigMap permissions"
    Q10_ROLE_SCORE=0
fi

# Check if RoleBinding exists connecting to app-service-account
RB_SA=$(kubectl get rolebinding -n debug -o jsonpath='{.items[?(@.subjects[0].name=="app-service-account")].metadata.name}' 2>/dev/null)

if [[ -n "$RB_SA" ]]; then
    echo "✅ PASS: RoleBinding connects Role to app-service-account"
    Q10_RB_SCORE=2
else
    echo "❌ FAIL: RoleBinding not configured correctly"
    Q10_RB_SCORE=0
fi

# Test if ServiceAccount can now create ConfigMaps
CAN_CREATE=$(kubectl auth can-i create configmaps --as=system:serviceaccount:debug:app-service-account -n debug 2>/dev/null)

if [[ "$CAN_CREATE" == "yes" ]]; then
    echo "✅ PASS: ServiceAccount can create ConfigMaps"
    Q10_TEST_SCORE=1
else
    echo "❌ FAIL: ServiceAccount still cannot create ConfigMaps"
    Q10_TEST_SCORE=0
fi

Q10_TOTAL=$((Q10_ROLE_SCORE + Q10_RB_SCORE + Q10_TEST_SCORE))
echo "Question 10 Score: $Q10_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q10_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 10 ends
```

**Step 6: Commit Questions 6-10 evaluation**

```bash
git add scripts/evaluate2.sh
git commit -m "Add Questions 6-10 evaluation to evaluate2.sh

Evaluation logic for:
- Q6: StatefulSet scaling and updates
- Q7: Role and RoleBinding
- Q8: ClusterRole and ClusterRoleBinding
- Q9: Limited ServiceAccount permissions
- Q10: Debug RBAC issue

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 5: Complete evaluate2.sh with Questions 11-20

**Files:**
- Modify: `scripts/evaluate2.sh`

**Step 1: Add Questions 11-13 evaluation (Jobs)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 11 starts

echo "=== Evaluating Question 11 ==="

JOB_NAME=$(kubectl get job data-processor -n batch -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$JOB_NAME" ]]; then
    echo "❌ FAIL: Job 'data-processor' does not exist"
    Q11_JOB_SCORE=0
    Q11_COMPLETION_SCORE=0
else
    echo "✅ PASS: Job 'data-processor' exists"
    Q11_JOB_SCORE=2

    # Check completion
    COMPLETIONS=$(kubectl get job data-processor -n batch -o jsonpath='{.status.succeeded}' 2>/dev/null)

    if [[ "$COMPLETIONS" == "1" ]]; then
        echo "✅ PASS: Job completed successfully"
        Q11_COMPLETION_SCORE=1
    else
        echo "❌ FAIL: Job has not completed successfully"
        Q11_COMPLETION_SCORE=0
    fi
fi

# Check status file
STATUS_FILE="/opt/KDJOB00101/status.txt"

if [[ -f "$STATUS_FILE" ]] && [[ -s "$STATUS_FILE" ]]; then
    echo "✅ PASS: Status file exists with content"
    Q11_FILE_SCORE=1
else
    echo "❌ FAIL: Status file missing or empty"
    Q11_FILE_SCORE=0
fi

Q11_TOTAL=$((Q11_JOB_SCORE + Q11_COMPLETION_SCORE + Q11_FILE_SCORE))
echo "Question 11 Score: $Q11_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q11_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 11 ends

# Evaluation for Question 12 starts

echo "=== Evaluating Question 12 ==="

JOB_NAME=$(kubectl get job parallel-processor -n batch -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$JOB_NAME" ]]; then
    echo "❌ FAIL: Job 'parallel-processor' does not exist"
    Q12_JOB_SCORE=0
    Q12_PARALLEL_SCORE=0
    Q12_COMPLETIONS_SCORE=0
else
    echo "✅ PASS: Job 'parallel-processor' exists"
    Q12_JOB_SCORE=1

    # Check parallelism
    PARALLELISM=$(kubectl get job parallel-processor -n batch -o jsonpath='{.spec.parallelism}' 2>/dev/null)

    if [[ "$PARALLELISM" == "3" ]]; then
        echo "✅ PASS: Job parallelism set to 3"
        Q12_PARALLEL_SCORE=1
    else
        echo "❌ FAIL: Job parallelism incorrect (expected: 3, actual: $PARALLELISM)"
        Q12_PARALLEL_SCORE=0
    fi

    # Check completions
    COMPLETIONS_SPEC=$(kubectl get job parallel-processor -n batch -o jsonpath='{.spec.completions}' 2>/dev/null)
    COMPLETIONS_STATUS=$(kubectl get job parallel-processor -n batch -o jsonpath='{.status.succeeded}' 2>/dev/null)

    if [[ "$COMPLETIONS_SPEC" == "9" ]]; then
        echo "✅ PASS: Job completions set to 9"

        if [[ "$COMPLETIONS_STATUS" == "9" ]]; then
            echo "✅ PASS: Job completed all 9 tasks"
            Q12_COMPLETIONS_SCORE=2
        else
            echo "⚠️  PARTIAL: Job configured but not yet complete ($COMPLETIONS_STATUS/9)"
            Q12_COMPLETIONS_SCORE=1
        fi
    else
        echo "❌ FAIL: Job completions incorrect (expected: 9, actual: $COMPLETIONS_SPEC)"
        Q12_COMPLETIONS_SCORE=0
    fi
fi

Q12_TOTAL=$((Q12_JOB_SCORE + Q12_PARALLEL_SCORE + Q12_COMPLETIONS_SCORE))
echo "Question 12 Score: $Q12_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q12_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 12 ends

# Evaluation for Question 13 starts

echo "=== Evaluating Question 13 ==="

JOB_NAME=$(kubectl get job timeout-job -n batch -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$JOB_NAME" ]]; then
    echo "❌ FAIL: Job 'timeout-job' does not exist"
    Q13_JOB_SCORE=0
    Q13_BACKOFF_SCORE=0
    Q13_DEADLINE_SCORE=0
else
    echo "✅ PASS: Job 'timeout-job' exists"
    Q13_JOB_SCORE=1

    # Check backoffLimit
    BACKOFF=$(kubectl get job timeout-job -n batch -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)

    if [[ "$BACKOFF" == "2" ]]; then
        echo "✅ PASS: backoffLimit set to 2"
        Q13_BACKOFF_SCORE=1
    else
        echo "❌ FAIL: backoffLimit incorrect (expected: 2, actual: $BACKOFF)"
        Q13_BACKOFF_SCORE=0
    fi

    # Check activeDeadlineSeconds
    DEADLINE=$(kubectl get job timeout-job -n batch -o jsonpath='{.spec.activeDeadlineSeconds}' 2>/dev/null)

    if [[ "$DEADLINE" == "30" ]]; then
        echo "✅ PASS: activeDeadlineSeconds set to 30"
        Q13_DEADLINE_SCORE=1
    else
        echo "❌ FAIL: activeDeadlineSeconds incorrect (expected: 30, actual: $DEADLINE)"
        Q13_DEADLINE_SCORE=0
    fi
fi

# Check behavior documentation
BEHAVIOR_FILE="/opt/KDJOB00301/behavior.txt"

if [[ -f "$BEHAVIOR_FILE" ]] && [[ -s "$BEHAVIOR_FILE" ]]; then
    echo "✅ PASS: Behavior documentation exists"
    Q13_DOC_SCORE=1
else
    echo "❌ FAIL: Behavior documentation missing or empty"
    Q13_DOC_SCORE=0
fi

Q13_TOTAL=$((Q13_JOB_SCORE + Q13_BACKOFF_SCORE + Q13_DEADLINE_SCORE + Q13_DOC_SCORE))
echo "Question 13 Score: $Q13_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q13_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 13 ends
```

**Step 2: Add Questions 14-16 evaluation (Resource Management)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 14 starts

echo "=== Evaluating Question 14 ==="

NS_EXISTS=$(kubectl get namespace quota-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS_EXISTS" == "quota-test" ]]; then
    echo "✅ PASS: Namespace 'quota-test' exists"
    Q14_NS_SCORE=1
else
    echo "❌ FAIL: Namespace 'quota-test' does not exist"
    Q14_NS_SCORE=0
fi

# Check ResourceQuota
QUOTA_NAME=$(kubectl get resourcequota -n quota-test -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -n "$QUOTA_NAME" ]]; then
    echo "✅ PASS: ResourceQuota exists in namespace"

    PODS_LIMIT=$(kubectl get resourcequota "$QUOTA_NAME" -n quota-test -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
    CPU_LIMIT=$(kubectl get resourcequota "$QUOTA_NAME" -n quota-test -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
    MEM_LIMIT=$(kubectl get resourcequota "$QUOTA_NAME" -n quota-test -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)

    if [[ "$PODS_LIMIT" == "3" ]] && [[ "$CPU_LIMIT" == "1" ]] && [[ "$MEM_LIMIT" == "1Gi" ]]; then
        echo "✅ PASS: ResourceQuota configured correctly"
        Q14_QUOTA_SCORE=2
    else
        echo "❌ FAIL: ResourceQuota limits incorrect"
        Q14_QUOTA_SCORE=0
    fi
else
    echo "❌ FAIL: No ResourceQuota found"
    Q14_QUOTA_SCORE=0
fi

# Check pods
POD_COUNT=$(kubectl get pods -n quota-test --no-headers 2>/dev/null | wc -l | tr -d ' ')

if [[ "$POD_COUNT" -ge "2" ]]; then
    echo "✅ PASS: At least 2 pods created within quota"
    Q14_PODS_SCORE=1
else
    echo "❌ FAIL: Not enough pods created"
    Q14_PODS_SCORE=0
fi

# Check documentation file
QUOTA_FILE="/opt/KDRES00101/quota-test.txt"

if [[ -f "$QUOTA_FILE" ]] && [[ -s "$QUOTA_FILE" ]]; then
    echo "✅ PASS: Quota test documentation exists"
    Q14_DOC_SCORE=1
else
    echo "❌ FAIL: Documentation missing or empty"
    Q14_DOC_SCORE=0
fi

Q14_TOTAL=$((Q14_NS_SCORE + Q14_QUOTA_SCORE + Q14_PODS_SCORE + Q14_DOC_SCORE))
echo "Question 14 Score: $Q14_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q14_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 14 ends

# Evaluation for Question 15 starts

echo "=== Evaluating Question 15 ==="

NS_EXISTS=$(kubectl get namespace limits-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS_EXISTS" == "limits-test" ]]; then
    echo "✅ PASS: Namespace 'limits-test' exists"
    Q15_NS_SCORE=1
else
    echo "❌ FAIL: Namespace 'limits-test' does not exist"
    Q15_NS_SCORE=0
fi

# Check LimitRange
LR_NAME=$(kubectl get limitrange -n limits-test -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -n "$LR_NAME" ]]; then
    echo "✅ PASS: LimitRange exists"

    DEF_REQ_CPU=$(kubectl get limitrange "$LR_NAME" -n limits-test -o jsonpath='{.spec.limits[0].defaultRequest.cpu}' 2>/dev/null)
    DEF_REQ_MEM=$(kubectl get limitrange "$LR_NAME" -n limits-test -o jsonpath='{.spec.limits[0].defaultRequest.memory}' 2>/dev/null)
    DEF_LIM_CPU=$(kubectl get limitrange "$LR_NAME" -n limits-test -o jsonpath='{.spec.limits[0].default.cpu}' 2>/dev/null)
    DEF_LIM_MEM=$(kubectl get limitrange "$LR_NAME" -n limits-test -o jsonpath='{.spec.limits[0].default.memory}' 2>/dev/null)

    if [[ "$DEF_REQ_CPU" == "100m" ]] && [[ "$DEF_REQ_MEM" == "128Mi" ]] && [[ "$DEF_LIM_CPU" == "200m" ]] && [[ "$DEF_LIM_MEM" == "256Mi" ]]; then
        echo "✅ PASS: LimitRange defaults configured correctly"
        Q15_LR_SCORE=2
    else
        echo "❌ FAIL: LimitRange defaults incorrect"
        Q15_LR_SCORE=0
    fi
else
    echo "❌ FAIL: No LimitRange found"
    Q15_LR_SCORE=0
fi

# Check pod with auto-applied defaults
POD_NAME=$(kubectl get pod test-pod -n limits-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$POD_NAME" == "test-pod" ]]; then
    POD_REQ_CPU=$(kubectl get pod test-pod -n limits-test -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
    POD_REQ_MEM=$(kubectl get pod test-pod -n limits-test -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)

    if [[ "$POD_REQ_CPU" == "100m" ]] && [[ "$POD_REQ_MEM" == "128Mi" ]]; then
        echo "✅ PASS: Pod has default resources auto-applied"
        Q15_POD_SCORE=2
    else
        echo "❌ FAIL: Pod does not have correct defaults"
        Q15_POD_SCORE=0
    fi
else
    echo "❌ FAIL: Pod 'test-pod' does not exist"
    Q15_POD_SCORE=0
fi

Q15_TOTAL=$((Q15_NS_SCORE + Q15_LR_SCORE + Q15_POD_SCORE))
echo "Question 15 Score: $Q15_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q15_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 15 ends

# Evaluation for Question 16 starts

echo "=== Evaluating Question 16 ==="

# Check deployment
DEPLOY_NAME=$(kubectl get deployment scalable-app -n autoscale -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$DEPLOY_NAME" == "scalable-app" ]]; then
    echo "✅ PASS: Deployment 'scalable-app' exists"

    # Check resource requests
    CPU_REQUEST=$(kubectl get deployment scalable-app -n autoscale -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)

    if [[ "$CPU_REQUEST" == "100m" ]]; then
        echo "✅ PASS: Deployment has CPU request of 100m"
        Q16_DEPLOY_SCORE=2
    else
        echo "❌ FAIL: Deployment CPU request incorrect"
        Q16_DEPLOY_SCORE=0
    fi
else
    echo "❌ FAIL: Deployment 'scalable-app' does not exist"
    Q16_DEPLOY_SCORE=0
fi

# Check HPA
HPA_NAME=$(kubectl get hpa -n autoscale -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -n "$HPA_NAME" ]]; then
    echo "✅ PASS: HPA exists"

    MIN_REPLICAS=$(kubectl get hpa "$HPA_NAME" -n autoscale -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
    MAX_REPLICAS=$(kubectl get hpa "$HPA_NAME" -n autoscale -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
    TARGET_CPU=$(kubectl get hpa "$HPA_NAME" -n autoscale -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)

    if [[ "$MIN_REPLICAS" == "1" ]] && [[ "$MAX_REPLICAS" == "5" ]] && [[ "$TARGET_CPU" == "50" ]]; then
        echo "✅ PASS: HPA configured correctly"
        Q16_HPA_SCORE=2
    else
        echo "❌ FAIL: HPA configuration incorrect"
        Q16_HPA_SCORE=0
    fi
else
    echo "❌ FAIL: No HPA found"
    Q16_HPA_SCORE=0
fi

# Check documentation
SCALING_FILE="/opt/KDHPA00101/scaling.txt"

if [[ -f "$SCALING_FILE" ]] && [[ -s "$SCALING_FILE" ]]; then
    echo "✅ PASS: Scaling documentation exists"
    Q16_DOC_SCORE=1
else
    echo "❌ FAIL: Documentation missing or empty"
    Q16_DOC_SCORE=0
fi

Q16_TOTAL=$((Q16_DEPLOY_SCORE + Q16_HPA_SCORE + Q16_DOC_SCORE))
echo "Question 16 Score: $Q16_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q16_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 16 ends
```

**Step 3: Add Questions 17-20 evaluation (Ingress & Troubleshooting)**

Append to `scripts/evaluate2.sh`:

```bash
# Evaluation for Question 17 starts

echo "=== Evaluating Question 17 ==="

# Check deployments and services
APP1_DEPLOY=$(kubectl get deployment app1 -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)
APP2_DEPLOY=$(kubectl get deployment app2 -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$APP1_DEPLOY" == "app1" ]] && [[ "$APP2_DEPLOY" == "app2" ]]; then
    echo "✅ PASS: Both deployments exist"
    Q17_DEPLOY_SCORE=1
else
    echo "❌ FAIL: Deployments missing"
    Q17_DEPLOY_SCORE=0
fi

APP1_SVC=$(kubectl get service app1-service -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)
APP2_SVC=$(kubectl get service app2-service -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$APP1_SVC" == "app1-service" ]] && [[ "$APP2_SVC" == "app2-service" ]]; then
    echo "✅ PASS: Both services exist"
    Q17_SVC_SCORE=1
else
    echo "❌ FAIL: Services missing"
    Q17_SVC_SCORE=0
fi

# Check Ingress
ING_NAME=$(kubectl get ingress path-ingress -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$ING_NAME" == "path-ingress" ]]; then
    echo "✅ PASS: Ingress 'path-ingress' exists"

    # Check host
    ING_HOST=$(kubectl get ingress path-ingress -n ingress-test -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)

    if [[ "$ING_HOST" == "test.example.com" ]]; then
        echo "✅ PASS: Ingress host correct"
        Q17_ING_HOST_SCORE=1
    else
        echo "❌ FAIL: Ingress host incorrect"
        Q17_ING_HOST_SCORE=0
    fi

    # Check paths
    PATH1=$(kubectl get ingress path-ingress -n ingress-test -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/app1")].backend.service.name}' 2>/dev/null)
    PATH2=$(kubectl get ingress path-ingress -n ingress-test -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/app2")].backend.service.name}' 2>/dev/null)

    if [[ "$PATH1" == "app1-service" ]] && [[ "$PATH2" == "app2-service" ]]; then
        echo "✅ PASS: Ingress paths configured correctly"
        Q17_ING_PATHS_SCORE=3
    else
        echo "❌ FAIL: Ingress paths incorrect"
        Q17_ING_PATHS_SCORE=0
    fi
else
    echo "❌ FAIL: Ingress 'path-ingress' does not exist"
    Q17_ING_HOST_SCORE=0
    Q17_ING_PATHS_SCORE=0
fi

Q17_TOTAL=$((Q17_DEPLOY_SCORE + Q17_SVC_SCORE + Q17_ING_HOST_SCORE + Q17_ING_PATHS_SCORE))
echo "Question 17 Score: $Q17_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q17_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))

# Evaluation for Question 17 ends

# Evaluation for Question 18 starts

echo "=== Evaluating Question 18 ==="

ING_NAME=$(kubectl get ingress secure-ingress -n ingress-test -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$ING_NAME" == "secure-ingress" ]]; then
    echo "✅ PASS: Ingress 'secure-ingress' exists"
    Q18_ING_SCORE=1

    # Check TLS configuration
    TLS_SECRET=$(kubectl get ingress secure-ingress -n ingress-test -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)

    if [[ "$TLS_SECRET" == "tls-secret" ]]; then
        echo "✅ PASS: TLS configured with correct Secret"
        Q18_TLS_SCORE=2
    else
        echo "❌ FAIL: TLS Secret incorrect"
        Q18_TLS_SCORE=0
    fi

    # Check host
    ING_HOST=$(kubectl get ingress secure-ingress -n ingress-test -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
    TLS_HOST=$(kubectl get ingress secure-ingress -n ingress-test -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)

    if [[ "$ING_HOST" == "secure.example.com" ]] && [[ "$TLS_HOST" == "secure.example.com" ]]; then
        echo "✅ PASS: Host configured correctly"
        Q18_HOST_SCORE=1
    else
        echo "❌ FAIL: Host configuration incorrect"
        Q18_HOST_SCORE=0
    fi

    # Check backend
    BACKEND=$(kubectl get ingress secure-ingress -n ingress-test -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)

    if [[ "$BACKEND" == "app1-service" ]]; then
        echo "✅ PASS: Backend service correct"
        Q18_BACKEND_SCORE=1
    else
        echo "❌ FAIL: Backend service incorrect"
        Q18_BACKEND_SCORE=0
    fi
else
    echo "❌ FAIL: Ingress 'secure-ingress' does not exist"
    Q18_ING_SCORE=0
    Q18_TLS_SCORE=0
    Q18_HOST_SCORE=0
    Q18_BACKEND_SCORE=0
fi

Q18_TOTAL=$((Q18_ING_SCORE + Q18_TLS_SCORE + Q18_HOST_SCORE + Q18_BACKEND_SCORE))
echo "Question 18 Score: $Q18_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q18_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 18 ends

# Evaluation for Question 19 starts

echo "=== Evaluating Question 19 ==="

# Check deployment status
DEPLOY_NAME=$(kubectl get deployment broken-app -n troubleshoot2 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$DEPLOY_NAME" == "broken-app" ]]; then
    READY_REPLICAS=$(kubectl get deployment broken-app -n troubleshoot2 -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    DESIRED_REPLICAS=$(kubectl get deployment broken-app -n troubleshoot2 -o jsonpath='{.spec.replicas}' 2>/dev/null)

    if [[ "$READY_REPLICAS" == "2" ]] && [[ "$DESIRED_REPLICAS" == "2" ]]; then
        echo "✅ PASS: Deployment 'broken-app' has 2/2 replicas ready"
        Q19_DEPLOY_SCORE=3
    else
        echo "❌ FAIL: Deployment not fully ready (ready: $READY_REPLICAS/2)"
        Q19_DEPLOY_SCORE=0
    fi
else
    echo "❌ FAIL: Deployment 'broken-app' does not exist"
    Q19_DEPLOY_SCORE=0
fi

# Check issues documentation
ISSUES_FILE="/opt/KDTROUBLE00101/issues.txt"

if [[ ! -f "$ISSUES_FILE" ]]; then
    echo "❌ FAIL: Issues file not found"
    Q19_ISSUES_SCORE=0
elif [[ ! -s "$ISSUES_FILE" ]]; then
    echo "❌ FAIL: Issues file is empty"
    Q19_ISSUES_SCORE=0
else
    ISSUE_COUNT=$(wc -l < "$ISSUES_FILE" | tr -d ' ')

    if [[ "$ISSUE_COUNT" -ge "4" ]]; then
        echo "✅ PASS: All 4 issues documented"
        Q19_ISSUES_SCORE=4
    else
        echo "⚠️  PARTIAL: Only $ISSUE_COUNT issues documented (expected 4)"
        Q19_ISSUES_SCORE=$ISSUE_COUNT
    fi
fi

Q19_TOTAL=$((Q19_DEPLOY_SCORE + Q19_ISSUES_SCORE))
echo "Question 19 Score: $Q19_TOTAL/7"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q19_TOTAL))
MAX_SCORE=$((MAX_SCORE + 7))

# Evaluation for Question 19 ends

# Evaluation for Question 20 starts

echo "=== Evaluating Question 20 ==="

# Check node-info.txt
NODE_FILE="/opt/KDCLI00101/node-info.txt"

if [[ -f "$NODE_FILE" ]] && [[ -s "$NODE_FILE" ]]; then
    echo "✅ PASS: node-info.txt exists with content"
    Q20_NODE_SCORE=2
else
    echo "❌ FAIL: node-info.txt missing or empty"
    Q20_NODE_SCORE=0
fi

# Check pod-resources.txt
POD_RESOURCES_FILE="/opt/KDCLI00101/pod-resources.txt"

if [[ -f "$POD_RESOURCES_FILE" ]] && [[ -s "$POD_RESOURCES_FILE" ]]; then
    echo "✅ PASS: pod-resources.txt exists with content"
    Q20_RESOURCES_SCORE=2
else
    echo "❌ FAIL: pod-resources.txt missing or empty"
    Q20_RESOURCES_SCORE=0
fi

# Check high-priority.txt
PRIORITY_FILE="/opt/KDCLI00101/high-priority.txt"

if [[ -f "$PRIORITY_FILE" ]] && [[ -s "$PRIORITY_FILE" ]]; then
    echo "✅ PASS: high-priority.txt exists with content"
    Q20_PRIORITY_SCORE=2
else
    echo "❌ FAIL: high-priority.txt missing or empty"
    Q20_PRIORITY_SCORE=0
fi

# Check service-endpoints.txt
ENDPOINTS_FILE="/opt/KDCLI00101/service-endpoints.txt"

if [[ -f "$ENDPOINTS_FILE" ]] && [[ -s "$ENDPOINTS_FILE" ]]; then
    echo "✅ PASS: service-endpoints.txt exists with content"
    Q20_ENDPOINTS_SCORE=2
else
    echo "❌ FAIL: service-endpoints.txt missing or empty"
    Q20_ENDPOINTS_SCORE=0
fi

Q20_TOTAL=$((Q20_NODE_SCORE + Q20_RESOURCES_SCORE + Q20_PRIORITY_SCORE + Q20_ENDPOINTS_SCORE))
echo "Question 20 Score: $Q20_TOTAL/8"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q20_TOTAL))
MAX_SCORE=$((MAX_SCORE + 8))

# Evaluation for Question 20 ends
```

**Step 4: Add final scoring summary**

Append to `scripts/evaluate2.sh`:

```bash
# Final Score Summary

echo "=========================================="
echo "FINAL SCORE: $TOTAL_SCORE/$MAX_SCORE"
PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))
echo "Percentage: $PERCENTAGE%"
echo "=========================================="

if [[ $PERCENTAGE -ge 90 ]]; then
    echo "🎉 Excellent! You've mastered advanced CKAD concepts!"
elif [[ $PERCENTAGE -ge 70 ]]; then
    echo "👍 Good job! Review the failed questions to improve."
elif [[ $PERCENTAGE -ge 50 ]]; then
    echo "📚 Keep practicing! Focus on the areas where you lost points."
else
    echo "💪 Don't give up! Review the concepts and try again."
fi
```

**Step 5: Make evaluate2.sh executable and commit**

```bash
chmod +x scripts/evaluate2.sh
git add scripts/evaluate2.sh
git commit -m "Complete evaluate2.sh with all 20 questions

Full evaluation logic for:
- Questions 11-13: Jobs and parallelism
- Questions 14-16: Resource management
- Questions 17-18: Ingress configuration
- Questions 19-20: Advanced troubleshooting

Total: 100 points with percentage scoring

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 6: Update README and final verification

**Files:**
- Modify: `README.md`

**Step 1: Update README.md to document Set 2**

```markdown
## Setup Testing Environment
- Run following commands on your test Kubernetes environment:
    ```
    git clone https://github.com/kmriyad/ckad.git
    chmod +x ckad/scripts/setup.sh
    chmod +x ckad/scripts/evaluate.sh
    ckad/scripts/setup.sh
    ```
- Student answers questions in your test Kubernetes environment by following the directions in questions.md
- Administrator runs evaluate.sh to evaluate student's answers

## Setup Testing Environment - Set 2 (Advanced Topics)
- Run following commands on your test Kubernetes environment:
    ```
    chmod +x ckad/scripts/setup2.sh
    chmod +x ckad/scripts/evaluate2.sh
    ckad/scripts/setup2.sh
    ```
- Student answers questions in questions2.md (covers DaemonSets, StatefulSets, RBAC, Jobs, Resource Management, Ingress, Advanced Troubleshooting)
- Administrator runs evaluate2.sh to evaluate student's answers

Note: Both sets can be run independently. Set 1 covers foundational concepts, Set 2 covers advanced CKAD topics.
```

**Step 2: Commit README update**

```bash
git add README.md
git commit -m "Update README to document questions set 2

Add instructions for running CKAD practice set 2 with
advanced topics including DaemonSets, StatefulSets, RBAC,
Jobs, resource management, Ingress, and troubleshooting.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Step 3: Final verification checklist**

Verify all files exist:
```bash
ls -lh questions2.md scripts/setup2.sh scripts/evaluate2.sh
```

Verify scripts are executable:
```bash
test -x scripts/setup2.sh && echo "setup2.sh is executable" || echo "ERROR: setup2.sh not executable"
test -x scripts/evaluate2.sh && echo "evaluate2.sh is executable" || echo "ERROR: evaluate2.sh not executable"
```

Count questions in questions2.md:
```bash
grep -c "^### Question" questions2.md
```

Expected output: 20

**Step 4: Push all changes to remote**

```bash
git push origin feature/questions-set-2
```

**Step 5: Create completion summary**

Document what was created:
- questions2.md: 20 questions covering advanced CKAD topics (100 points)
- scripts/setup2.sh: Complete environment setup for all 20 questions
- scripts/evaluate2.sh: Automated evaluation with 100-point scoring
- docs/plans/2025-10-29-questions-set-2-design.md: Design documentation
- README.md: Updated with Set 2 instructions

---

## Summary

This plan creates a complete second set of CKAD practice questions following the exact same structure as Set 1. The implementation is broken into 6 tasks:

1. **Task 1:** Create questions2.md with all 20 questions
2. **Task 2:** Create setup2.sh with complete environment setup
3. **Task 3:** Start evaluate2.sh with Questions 1-5
4. **Task 4:** Continue evaluate2.sh with Questions 6-10
5. **Task 5:** Complete evaluate2.sh with Questions 11-20
6. **Task 6:** Update README and verify everything works

Each task includes specific file paths, complete code examples, and commit messages following TDD principles where applicable (for the evaluation logic).
