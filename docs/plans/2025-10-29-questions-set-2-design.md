# CKAD Practice Questions Set 2 - Design Document

**Date:** 2025-10-29
**Purpose:** Create a second set of 20 CKAD practice questions focusing on topics not heavily covered in questions.md

## Overview

This design covers the creation of a complementary question set that fills gaps in CKAD exam domain coverage. While Set 1 (questions.md) focuses on foundational concepts like pods, basic deployments, ConfigMaps, Secrets, and simple troubleshooting, Set 2 will cover advanced topics that are critical for the CKAD exam.

## Goals

1. **Comprehensive Coverage:** Fill CKAD exam domain gaps from Set 1
2. **Consistent Structure:** Match the format and scoring approach of Set 1
3. **Automated Testing:** Full setup and evaluation automation
4. **Independent Usage:** Set 2 can be used standalone or as a follow-up to Set 1

## File Structure

```
ckad/
├── questions.md          # Existing Set 1
├── questions2.md         # New Set 2
├── scripts/
│   ├── setup.sh          # Existing Set 1 setup
│   ├── setup2.sh         # New Set 2 setup
│   ├── evaluate.sh       # Existing Set 1 evaluation
│   └── evaluate2.sh      # New Set 2 evaluation
└── docs/
    └── plans/
        └── 2025-10-29-questions-set-2-design.md
```

## Question Breakdown

### Total: 20 Questions, 100 Points

#### Section 1: DaemonSets & Node Scheduling (Questions 1-3, 12 points)

**Question 1 (4 points): Create DaemonSet**
- Context: Need to run logging agent on every node
- Tasks:
  - Create DaemonSet named `log-collector` in namespace `logging`
  - Use image: `fluentd:v1.14`
  - Mount host path `/var/log` to container path `/var/log:ro`
- Setup: Create `logging` namespace
- Evaluation:
  - DaemonSet exists and runs
  - Correct image used
  - Host path mounted correctly
  - Pod count matches node count

**Question 2 (4 points): Taints and Tolerations**
- Context: Need to schedule pod on tainted node
- Tasks:
  - A node has taint `workload=special:NoSchedule` (setup creates this)
  - Create pod `special-app` that tolerates this taint
  - Pod should use nginx image
  - Verify pod schedules on the tainted node
- Setup: Apply taint to a node (use first node in cluster)
- Evaluation:
  - Pod exists and running
  - Has correct toleration
  - Scheduled on tainted node

**Question 3 (4 points): Node Affinity**
- Context: Deploy workload only on specific node type
- Tasks:
  - Nodes labeled with `disktype=ssd` (setup creates label)
  - Create deployment `fast-app` with 2 replicas
  - Use requiredDuringSchedulingIgnoredDuringExecution node affinity for `disktype=ssd`
  - Use nginx image
- Setup: Label one or more nodes with `disktype=ssd`
- Evaluation:
  - Deployment exists with correct replicas
  - Node affinity configured correctly
  - All pods scheduled on labeled nodes

#### Section 2: StatefulSets (Questions 4-6, 15 points)

**Question 4 (5 points): StatefulSet with Headless Service**
- Context: Application needs stable network identities
- Tasks:
  - Create headless service `db-service` in namespace `stateful`
  - Create StatefulSet `db` with 3 replicas
  - Use nginx image (simulating database)
  - Port 80
  - Verify stable DNS names (db-0.db-service, db-1.db-service, db-2.db-service)
- Setup: Create `stateful` namespace
- Evaluation:
  - Headless service exists (clusterIP: None)
  - StatefulSet exists with 3 replicas
  - Pods have stable names (db-0, db-1, db-2)
  - DNS resolution works

**Question 5 (5 points): StatefulSet with Persistent Storage**
- Context: Each instance needs its own persistent storage
- Tasks:
  - Create StatefulSet `data-app` in namespace `stateful`
  - Use volumeClaimTemplates requesting 1Gi storage
  - 2 replicas
  - Use busybox image, write hostname to /data/id.txt
  - Verify each pod has separate PVC
