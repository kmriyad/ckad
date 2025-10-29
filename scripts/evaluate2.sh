#!/usr/bin/env bash
# ABOUTME: Automated evaluation script for CKAD practice questions set 2
# ABOUTME: Tests Kubernetes resources and configurations for correctness and compliance
########################################
# CKAD Practice Set 2 Evaluation Script
# This script evaluates student responses to questions in questions2.md
# It checks for the existence and correctness of Kubernetes resources.
#########################################

# Initialize score tracking
TOTAL_SCORE=0
MAX_SCORE=0

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
