#!/usr/bin/env bash

########################################
# ABOUTME: CKAD Exam Simulation Evaluation Script - Set 3
# ABOUTME: Evaluates student answers for advanced Kubernetes questions and calculates scores.
#########################################

# Initialize score tracking
TOTAL_SCORE=0
MAX_SCORE=0

# Evaluation for Question 1 starts
echo "=== Evaluating Question 1: Init Containers - Basic ==="

# Check if pod exists
POD_NAME=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'app-with-init' does not exist in namespace 'init-basic'"
    Q1_POD_SCORE=0
    Q1_INIT_SCORE=0
    Q1_MAIN_SCORE=0
    Q1_STATUS_SCORE=0
else
    echo "✅ PASS: Pod 'app-with-init' exists"
    Q1_POD_SCORE=1

    # Check init container
    INIT_NAME=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
    INIT_IMAGE=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)

    if [[ "$INIT_NAME" == "db-check" ]] && [[ "$INIT_IMAGE" == *"busybox"* ]]; then
        echo "✅ PASS: Init container 'db-check' with busybox image exists"
        Q1_INIT_SCORE=2
    else
        echo "❌ FAIL: Init container not correctly configured (name: $INIT_NAME, image: $INIT_IMAGE)"
        Q1_INIT_SCORE=0
    fi

    # Check main container
    MAIN_NAME=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    MAIN_IMAGE=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

    if [[ "$MAIN_NAME" == "app" ]] && [[ "$MAIN_IMAGE" == *"nginx"* ]]; then
        echo "✅ PASS: Main container 'app' with nginx image exists"
        Q1_MAIN_SCORE=1
    else
        echo "❌ FAIL: Main container not correctly configured"
        Q1_MAIN_SCORE=0
    fi

    # Check pod status
    POD_STATUS=$(kubectl get pod app-with-init -n init-basic -o jsonpath='{.status.phase}' 2>/dev/null)

    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "✅ PASS: Pod is running (init container completed successfully)"
        Q1_STATUS_SCORE=1
    else
        echo "⚠️  PARTIAL: Pod status is '$POD_STATUS' (expected: Running)"
        Q1_STATUS_SCORE=0
    fi
fi

Q1_TOTAL=$((Q1_POD_SCORE + Q1_INIT_SCORE + Q1_MAIN_SCORE + Q1_STATUS_SCORE))
echo "Question 1 Score: $Q1_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q1_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 1 ends

# Evaluation for Question 2 starts
echo "=== Evaluating Question 2: Init Containers - Multiple ==="

POD_NAME=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'multi-init-pod' does not exist in namespace 'init-multi'"
    Q2_POD_SCORE=0
    Q2_INIT1_SCORE=0
    Q2_INIT2_SCORE=0
    Q2_MAIN_SCORE=0
    Q2_VOLUME_SCORE=0
else
    echo "✅ PASS: Pod 'multi-init-pod' exists"
    Q2_POD_SCORE=1

    # Check first init container
    INIT1_NAME=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)

    if [[ "$INIT1_NAME" == "download" ]]; then
        echo "✅ PASS: First init container 'download' exists"
        Q2_INIT1_SCORE=1
    else
        echo "❌ FAIL: First init container should be named 'download'"
        Q2_INIT1_SCORE=0
    fi

    # Check second init container
    INIT2_NAME=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.spec.initContainers[1].name}' 2>/dev/null)

    if [[ "$INIT2_NAME" == "validate" ]]; then
        echo "✅ PASS: Second init container 'validate' exists"
        Q2_INIT2_SCORE=1
    else
        echo "❌ FAIL: Second init container should be named 'validate'"
        Q2_INIT2_SCORE=0
    fi

    # Check main container
    MAIN_NAME=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    MAIN_MOUNT=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/app-config")].mountPath}' 2>/dev/null)

    if [[ "$MAIN_NAME" == "app" ]] && [[ "$MAIN_MOUNT" == "/etc/app-config" ]]; then
        echo "✅ PASS: Main container 'app' with correct mount path"
        Q2_MAIN_SCORE=1
    else
        echo "❌ FAIL: Main container not correctly configured"
        Q2_MAIN_SCORE=0
    fi

    # Check shared volume
    VOLUME_NAME=$(kubectl get pod multi-init-pod -n init-multi -o jsonpath='{.spec.volumes[?(@.name=="work-dir")].name}' 2>/dev/null)

    if [[ "$VOLUME_NAME" == "work-dir" ]]; then
        echo "✅ PASS: Shared emptyDir volume 'work-dir' exists"
        Q2_VOLUME_SCORE=1
    else
        echo "❌ FAIL: Shared volume 'work-dir' not found"
        Q2_VOLUME_SCORE=0
    fi
fi

Q2_TOTAL=$((Q2_POD_SCORE + Q2_INIT1_SCORE + Q2_INIT2_SCORE + Q2_MAIN_SCORE + Q2_VOLUME_SCORE))
echo "Question 2 Score: $Q2_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q2_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 2 ends

# Evaluation for Question 3 starts
echo "=== Evaluating Question 3: Security Context - User ==="