- Setup: Namespace already created in Q4
- Evaluation:
  - StatefulSet exists with volumeClaimTemplates
  - 2 PVCs created (one per pod)
  - Data persists after pod deletion
  - Each pod has unique data

**Question 6 (5 points): StatefulSet Scaling and Updates**
- Context: Managing StatefulSet lifecycle
- Tasks:
  - Scale existing StatefulSet `db` from Q4 to 5 replicas
  - Update image to nginx:1.24
  - Observe ordered operations
  - Scale back down to 3
  - Store scaling observations in /opt/KDST00301/observations.txt
- Setup: File path created
- Evaluation:
  - StatefulSet scaled correctly
  - Image updated
  - File contains evidence of ordered operations
  - Final replica count is 3

#### Section 3: RBAC (Questions 7-10, 20 points)

**Question 7 (4 points): Role and RoleBinding**
- Context: Service needs to list pods in its namespace
- Tasks:
  - Create Role `pod-reader` in namespace `rbac-test`
  - Allow: get, list, watch on pods
  - Create ServiceAccount `app-sa`
  - Create RoleBinding binding pod-reader to app-sa
- Setup: Create `rbac-test` namespace
- Evaluation:
  - Role exists with correct permissions
  - ServiceAccount exists
  - RoleBinding connects them
  - Test with `kubectl auth can-i`

**Question 8 (5 points): ClusterRole and ClusterRoleBinding**
- Context: Monitoring tool needs to read nodes across cluster
- Tasks:
  - Create ClusterRole `node-reader`
  - Allow: get, list on nodes
  - Create ServiceAccount `monitor-sa` in namespace `monitoring`
  - Create ClusterRoleBinding
- Setup: Create `monitoring` namespace
- Evaluation:
  - ClusterRole exists with correct permissions
  - ServiceAccount exists
  - ClusterRoleBinding connects them
  - Permissions work cluster-wide

**Question 9 (6 points): ServiceAccount with Limited Permissions**
- Context: Pod should only access ConfigMaps, not Secrets
- Tasks:
  - Create ServiceAccount `limited-sa` in namespace `secure`
  - Create Role allowing get, list on ConfigMaps only
  - Create RoleBinding
  - Create pod `limited-pod` using this ServiceAccount
  - Verify pod can read ConfigMaps but not Secrets (document test in /opt/KDRBAC00301/test-results.txt)
- Setup: Create `secure` namespace, create a ConfigMap and Secret for testing
- Evaluation:
  - ServiceAccount, Role, RoleBinding configured correctly
  - Pod uses the ServiceAccount
  - Test results document correct permission behavior

**Question 10 (5 points): Debug RBAC Issue**
- Context: Application pod failing to create ConfigMaps
- Tasks:
  - Pod `app-broken` in namespace `debug` is failing
  - Error in logs shows permission denied creating ConfigMaps
  - Create appropriate Role and RoleBinding to fix issue
  - Pod uses ServiceAccount `app-service-account` (already created)
- Setup: Create namespace, ServiceAccount, failing pod
- Evaluation:
  - Role created with create permission on ConfigMaps
  - RoleBinding connects Role to existing ServiceAccount
  - Pod can now successfully create ConfigMaps

#### Section 4: Jobs & Parallelism (Questions 11-13, 12 points)

**Question 11 (4 points): Basic Job**
- Context: Run one-time data processing task
- Tasks:
  - Create Job `data-processor` in namespace `batch`
  - Use busybox image
  - Command: process data and output results
  - Job should complete successfully once
  - Store job completion status in /opt/KDJOB00101/status.txt
- Setup: Create `batch` namespace, create output file
- Evaluation:
  - Job exists
  - Completed successfully (completions=1)
  - Status file updated

**Question 12 (4 points): Parallel Job**
- Context: Process multiple items concurrently
- Tasks:
  - Create Job `parallel-processor` in namespace `batch`
  - parallelism: 3, completions: 9
  - Use busybox image with sleep command
  - Verify 3 pods run at once until 9 total completions
