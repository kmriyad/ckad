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