POD_NAME=$(kubectl get pod secure-pod -n security-user -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'secure-pod' does not exist in namespace 'security-user'"
    Q3_POD_SCORE=0
    Q3_USER_SCORE=0
    Q3_GROUP_SCORE=0
    Q3_FILE_SCORE=0
else
    echo "✅ PASS: Pod 'secure-pod' exists"
    Q3_POD_SCORE=1

    # Check runAsUser
    RUN_AS_USER=$(kubectl get pod secure-pod -n security-user -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
    RUN_AS_GROUP=$(kubectl get pod secure-pod -n security-user -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null)
    FS_GROUP=$(kubectl get pod secure-pod -n security-user -o jsonpath='{.spec.securityContext.fsGroup}' 2>/dev/null)

    if [[ "$RUN_AS_USER" == "1000" ]]; then
        echo "✅ PASS: runAsUser: 1000"
        Q3_USER_SCORE=1
    else
        echo "❌ FAIL: runAsUser is '$RUN_AS_USER' (expected: 1000)"
        Q3_USER_SCORE=0
    fi

    if [[ "$RUN_AS_GROUP" == "3000" ]] && [[ "$FS_GROUP" == "2000" ]]; then
        echo "✅ PASS: runAsGroup: 3000, fsGroup: 2000"
        Q3_GROUP_SCORE=1
    else
        echo "❌ FAIL: runAsGroup: '$RUN_AS_GROUP' (expected: 3000), fsGroup: '$FS_GROUP' (expected: 2000)"
        Q3_GROUP_SCORE=0
    fi

    # Check output file
    FILE_PATH="/opt/KDSEC00101/user-info.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        if grep -q "uid=1000" "$FILE_PATH" 2>/dev/null; then
            echo "✅ PASS: Output file contains user info"
            Q3_FILE_SCORE=1
        else
            echo "❌ FAIL: Output file doesn't contain expected user info"
            Q3_FILE_SCORE=0
        fi
    else
        echo "❌ FAIL: Output file $FILE_PATH is empty or doesn't exist"
        Q3_FILE_SCORE=0
    fi
fi

Q3_TOTAL=$((Q3_POD_SCORE + Q3_USER_SCORE + Q3_GROUP_SCORE + Q3_FILE_SCORE))
echo "Question 3 Score: $Q3_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q3_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))
# Evaluation for Question 3 ends

# Evaluation for Question 4 starts
echo "=== Evaluating Question 4: Security Context - Capabilities ==="

POD_NAME=$(kubectl get pod cap-pod -n security-caps -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'cap-pod' does not exist in namespace 'security-caps'"
    Q4_POD_SCORE=0
    Q4_DROP_SCORE=0
    Q4_ADD_SCORE=0
    Q4_STATUS_SCORE=0
    Q4_FILE_SCORE=0
else
    echo "✅ PASS: Pod 'cap-pod' exists"
    Q4_POD_SCORE=1

    # Check drop ALL
    DROP_CAPS=$(kubectl get pod cap-pod -n security-caps -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop}' 2>/dev/null)

    if echo "$DROP_CAPS" | grep -qi "ALL"; then
        echo "✅ PASS: Capabilities DROP ALL configured"
        Q4_DROP_SCORE=2
    else
        echo "❌ FAIL: DROP ALL not configured (found: $DROP_CAPS)"
        Q4_DROP_SCORE=0
    fi

    # Check add NET_BIND_SERVICE
    ADD_CAPS=$(kubectl get pod cap-pod -n security-caps -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)

    if echo "$ADD_CAPS" | grep -qi "NET_BIND_SERVICE"; then
        echo "✅ PASS: NET_BIND_SERVICE capability added"
        Q4_ADD_SCORE=1
    else
        echo "❌ FAIL: NET_BIND_SERVICE not added (found: $ADD_CAPS)"
        Q4_ADD_SCORE=0
    fi

    # Check pod is running
    POD_STATUS=$(kubectl get pod cap-pod -n security-caps -o jsonpath='{.status.phase}' 2>/dev/null)

    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "✅ PASS: Pod is running"
        Q4_STATUS_SCORE=1
    else
        echo "❌ FAIL: Pod status is '$POD_STATUS'"
        Q4_STATUS_SCORE=0
    fi

    # Check output file
    FILE_PATH="/opt/KDSEC00201/capabilities.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        echo "✅ PASS: Capabilities output file exists"
        Q4_FILE_SCORE=1
    else
        echo "❌ FAIL: Capabilities output file is empty or doesn't exist"
        Q4_FILE_SCORE=0
    fi
fi

Q4_TOTAL=$((Q4_POD_SCORE + Q4_DROP_SCORE + Q4_ADD_SCORE + Q4_STATUS_SCORE + Q4_FILE_SCORE))
echo "Question 4 Score: $Q4_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q4_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))
# Evaluation for Question 4 ends

# Evaluation for Question 5 starts
echo "=== Evaluating Question 5: Pod Affinity ==="

DEPLOYMENT_NAME=$(kubectl get deployment frontend -n affinity -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'frontend' does not exist in namespace 'affinity'"
    Q5_DEPLOY_SCORE=0
    Q5_REPLICAS_SCORE=0
    Q5_AFFINITY_SCORE=0
    Q5_TOPOLOGY_SCORE=0
    Q5_RUNNING_SCORE=0
else
    echo "✅ PASS: Deployment 'frontend' exists"
    Q5_DEPLOY_SCORE=1

    # Check replicas
    REPLICAS=$(kubectl get deployment frontend -n affinity -o jsonpath='{.spec.replicas}' 2>/dev/null)

    if [[ "$REPLICAS" == "2" ]]; then
        echo "✅ PASS: Deployment has 2 replicas"
        Q5_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: Deployment has $REPLICAS replicas (expected: 2)"
        Q5_REPLICAS_SCORE=0
    fi

    # Check pod affinity
    AFFINITY=$(kubectl get deployment frontend -n affinity -o jsonpath='{.spec.template.spec.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)

    if [[ ! -z "$AFFINITY" ]]; then
        echo "✅ PASS: Pod affinity (preferredDuringSchedulingIgnoredDuringExecution) configured"
        Q5_AFFINITY_SCORE=1
    else
        echo "❌ FAIL: Pod affinity not configured"
        Q5_AFFINITY_SCORE=0
    fi

    # Check topology key
    TOPOLOGY=$(kubectl get deployment frontend -n affinity -o json 2>/dev/null | grep -o '"topologyKey":"kubernetes.io/hostname"' || echo "")

    if [[ ! -z "$TOPOLOGY" ]]; then
        echo "✅ PASS: topologyKey set to kubernetes.io/hostname"
        Q5_TOPOLOGY_SCORE=1
    else
        echo "❌ FAIL: topologyKey not correctly set"
        Q5_TOPOLOGY_SCORE=0
    fi

    # Check pods running
    READY=$(kubectl get deployment frontend -n affinity -o jsonpath='{.status.readyReplicas}' 2>/dev/null)

    if [[ "$READY" == "2" ]]; then
        echo "✅ PASS: All pods are running"
        Q5_RUNNING_SCORE=1
    else
        echo "⚠️  PARTIAL: Only $READY pods ready"
        Q5_RUNNING_SCORE=0
    fi
fi

Q5_TOTAL=$((Q5_DEPLOY_SCORE + Q5_REPLICAS_SCORE + Q5_AFFINITY_SCORE + Q5_TOPOLOGY_SCORE + Q5_RUNNING_SCORE))
echo "Question 5 Score: $Q5_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q5_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 5 ends

# Evaluation for Question 6 starts
echo "=== Evaluating Question 6: Pod Anti-Affinity ==="

DEPLOYMENT_NAME=$(kubectl get deployment db-spread -n anti-affinity -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'db-spread' does not exist in namespace 'anti-affinity'"
    Q6_DEPLOY_SCORE=0
    Q6_REPLICAS_SCORE=0
    Q6_LABEL_SCORE=0
    Q6_ANTIAFFINITY_SCORE=0
    Q6_FILE_SCORE=0
else
    echo "✅ PASS: Deployment 'db-spread' exists"
    Q6_DEPLOY_SCORE=1

    # Check replicas
    REPLICAS=$(kubectl get deployment db-spread -n anti-affinity -o jsonpath='{.spec.replicas}' 2>/dev/null)

    if [[ "$REPLICAS" == "3" ]]; then
        echo "✅ PASS: Deployment has 3 replicas"
        Q6_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: Deployment has $REPLICAS replicas (expected: 3)"
        Q6_REPLICAS_SCORE=0
    fi

    # Check label
    LABEL=$(kubectl get deployment db-spread -n anti-affinity -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)

    if [[ "$LABEL" == "database" ]]; then
        echo "✅ PASS: Pod template has label app=database"
        Q6_LABEL_SCORE=1
    else
        echo "❌ FAIL: Pod template label is '$LABEL' (expected: database)"
        Q6_LABEL_SCORE=0
    fi

    # Check pod anti-affinity
    ANTIAFFINITY=$(kubectl get deployment db-spread -n anti-affinity -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)

    if [[ ! -z "$ANTIAFFINITY" ]]; then
        echo "✅ PASS: Pod anti-affinity (requiredDuringSchedulingIgnoredDuringExecution) configured"
        Q6_ANTIAFFINITY_SCORE=2
    else
        echo "❌ FAIL: Pod anti-affinity not configured"
        Q6_ANTIAFFINITY_SCORE=0
    fi

    # Check observations file (for single-node clusters)
    FILE_PATH="/opt/KDAFF00201/observations.txt"
    RUNNING_PODS=$(kubectl get pods -n anti-affinity -l app=database --field-selector=status.phase=Running 2>/dev/null | grep -c "db-spread" || echo "0")

    if [[ "$RUNNING_PODS" -ge 1 ]]; then
        if [[ "$RUNNING_PODS" -lt 3 ]] && [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
            echo "✅ PASS: Observations documented for single-node limitation"
            Q6_FILE_SCORE=1
        elif [[ "$RUNNING_PODS" -eq 3 ]]; then
            echo "✅ PASS: All 3 pods running on different nodes"
            Q6_FILE_SCORE=1
        else
            echo "⚠️  PARTIAL: Some pods pending, ensure observations documented"
            Q6_FILE_SCORE=0
        fi
    else
        echo "❌ FAIL: No pods running"
        Q6_FILE_SCORE=0
    fi
fi

Q6_TOTAL=$((Q6_DEPLOY_SCORE + Q6_REPLICAS_SCORE + Q6_LABEL_SCORE + Q6_ANTIAFFINITY_SCORE + Q6_FILE_SCORE))
echo "Question 6 Score: $Q6_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q6_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))
# Evaluation for Question 6 ends

# Evaluation for Question 7 starts
echo "=== Evaluating Question 7: Startup Probe ==="

POD_NAME=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'slow-start' does not exist in namespace 'startup-probe'"
    Q7_POD_SCORE=0
    Q7_STARTUP_SCORE=0
    Q7_LIVENESS_SCORE=0
    Q7_RUNNING_SCORE=0
else
    echo "✅ PASS: Pod 'slow-start' exists"
    Q7_POD_SCORE=1

    # Check startup probe
    STARTUP_PATH=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.spec.containers[0].startupProbe.httpGet.path}' 2>/dev/null)
    STARTUP_PORT=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.spec.containers[0].startupProbe.httpGet.port}' 2>/dev/null)
    STARTUP_THRESHOLD=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null)

    if [[ "$STARTUP_PATH" == "/" ]] && [[ "$STARTUP_PORT" == "80" ]] && [[ "$STARTUP_THRESHOLD" == "30" ]]; then
        echo "✅ PASS: Startup probe configured correctly"
        Q7_STARTUP_SCORE=2
    else
        echo "❌ FAIL: Startup probe not correctly configured (path: $STARTUP_PATH, port: $STARTUP_PORT, threshold: $STARTUP_THRESHOLD)"
        Q7_STARTUP_SCORE=0
    fi

    # Check liveness probe
    LIVENESS_PATH=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
    LIVENESS_PORT=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null)

    if [[ "$LIVENESS_PATH" == "/" ]] && [[ "$LIVENESS_PORT" == "80" ]]; then
        echo "✅ PASS: Liveness probe configured"
        Q7_LIVENESS_SCORE=1
    else
        echo "❌ FAIL: Liveness probe not correctly configured"
        Q7_LIVENESS_SCORE=0
    fi

    # Check pod is running
    POD_STATUS=$(kubectl get pod slow-start -n startup-probe -o jsonpath='{.status.phase}' 2>/dev/null)

    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "✅ PASS: Pod is running"
        Q7_RUNNING_SCORE=0
    else
        echo "⚠️  PARTIAL: Pod status is '$POD_STATUS'"
        Q7_RUNNING_SCORE=0
    fi
fi

Q7_TOTAL=$((Q7_POD_SCORE + Q7_STARTUP_SCORE + Q7_LIVENESS_SCORE + Q7_RUNNING_SCORE))
echo "Question 7 Score: $Q7_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q7_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))
# Evaluation for Question 7 ends

# Evaluation for Question 8 starts
echo "=== Evaluating Question 8: Pod Disruption Budget ==="

PDB_NAME=$(kubectl get pdb critical-pdb -n pdb -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$PDB_NAME" ]]; then
    echo "❌ FAIL: PodDisruptionBudget 'critical-pdb' does not exist in namespace 'pdb'"
    Q8_PDB_SCORE=0
    Q8_MINAVAILABLE_SCORE=0
    Q8_SELECTOR_SCORE=0
    Q8_FILE_SCORE=0
else
    echo "✅ PASS: PodDisruptionBudget 'critical-pdb' exists"
    Q8_PDB_SCORE=1

    # Check minAvailable
    MIN_AVAILABLE=$(kubectl get pdb critical-pdb -n pdb -o jsonpath='{.spec.minAvailable}' 2>/dev/null)

    if [[ "$MIN_AVAILABLE" == "2" ]]; then
        echo "✅ PASS: minAvailable set to 2"
        Q8_MINAVAILABLE_SCORE=2
    else
        echo "❌ FAIL: minAvailable is '$MIN_AVAILABLE' (expected: 2)"
        Q8_MINAVAILABLE_SCORE=0
    fi

    # Check selector
    SELECTOR=$(kubectl get pdb critical-pdb -n pdb -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)

    if [[ "$SELECTOR" == "critical" ]]; then
        echo "✅ PASS: Selector matches app=critical"
        Q8_SELECTOR_SCORE=1
    else
        echo "❌ FAIL: Selector is '$SELECTOR' (expected: critical)"
        Q8_SELECTOR_SCORE=0
    fi

    # Check output file
    FILE_PATH="/opt/KDPDB00101/pdb-status.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        echo "✅ PASS: PDB status output file exists"
        Q8_FILE_SCORE=1
    else
        echo "❌ FAIL: PDB status output file is empty or doesn't exist"
        Q8_FILE_SCORE=0
    fi
fi

Q8_TOTAL=$((Q8_PDB_SCORE + Q8_MINAVAILABLE_SCORE + Q8_SELECTOR_SCORE + Q8_FILE_SCORE))
echo "Question 8 Score: $Q8_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q8_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 8 ends

# Evaluation for Question 9 starts
echo "=== Evaluating Question 9: Priority Classes ==="

HIGH_PRIORITY=$(kubectl get priorityclass high-priority -o jsonpath='{.value}' 2>/dev/null)
LOW_PRIORITY=$(kubectl get priorityclass low-priority -o jsonpath='{.value}' 2>/dev/null)

if [[ -z "$HIGH_PRIORITY" ]]; then
    echo "❌ FAIL: PriorityClass 'high-priority' does not exist"
    Q9_HIGH_SCORE=0
else
    if [[ "$HIGH_PRIORITY" == "1000000" ]]; then
        echo "✅ PASS: high-priority class with value 1000000"
        Q9_HIGH_SCORE=1
    else
        echo "❌ FAIL: high-priority value is '$HIGH_PRIORITY' (expected: 1000000)"
        Q9_HIGH_SCORE=0
    fi
fi

if [[ -z "$LOW_PRIORITY" ]]; then
    echo "❌ FAIL: PriorityClass 'low-priority' does not exist"
    Q9_LOW_SCORE=0
else
    if [[ "$LOW_PRIORITY" == "100" ]]; then
        echo "✅ PASS: low-priority class with value 100"
        Q9_LOW_SCORE=1
    else
        echo "❌ FAIL: low-priority value is '$LOW_PRIORITY' (expected: 100)"
        Q9_LOW_SCORE=0
    fi
fi

# Check pod with priority class
POD_PRIORITY=$(kubectl get pod critical-pod -n priority -o jsonpath='{.spec.priorityClassName}' 2>/dev/null)

if [[ "$POD_PRIORITY" == "high-priority" ]]; then
    echo "✅ PASS: Pod 'critical-pod' uses high-priority class"
    Q9_POD_SCORE=2
else
    echo "❌ FAIL: Pod priority class is '$POD_PRIORITY' (expected: high-priority)"
    Q9_POD_SCORE=0
fi

# Check output file
FILE_PATH="/opt/KDPRI00101/priorities.txt"
if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
    echo "✅ PASS: Priorities output file exists"
    Q9_FILE_SCORE=1
else
    echo "❌ FAIL: Priorities output file is empty or doesn't exist"
    Q9_FILE_SCORE=0
fi

Q9_TOTAL=$((Q9_HIGH_SCORE + Q9_LOW_SCORE + Q9_POD_SCORE + Q9_FILE_SCORE))
echo "Question 9 Score: $Q9_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q9_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 9 ends

# Evaluation for Question 10 starts
echo "=== Evaluating Question 10: Projected Volumes ==="

POD_NAME=$(kubectl get pod projected-pod -n projected -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'projected-pod' does not exist in namespace 'projected'"
    Q10_POD_SCORE=0
    Q10_VOLUME_SCORE=0
    Q10_CONFIGMAP_SCORE=0
    Q10_SECRET_SCORE=0
    Q10_DOWNWARD_SCORE=0
else
    echo "✅ PASS: Pod 'projected-pod' exists"
    Q10_POD_SCORE=1

    # Check projected volume mount
    MOUNT_PATH=$(kubectl get pod projected-pod -n projected -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/projected")].mountPath}' 2>/dev/null)

    if [[ "$MOUNT_PATH" == "/etc/projected" ]]; then
        echo "✅ PASS: Volume mounted at /etc/projected"
        Q10_VOLUME_SCORE=1
    else
        echo "❌ FAIL: Volume not mounted at /etc/projected"
        Q10_VOLUME_SCORE=0
    fi

    # Check projected volume sources
    VOLUME_JSON=$(kubectl get pod projected-pod -n projected -o jsonpath='{.spec.volumes[0].projected.sources}' 2>/dev/null)

    if echo "$VOLUME_JSON" | grep -q "configMap"; then
        echo "✅ PASS: ConfigMap source in projected volume"
        Q10_CONFIGMAP_SCORE=1
    else
        echo "❌ FAIL: ConfigMap not in projected volume"
        Q10_CONFIGMAP_SCORE=0
    fi

    if echo "$VOLUME_JSON" | grep -q "secret"; then
        echo "✅ PASS: Secret source in projected volume"
        Q10_SECRET_SCORE=1
    else
        echo "❌ FAIL: Secret not in projected volume"
        Q10_SECRET_SCORE=0
    fi

    if echo "$VOLUME_JSON" | grep -q "downwardAPI"; then
        echo "✅ PASS: downwardAPI source in projected volume"
        Q10_DOWNWARD_SCORE=1
    else
        echo "❌ FAIL: downwardAPI not in projected volume"
        Q10_DOWNWARD_SCORE=0
    fi
fi

Q10_TOTAL=$((Q10_POD_SCORE + Q10_VOLUME_SCORE + Q10_CONFIGMAP_SCORE + Q10_SECRET_SCORE + Q10_DOWNWARD_SCORE))
echo "Question 10 Score: $Q10_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q10_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 10 ends

# Evaluation for Question 11 starts
echo "=== Evaluating Question 11: EmptyDir with sizeLimit ==="

POD_NAME=$(kubectl get pod memory-pod -n emptydir -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'memory-pod' does not exist in namespace 'emptydir'"
    Q11_POD_SCORE=0
    Q11_MEDIUM_SCORE=0
    Q11_LIMIT_SCORE=0
    Q11_MOUNT_SCORE=0
else
    echo "✅ PASS: Pod 'memory-pod' exists"
    Q11_POD_SCORE=1

    # Check medium
    MEDIUM=$(kubectl get pod memory-pod -n emptydir -o jsonpath='{.spec.volumes[0].emptyDir.medium}' 2>/dev/null)

    if [[ "$MEDIUM" == "Memory" ]]; then
        echo "✅ PASS: emptyDir medium set to Memory"
        Q11_MEDIUM_SCORE=1
    else
        echo "❌ FAIL: emptyDir medium is '$MEDIUM' (expected: Memory)"
        Q11_MEDIUM_SCORE=0
    fi

    # Check sizeLimit
    SIZE_LIMIT=$(kubectl get pod memory-pod -n emptydir -o jsonpath='{.spec.volumes[0].emptyDir.sizeLimit}' 2>/dev/null)

    if [[ "$SIZE_LIMIT" == "64Mi" ]]; then
        echo "✅ PASS: sizeLimit set to 64Mi"
        Q11_LIMIT_SCORE=1
    else
        echo "❌ FAIL: sizeLimit is '$SIZE_LIMIT' (expected: 64Mi)"
        Q11_LIMIT_SCORE=0
    fi

    # Check mount path
    MOUNT_PATH=$(kubectl get pod memory-pod -n emptydir -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/cache")].mountPath}' 2>/dev/null)

    if [[ "$MOUNT_PATH" == "/cache" ]]; then
        echo "✅ PASS: Volume mounted at /cache"
        Q11_MOUNT_SCORE=1
    else
        echo "❌ FAIL: Volume not mounted at /cache"
        Q11_MOUNT_SCORE=0
    fi
fi

Q11_TOTAL=$((Q11_POD_SCORE + Q11_MEDIUM_SCORE + Q11_LIMIT_SCORE + Q11_MOUNT_SCORE))
echo "Question 11 Score: $Q11_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q11_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))
# Evaluation for Question 11 ends

# Evaluation for Question 12 starts
echo "=== Evaluating Question 12: Ephemeral Containers ==="

# Check command file
CMD_FILE="/opt/KDEPH00101/debug-command.txt"
PROCESS_FILE="/opt/KDEPH00101/process-list.txt"

Q12_CMD_SCORE=0
Q12_PROCESS_SCORE=0
Q12_EPHEMERAL_SCORE=0

# Check if ephemeral container was added or debug copy created
EPHEMERAL=$(kubectl get pod target-pod -n debug -o jsonpath='{.spec.ephemeralContainers}' 2>/dev/null)
DEBUG_POD=$(kubectl get pod -n debug -l run=target-pod-debug 2>/dev/null | grep -c "Running" || echo "0")

if [[ ! -z "$EPHEMERAL" ]] || [[ "$DEBUG_POD" -gt 0 ]]; then
    echo "✅ PASS: Debug container/pod created"
    Q12_EPHEMERAL_SCORE=3
else
    echo "❌ FAIL: No ephemeral container or debug pod found"
    Q12_EPHEMERAL_SCORE=0
fi

if [[ -f "$CMD_FILE" ]] && [[ -s "$CMD_FILE" ]]; then
    if grep -qi "kubectl debug" "$CMD_FILE"; then
        echo "✅ PASS: Debug command documented"
        Q12_CMD_SCORE=2
    else
        echo "⚠️  PARTIAL: Command file exists but doesn't contain kubectl debug"
        Q12_CMD_SCORE=1
    fi
else
    echo "❌ FAIL: Debug command file is empty or doesn't exist"
    Q12_CMD_SCORE=0
fi

if [[ -f "$PROCESS_FILE" ]] && [[ -s "$PROCESS_FILE" ]]; then
    echo "✅ PASS: Process list file exists"
    Q12_PROCESS_SCORE=1
else
    echo "❌ FAIL: Process list file is empty or doesn't exist"
    Q12_PROCESS_SCORE=0
fi

Q12_TOTAL=$((Q12_EPHEMERAL_SCORE + Q12_CMD_SCORE + Q12_PROCESS_SCORE))
echo "Question 12 Score: $Q12_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q12_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))
# Evaluation for Question 12 ends

# Evaluation for Question 13 starts
echo "=== Evaluating Question 13: Canary Deployment ==="

STABLE_DEPLOY=$(kubectl get deployment app-stable -n canary -o jsonpath='{.metadata.name}' 2>/dev/null)
CANARY_DEPLOY=$(kubectl get deployment app-canary -n canary -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$STABLE_DEPLOY" ]]; then
    echo "❌ FAIL: Deployment 'app-stable' does not exist"
    Q13_STABLE_SCORE=0
else
    STABLE_REPLICAS=$(kubectl get deployment app-stable -n canary -o jsonpath='{.spec.replicas}' 2>/dev/null)
    STABLE_LABEL=$(kubectl get deployment app-stable -n canary -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)

    if [[ "$STABLE_REPLICAS" == "3" ]] && [[ "$STABLE_LABEL" == "myapp" ]]; then
        echo "✅ PASS: app-stable deployment correct (3 replicas, app=myapp)"
        Q13_STABLE_SCORE=2
    else
        echo "❌ FAIL: app-stable not correctly configured"
        Q13_STABLE_SCORE=0
    fi
fi

if [[ -z "$CANARY_DEPLOY" ]]; then
    echo "❌ FAIL: Deployment 'app-canary' does not exist"
    Q13_CANARY_SCORE=0
else
    CANARY_REPLICAS=$(kubectl get deployment app-canary -n canary -o jsonpath='{.spec.replicas}' 2>/dev/null)
    CANARY_LABEL=$(kubectl get deployment app-canary -n canary -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)

    if [[ "$CANARY_REPLICAS" == "1" ]] && [[ "$CANARY_LABEL" == "myapp" ]]; then
        echo "✅ PASS: app-canary deployment correct (1 replica, app=myapp)"
        Q13_CANARY_SCORE=1
    else
        echo "❌ FAIL: app-canary not correctly configured"
        Q13_CANARY_SCORE=0
    fi
fi

# Check service
SERVICE=$(kubectl get service myapp-service -n canary -o jsonpath='{.spec.selector.app}' 2>/dev/null)

if [[ "$SERVICE" == "myapp" ]]; then
    echo "✅ PASS: Service selects app=myapp (routes to both deployments)"
    Q13_SERVICE_SCORE=2
else
    echo "❌ FAIL: Service selector is '$SERVICE' (expected: myapp)"
    Q13_SERVICE_SCORE=0
fi

Q13_TOTAL=$((Q13_STABLE_SCORE + Q13_CANARY_SCORE + Q13_SERVICE_SCORE))
echo "Question 13 Score: $Q13_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q13_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 13 ends

# Evaluation for Question 14 starts
echo "=== Evaluating Question 14: Service Troubleshooting ==="

# Check if service has endpoints now
ENDPOINTS=$(kubectl get endpoints web-service -n svc-debug -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)

if [[ ! -z "$ENDPOINTS" ]]; then
    echo "✅ PASS: Service 'web-service' has endpoints"
    Q14_FIX_SCORE=2
else
    echo "❌ FAIL: Service still has no endpoints"
    Q14_FIX_SCORE=0
fi

# Check service selector
SELECTOR=$(kubectl get service web-service -n svc-debug -o jsonpath='{.spec.selector.app}' 2>/dev/null)

if [[ "$SELECTOR" == "web-app" ]]; then
    echo "✅ PASS: Service selector is now correct (app=web-app)"
    Q14_SELECTOR_SCORE=1
else
    echo "❌ FAIL: Service selector is '$SELECTOR' (expected: web-app)"
    Q14_SELECTOR_SCORE=0
fi

# Check issue file
ISSUE_FILE="/opt/KDSVC00101/issue.txt"
if [[ -f "$ISSUE_FILE" ]] && [[ -s "$ISSUE_FILE" ]]; then
    echo "✅ PASS: Issue documented"
    Q14_ISSUE_SCORE=1
else
    echo "❌ FAIL: Issue file is empty or doesn't exist"
    Q14_ISSUE_SCORE=0
fi

# Check endpoints file
ENDPOINTS_FILE="/opt/KDSVC00101/endpoints.txt"
if [[ -f "$ENDPOINTS_FILE" ]] && [[ -s "$ENDPOINTS_FILE" ]]; then
    echo "✅ PASS: Endpoints output documented"
    Q14_ENDPOINTS_SCORE=1
else
    echo "❌ FAIL: Endpoints file is empty or doesn't exist"
    Q14_ENDPOINTS_SCORE=0
fi

Q14_TOTAL=$((Q14_FIX_SCORE + Q14_SELECTOR_SCORE + Q14_ISSUE_SCORE + Q14_ENDPOINTS_SCORE))
echo "Question 14 Score: $Q14_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q14_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 14 ends

# Evaluation for Question 15 starts
echo "=== Evaluating Question 15: Complex Network Policy ==="

FRONTEND_POLICY=$(kubectl get networkpolicy frontend-policy -n netpol-tiers -o jsonpath='{.metadata.name}' 2>/dev/null)
BACKEND_POLICY=$(kubectl get networkpolicy backend-policy -n netpol-tiers -o jsonpath='{.metadata.name}' 2>/dev/null)
DATABASE_POLICY=$(kubectl get networkpolicy database-policy -n netpol-tiers -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$FRONTEND_POLICY" ]]; then
    echo "❌ FAIL: NetworkPolicy 'frontend-policy' does not exist"
    Q15_FRONTEND_SCORE=0
else
    # Check frontend policy targets tier=frontend
    FRONTEND_SELECTOR=$(kubectl get networkpolicy frontend-policy -n netpol-tiers -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
    if [[ "$FRONTEND_SELECTOR" == "frontend" ]]; then
        echo "✅ PASS: frontend-policy targets tier=frontend"
        Q15_FRONTEND_SCORE=2
    else
        echo "❌ FAIL: frontend-policy selector is '$FRONTEND_SELECTOR'"
        Q15_FRONTEND_SCORE=0
    fi
fi

if [[ -z "$BACKEND_POLICY" ]]; then
    echo "❌ FAIL: NetworkPolicy 'backend-policy' does not exist"
    Q15_BACKEND_SCORE=0
else
    BACKEND_SELECTOR=$(kubectl get networkpolicy backend-policy -n netpol-tiers -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
    if [[ "$BACKEND_SELECTOR" == "backend" ]]; then
        echo "✅ PASS: backend-policy targets tier=backend"
        Q15_BACKEND_SCORE=2
    else
        echo "❌ FAIL: backend-policy selector is '$BACKEND_SELECTOR'"
        Q15_BACKEND_SCORE=0
    fi
fi

if [[ -z "$DATABASE_POLICY" ]]; then
    echo "❌ FAIL: NetworkPolicy 'database-policy' does not exist"
    Q15_DATABASE_SCORE=0
else
    DATABASE_SELECTOR=$(kubectl get networkpolicy database-policy -n netpol-tiers -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
    # Check egress denied (empty egress or policyTypes includes Egress with no egress rules)
    EGRESS_RULES=$(kubectl get networkpolicy database-policy -n netpol-tiers -o jsonpath='{.spec.egress}' 2>/dev/null)

    if [[ "$DATABASE_SELECTOR" == "database" ]] && [[ -z "$EGRESS_RULES" || "$EGRESS_RULES" == "[]" ]]; then
        echo "✅ PASS: database-policy targets tier=database with egress denied"
        Q15_DATABASE_SCORE=3
    else
        echo "⚠️  PARTIAL: database-policy exists but may not be correctly configured"
        Q15_DATABASE_SCORE=1
    fi
fi

Q15_TOTAL=$((Q15_FRONTEND_SCORE + Q15_BACKEND_SCORE + Q15_DATABASE_SCORE))
echo "Question 15 Score: $Q15_TOTAL/7"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q15_TOTAL))
MAX_SCORE=$((MAX_SCORE + 7))
# Evaluation for Question 15 ends

# Evaluation for Question 16 starts
echo "=== Evaluating Question 16: Deployment Strategy - Recreate ==="

DEPLOYMENT=$(kubectl get deployment legacy-app -n recreate -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT" ]]; then
    echo "❌ FAIL: Deployment 'legacy-app' does not exist"
    Q16_DEPLOY_SCORE=0
    Q16_STRATEGY_SCORE=0
    Q16_IMAGE_SCORE=0
    Q16_FILE_SCORE=0
else
    echo "✅ PASS: Deployment 'legacy-app' exists"
    Q16_DEPLOY_SCORE=1

    # Check strategy
    STRATEGY=$(kubectl get deployment legacy-app -n recreate -o jsonpath='{.spec.strategy.type}' 2>/dev/null)

    if [[ "$STRATEGY" == "Recreate" ]]; then
        echo "✅ PASS: Strategy changed to Recreate"
        Q16_STRATEGY_SCORE=1
    else
        echo "❌ FAIL: Strategy is '$STRATEGY' (expected: Recreate)"
        Q16_STRATEGY_SCORE=0
    fi

    # Check image updated
    IMAGE=$(kubectl get deployment legacy-app -n recreate -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

    if [[ "$IMAGE" == "nginx:1.25" ]]; then
        echo "✅ PASS: Image updated to nginx:1.25"
        Q16_IMAGE_SCORE=1
    else
        echo "❌ FAIL: Image is '$IMAGE' (expected: nginx:1.25)"
        Q16_IMAGE_SCORE=0
    fi

    # Check behavior file
    FILE_PATH="/opt/KDDEP00101/update-behavior.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        echo "✅ PASS: Update behavior documented"
        Q16_FILE_SCORE=1
    else
        echo "❌ FAIL: Behavior file is empty or doesn't exist"
        Q16_FILE_SCORE=0
    fi
fi

Q16_TOTAL=$((Q16_DEPLOY_SCORE + Q16_STRATEGY_SCORE + Q16_IMAGE_SCORE + Q16_FILE_SCORE))
echo "Question 16 Score: $Q16_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q16_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))
# Evaluation for Question 16 ends

# Evaluation for Question 17 starts
echo "=== Evaluating Question 17: Combined Probes Troubleshooting ==="

POD_NAME=$(kubectl get pod broken-probe -n probe-fix -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'broken-probe' does not exist"
    Q17_POD_SCORE=0
    Q17_FIX_SCORE=0
    Q17_FILE_SCORE=0
else
    # Check if pod is running (fix applied)
    POD_STATUS=$(kubectl get pod broken-probe -n probe-fix -o jsonpath='{.status.phase}' 2>/dev/null)
    POD_READY=$(kubectl get pod broken-probe -n probe-fix -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)

    if [[ "$POD_STATUS" == "Running" ]] && [[ "$POD_READY" == "True" ]]; then
        echo "✅ PASS: Pod is running and ready (probes fixed)"
        Q17_POD_SCORE=2
        Q17_FIX_SCORE=2
    else
        echo "❌ FAIL: Pod still not running/ready (status: $POD_STATUS, ready: $POD_READY)"
        Q17_POD_SCORE=0
        Q17_FIX_SCORE=0
    fi

    # Check fix description file
    FILE_PATH="/opt/KDCOMB00101/fix-description.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        echo "✅ PASS: Fix description documented"
        Q17_FILE_SCORE=1
    else
        echo "❌ FAIL: Fix description file is empty or doesn't exist"
        Q17_FILE_SCORE=0
    fi
fi

Q17_TOTAL=$((Q17_POD_SCORE + Q17_FIX_SCORE + Q17_FILE_SCORE))
echo "Question 17 Score: $Q17_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q17_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))
# Evaluation for Question 17 ends

# Evaluation for Question 18 starts
echo "=== Evaluating Question 18: Multi-issue Pod Debugging ==="

DEPLOYMENT=$(kubectl get deployment buggy-app -n multi-debug -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT" ]]; then
    echo "❌ FAIL: Deployment 'buggy-app' does not exist"
    Q18_DEPLOY_SCORE=0
    Q18_RUNNING_SCORE=0
    Q18_FILE_SCORE=0
else
    echo "✅ PASS: Deployment 'buggy-app' exists"
    Q18_DEPLOY_SCORE=1

    # Check if pods are running
    READY_REPLICAS=$(kubectl get deployment buggy-app -n multi-debug -o jsonpath='{.status.readyReplicas}' 2>/dev/null)

    if [[ "$READY_REPLICAS" == "2" ]]; then
        echo "✅ PASS: All 2 replicas running (all issues fixed)"
        Q18_RUNNING_SCORE=4
    else
        echo "❌ FAIL: Only $READY_REPLICAS replicas ready (expected: 2)"
        Q18_RUNNING_SCORE=0
    fi

    # Check issues file
    FILE_PATH="/opt/KDDEBUG00101/issues-found.txt"
    if [[ -f "$FILE_PATH" ]] && [[ -s "$FILE_PATH" ]]; then
        ISSUE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
        if [[ "$ISSUE_COUNT" -ge 4 ]]; then
            echo "✅ PASS: All issues documented ($ISSUE_COUNT issues)"
            Q18_FILE_SCORE=2
        else
            echo "⚠️  PARTIAL: Only $ISSUE_COUNT issues documented (expected: 4)"
            Q18_FILE_SCORE=1
        fi
    else
        echo "❌ FAIL: Issues file is empty or doesn't exist"
        Q18_FILE_SCORE=0
    fi
fi

Q18_TOTAL=$((Q18_DEPLOY_SCORE + Q18_RUNNING_SCORE + Q18_FILE_SCORE))
echo "Question 18 Score: $Q18_TOTAL/7"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q18_TOTAL))
MAX_SCORE=$((MAX_SCORE + 7))
# Evaluation for Question 18 ends

# Evaluation for Question 19 starts
echo "=== Evaluating Question 19: kubectl Custom Columns ==="

# Check pod report file
POD_REPORT="/opt/KDCLI00201/pod-report.txt"
if [[ -f "$POD_REPORT" ]] && [[ -s "$POD_REPORT" ]]; then
    if grep -q "NAME" "$POD_REPORT" && grep -q "NODE" "$POD_REPORT"; then
        echo "✅ PASS: Pod report with custom columns exists"
        Q19_REPORT_SCORE=2
    else
        echo "⚠️  PARTIAL: Pod report exists but may not have correct columns"
        Q19_REPORT_SCORE=1
    fi
else
    echo "❌ FAIL: Pod report file is empty or doesn't exist"
    Q19_REPORT_SCORE=0
fi

# Check restarts file
RESTARTS_FILE="/opt/KDCLI00201/restarts.txt"
if [[ -f "$RESTARTS_FILE" ]]; then
    echo "✅ PASS: Restarts report exists"
    Q19_RESTARTS_SCORE=1
else
    echo "❌ FAIL: Restarts file doesn't exist"
    Q19_RESTARTS_SCORE=0
fi

# Check node capacity file
NODE_FILE="/opt/KDCLI00201/node-capacity.txt"
if [[ -f "$NODE_FILE" ]] && [[ -s "$NODE_FILE" ]]; then
    if grep -q "cpu=" "$NODE_FILE" || grep -q "memory=" "$NODE_FILE"; then
        echo "✅ PASS: Node capacity report with correct format"
        Q19_NODE_SCORE=1
    else
        echo "⚠️  PARTIAL: Node capacity file exists but may not have correct format"
        Q19_NODE_SCORE=0
    fi
else
    echo "❌ FAIL: Node capacity file is empty or doesn't exist"
    Q19_NODE_SCORE=0
fi

Q19_TOTAL=$((Q19_REPORT_SCORE + Q19_RESTARTS_SCORE + Q19_NODE_SCORE))
echo "Question 19 Score: $Q19_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q19_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))
# Evaluation for Question 19 ends

# Evaluation for Question 20 starts
echo "=== Evaluating Question 20: Comprehensive Scenario ==="

# Check deployment exists
DEPLOYMENT=$(kubectl get deployment production-app -n production -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT" ]]; then
    echo "❌ FAIL: Deployment 'production-app' does not exist"
    Q20_DEPLOY_SCORE=0
    Q20_INIT_SCORE=0
    Q20_SECURITY_SCORE=0
    Q20_RESOURCES_SCORE=0
    Q20_PROBES_SCORE=0
    Q20_PDB_SCORE=0
    Q20_SERVICE_SCORE=0
    Q20_CONFIGMAP_SCORE=0
else
    echo "✅ PASS: Deployment 'production-app' exists"
    Q20_DEPLOY_SCORE=1

    # Check init container
    INIT_COUNT=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.initContainers}' 2>/dev/null | grep -c "name" || echo "0")
    if [[ "$INIT_COUNT" -gt 0 ]]; then
        echo "✅ PASS: Init container configured"
        Q20_INIT_SCORE=1
    else
        echo "❌ FAIL: No init container found"
        Q20_INIT_SCORE=0
    fi

    # Check security context
    RUN_AS_USER=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
    RUN_AS_NON_ROOT=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.securityContext.runAsNonRoot}' 2>/dev/null)

    if [[ "$RUN_AS_USER" == "1000" ]] || [[ "$RUN_AS_NON_ROOT" == "true" ]]; then
        echo "✅ PASS: Security context configured"
        Q20_SECURITY_SCORE=1
    else
        echo "❌ FAIL: Security context not properly configured"
        Q20_SECURITY_SCORE=0
    fi

    # Check resources
    CPU_REQUEST=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
    if [[ ! -z "$CPU_REQUEST" ]]; then
        echo "✅ PASS: Resource requests configured"
        Q20_RESOURCES_SCORE=1
    else
        echo "❌ FAIL: Resource requests not configured"
        Q20_RESOURCES_SCORE=0
    fi

    # Check probes
    STARTUP=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.containers[0].startupProbe}' 2>/dev/null)
    LIVENESS=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' 2>/dev/null)
    READINESS=$(kubectl get deployment production-app -n production -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)

    PROBE_COUNT=0
    [[ ! -z "$STARTUP" ]] && PROBE_COUNT=$((PROBE_COUNT + 1))
    [[ ! -z "$LIVENESS" ]] && PROBE_COUNT=$((PROBE_COUNT + 1))
    [[ ! -z "$READINESS" ]] && PROBE_COUNT=$((PROBE_COUNT + 1))

    if [[ "$PROBE_COUNT" -eq 3 ]]; then
        echo "✅ PASS: All three probes configured"
        Q20_PROBES_SCORE=1
    else
        echo "⚠️  PARTIAL: Only $PROBE_COUNT/3 probes configured"
        Q20_PROBES_SCORE=0
    fi

    # Check PDB
    PDB=$(kubectl get pdb production-pdb -n production -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [[ "$PDB" == "production-pdb" ]]; then
        echo "✅ PASS: PodDisruptionBudget exists"
        Q20_PDB_SCORE=1
    else
        echo "❌ FAIL: PodDisruptionBudget 'production-pdb' not found"
        Q20_PDB_SCORE=0
    fi

    # Check service
    SERVICE=$(kubectl get service production-service -n production -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [[ "$SERVICE" == "production-service" ]]; then
        echo "✅ PASS: Service 'production-service' exists"
        Q20_SERVICE_SCORE=1
    else
        echo "❌ FAIL: Service 'production-service' not found"
        Q20_SERVICE_SCORE=0
    fi

    # Check ConfigMap
    CONFIGMAP=$(kubectl get configmap app-config -n production -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [[ "$CONFIGMAP" == "app-config" ]]; then
        echo "✅ PASS: ConfigMap 'app-config' exists"
        Q20_CONFIGMAP_SCORE=1
    else
        echo "❌ FAIL: ConfigMap 'app-config' not found"
        Q20_CONFIGMAP_SCORE=0
    fi
fi

Q20_TOTAL=$((Q20_DEPLOY_SCORE + Q20_INIT_SCORE + Q20_SECURITY_SCORE + Q20_RESOURCES_SCORE + Q20_PROBES_SCORE + Q20_PDB_SCORE + Q20_SERVICE_SCORE + Q20_CONFIGMAP_SCORE))
echo "Question 20 Score: $Q20_TOTAL/8"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q20_TOTAL))
MAX_SCORE=$((MAX_SCORE + 8))
# Evaluation for Question 20 ends

# Final Score Summary
echo "========================================"
if [[ "$MAX_SCORE" -gt 0 ]]; then
    PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))
else
    PERCENTAGE=0
fi

echo "TOTAL SCORE: $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)"
echo "========================================"

if [[ "$PERCENTAGE" -ge 66 ]]; then
    echo "RESULT: PASS (66% required)"
else
    echo "RESULT: FAIL (66% required)"
fi
echo "========================================"