- Setup: Namespace already exists
- Evaluation:
  - Job configured with correct parallelism and completions
  - Job completes successfully
  - Completion count is 9

**Question 13 (4 points): Job with Limits**
- Context: Job should timeout if taking too long
- Tasks:
  - Create Job `timeout-job` in namespace `batch`
  - backoffLimit: 2
  - activeDeadlineSeconds: 30
  - Use busybox with long-running command
  - Observe and document timeout behavior in /opt/KDJOB00301/behavior.txt
- Setup: Create output file
- Evaluation:
  - Job has correct backoffLimit
  - Job has correct activeDeadlineSeconds
  - Job terminates after 30 seconds
  - Documentation file exists

#### Section 5: Resource Management (Questions 14-16, 15 points)

**Question 14 (5 points): ResourceQuota**
- Context: Limit resource consumption in namespace
- Tasks:
  - Create namespace `quota-test`
  - Create ResourceQuota limiting: max 3 pods, 1 CPU request total, 1Gi memory request total
  - Create 2 pods within quota
  - Attempt to create 4th pod and document quota enforcement in /opt/KDRES00101/quota-test.txt
- Setup: Create output file
- Evaluation:
  - ResourceQuota exists with correct limits
  - First 2 pods created successfully
  - Additional pods blocked by quota (documented)

**Question 15 (5 points): LimitRange**
- Context: Set default resource limits for namespace
- Tasks:
  - Create namespace `limits-test`
  - Create LimitRange with default request: 100m CPU, 128Mi memory; default limit: 200m CPU, 256Mi memory
  - Create pod without resource specifications
  - Verify defaults applied automatically
- Setup: Create namespace
- Evaluation:
  - LimitRange exists with correct defaults
  - Pod created
  - Pod has default requests and limits applied

**Question 16 (5 points): Horizontal Pod Autoscaler**
- Context: Auto-scale based on CPU usage
- Tasks:
  - Create deployment `scalable-app` in namespace `autoscale` with 1 replica
  - Container resource request: 100m CPU
  - Create HPA targeting 50% CPU, min 1, max 5 replicas
  - Use provided load generation script
  - Verify scaling occurs (document in /opt/KDHPA00101/scaling.txt)
- Setup: Create namespace, provide load generation helper
- Evaluation:
  - Deployment has resource requests
  - HPA exists with correct configuration
  - HPA references correct deployment
  - Scaling documented

#### Section 6: Ingress & Advanced Networking (Questions 17-18, 11 points)

**Question 17 (6 points): Path-based Ingress**
- Context: Route traffic based on URL path
- Tasks:
  - Create deployments `app1` and `app2` in namespace `ingress-test`
  - Create services for both
  - Create Ingress routing /app1 to app1 service, /app2 to app2 service
  - Host: test.example.com
  - Test routing (curl commands provided)
- Setup: Create namespace, provide test instructions
- Evaluation:
  - Both deployments and services exist
  - Ingress exists with correct path rules
  - Routing configured correctly

**Question 18 (5 points): Ingress with TLS**
- Context: Enable HTTPS for application
- Tasks:
  - Create Ingress `secure-ingress` in namespace `ingress-test`
  - Use TLS with provided certificate (Secret already created in setup)
  - Host: secure.example.com
  - Backend to existing app1 service
- Setup: Create TLS Secret with cert
- Evaluation:
  - Ingress exists
  - TLS configuration present
  - References correct Secret
  - Host configured correctly

#### Section 7: Advanced Troubleshooting (Questions 19-20, 15 points)

**Question 19 (7 points): Multi-issue Debugging**
- Context: Deployment has multiple problems
- Tasks:
  - Deployment `broken-app` in namespace `troubleshoot2` won't run
  - Issues include: wrong image tag, missing ConfigMap, insufficient memory limit, incorrect probe
  - Identify ALL issues and fix them
  - Document findings in /opt/KDTROUBLE00101/issues.txt (one issue per line)
  - Deployment should have 2 running replicas when complete
- Setup: Create intentionally broken deployment
- Evaluation:
  - All 4 issues identified in file
  - Deployment fixed and running
  - 2/2 replicas ready

**Question 20 (8 points): kubectl and JSONPath Mastery**
- Context: Extract specific information using kubectl
- Tasks:
  - Write to /opt/KDCLI00101/node-info.txt: List all node names sorted alphabetically
  - Write to /opt/KDCLI00101/pod-resources.txt: All pods in namespace `resource-check` with CPU requests in format "podname: CPUrequest"
  - Write to /opt/KDCLI00101/high-priority.txt: Names of pods with priorityClassName set (any value)
  - Write to /opt/KDCLI00101/service-endpoints.txt: All services with type=NodePort and their node ports in JSON format
- Setup: Create `resource-check` namespace with various pods, create output files
- Evaluation:
  - All 4 files contain correct information
  - Proper formatting
  - Correct JSONPath usage

## Technical Implementation Details

### setup2.sh Structure

```bash
#!/usr/bin/env bash
# CKAD Practice Set 2 Setup Script

# For each question:
# - Create required namespaces
# - Create required files/directories
# - Pre-create any resources students will modify
# - Apply taints/labels as needed
```

**Key Setup Tasks:**
- Q2: Apply taint to node
- Q3: Label nodes with disktype
- Q7-10: Create RBAC namespaces
- Q9: Create test ConfigMap and Secret
- Q10: Create broken RBAC scenario
- Q16: Provide load generation script or instructions
- Q18: Create TLS Secret with certificate
- Q19: Create broken deployment with multiple issues
- Q20: Create test pods with various configurations

### evaluate2.sh Structure

```bash
#!/usr/bin/env bash
# CKAD Practice Set 2 Evaluation Script

TOTAL_SCORE=0
MAX_SCORE=0

# For each question:
# - Check resource existence
# - Validate configuration
# - Test functionality where possible
# - Update score
```

**Evaluation Patterns:**
- Resource existence checks using kubectl get
- Configuration validation using kubectl get -o jsonpath
- Status checks (pod running, job completed)
- File content validation
- Permission testing with kubectl auth can-i
- DNS resolution tests for StatefulSets
- Replica count and scaling verification

### Special Considerations

**Node Operations (Q2, Q3):**
- Setup must detect available nodes
- Use first worker node for taints (or control plane if single-node like minikube)
- Label selection should work with varied node counts

**RBAC Testing (Q7-10):**
- Evaluation uses kubectl auth can-i to verify permissions
- May need to use --as=system:serviceaccount:namespace:sa-name

**HPA (Q16):**
- Requires metrics-server installed
- Setup should check and warn if not available
- Evaluation checks HPA object, may not verify actual scaling if metrics unavailable

**Ingress (Q17-18):**
- Requires Ingress controller installed
- Setup should note this requirement
- Evaluation validates Ingress object, may not test actual routing

**StatefulSet DNS (Q4):**
- Evaluation can test DNS with kubectl run --rm temporary pod and nslookup

## README Updates

Update README.md to document Set 2:

```markdown
## Setup Testing Environment - Set 2
- Run following commands on your test Kubernetes environment:
    ```
    ckad/scripts/setup2.sh
    ```
- Student answers questions in questions2.md
- Administrator runs evaluate2.sh to evaluate answers
```

## Success Criteria

1. ✅ All 20 questions cover CKAD exam domains not heavily covered in Set 1
2. ✅ setup2.sh creates all necessary preconditions
3. ✅ evaluate2.sh accurately scores all 20 questions totaling 100 points
4. ✅ Questions are clear and match CKAD exam style
5. ✅ Set 2 can run independently of Set 1
6. ✅ All scripts follow same patterns as existing scripts

## Future Enhancements

- Add score alias for evaluate2.sh (score2 command)
- Create combined evaluation script that runs both sets
- Add difficulty indicators to questions
- Time estimates per question
