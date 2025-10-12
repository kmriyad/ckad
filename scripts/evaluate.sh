#!/usr/bin/env bash
########################################
# This script evaluates the student's response to questions that asked in questions.md
# It checks for the existence and correctness of answers in the file, files, directories, and Kubernetes resources.
#########################################

# Initialize score tracking
TOTAL_SCORE=0
MAX_SCORE=0

# Evaluation for Question 1 starts

echo "=== Evaluating Question 1 ==="

# Check if the counter pod exists and is running
POD_NAME=$(kubectl get pod counter-pod -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod counter-pod -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'counter-pod' does not exist"
    Q1_POD_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'counter-pod' exists but is not running (status: $POD_STATUS)"
    Q1_POD_SCORE=0
else
    echo "✅ PASS: Pod 'counter-pod' is running"
    Q1_POD_SCORE=1
fi

# Check if the log output file exists and contains logs
LOG_FILE="/opt/KDOB00201/log_output.txt"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "❌ FAIL: Log file $LOG_FILE does not exist"
    Q1_LOG_SCORE=0
elif [[ ! -s "$LOG_FILE" ]]; then
    echo "❌ FAIL: Log file $LOG_FILE is empty"
    Q1_LOG_SCORE=0
elif grep -q "Counter:" "$LOG_FILE"; then
    echo "✅ PASS: Log file contains expected counter output"
    Q1_LOG_SCORE=1
else
    echo "❌ FAIL: Log file exists but does not contain expected 'Counter:' pattern"
    Q1_LOG_SCORE=0
fi

Q1_TOTAL=$((Q1_POD_SCORE + Q1_LOG_SCORE))
echo "Question 1 Score: $Q1_TOTAL/2"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q1_TOTAL))
MAX_SCORE=$((MAX_SCORE + 2))

# Evaluation for Question 1 ends

# Evaluation for Question 2 starts

echo "=== Evaluating Question 2 ==="

# Check if the cache pod exists in the web namespace
POD_NAME=$(kubectl get pod cache -n web -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod cache -n web -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'cache' does not exist in namespace 'web'"
    Q2_POD_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'cache' exists but is not running (status: $POD_STATUS)"
    Q2_POD_SCORE=0
else
    echo "✅ PASS: Pod 'cache' is running in namespace 'web'"
    Q2_POD_SCORE=1
fi

# Check if the correct image is used
POD_IMAGE=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

if [[ "$POD_IMAGE" == "lfccncf/redis:3.2" ]]; then
    echo "✅ PASS: Pod uses correct image: lfccncf/redis:3.2"
    Q2_IMAGE_SCORE=1
else
    echo "❌ FAIL: Pod uses incorrect image: $POD_IMAGE (expected: lfccncf/redis:3.2)"
    Q2_IMAGE_SCORE=0
fi

# Check if port 6379 is exposed
POD_PORT=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].ports[?(@.containerPort==6379)].containerPort}' 2>/dev/null)

if [[ "$POD_PORT" == "6379" ]]; then
    echo "✅ PASS: Port 6379 is exposed"
    Q2_PORT_SCORE=1
else
    echo "❌ FAIL: Port 6379 is not exposed"
    Q2_PORT_SCORE=0
fi

Q2_TOTAL=$((Q2_POD_SCORE + Q2_IMAGE_SCORE + Q2_PORT_SCORE))
echo "Question 2 Score: $Q2_TOTAL/3"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q2_TOTAL))
MAX_SCORE=$((MAX_SCORE + 3))

# Evaluation for Question 2 ends

# Evaluation for Question 3 starts

echo "=== Evaluating Question 3 ==="

# Check if the secret exists in qtn3 namespace
SECRET_NAME=$(kubectl get secret some-secret -n qtn3 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$SECRET_NAME" ]]; then
    echo "❌ FAIL: Secret 'some-secret' does not exist in namespace 'qtn3'"
    Q3_SECRET_SCORE=0
    Q3_SECRET_VALUE_SCORE=0
else
    echo "✅ PASS: Secret 'some-secret' exists in namespace 'qtn3'"
    Q3_SECRET_SCORE=1

    # Check if secret has the correct key/value pair
    SECRET_VALUE=$(kubectl get secret some-secret -n qtn3 -o jsonpath='{.data.key1}' 2>/dev/null | base64 -d 2>/dev/null)

    if [[ "$SECRET_VALUE" == "value4" ]]; then
        echo "✅ PASS: Secret contains correct key1=value4"
        Q3_SECRET_VALUE_SCORE=1
    else
        echo "❌ FAIL: Secret key1 has incorrect value: '$SECRET_VALUE' (expected: 'value4')"
        Q3_SECRET_VALUE_SCORE=0
    fi
fi

# Check if the pod exists and is running
POD_NAME=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'nginx-secret' does not exist in namespace 'qtn3'"
    Q3_POD_SCORE=0
    Q3_IMAGE_SCORE=0
    Q3_ENV_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'nginx-secret' exists but is not running (status: $POD_STATUS)"
    Q3_POD_SCORE=0
    Q3_IMAGE_SCORE=0
    Q3_ENV_SCORE=0
else
    echo "✅ PASS: Pod 'nginx-secret' is running in namespace 'qtn3'"
    Q3_POD_SCORE=1

    # Check if pod uses nginx image
    POD_IMAGE=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

    if [[ "$POD_IMAGE" == *"nginx"* ]]; then
        echo "✅ PASS: Pod uses nginx image: $POD_IMAGE"
        Q3_IMAGE_SCORE=1
    else
        echo "❌ FAIL: Pod uses incorrect image: $POD_IMAGE (expected: nginx)"
        Q3_IMAGE_SCORE=0
    fi

    # Check if environment variable is correctly configured
    ENV_VAR_NAME=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.spec.containers[0].env[?(@.name=="COOL_VARIABLE")].name}' 2>/dev/null)
    ENV_VAR_SOURCE=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.spec.containers[0].env[?(@.name=="COOL_VARIABLE")].valueFrom.secretKeyRef.name}' 2>/dev/null)
    ENV_VAR_KEY=$(kubectl get pod nginx-secret -n qtn3 -o jsonpath='{.spec.containers[0].env[?(@.name=="COOL_VARIABLE")].valueFrom.secretKeyRef.key}' 2>/dev/null)

    if [[ "$ENV_VAR_NAME" == "COOL_VARIABLE" ]] && [[ "$ENV_VAR_SOURCE" == "some-secret" ]] && [[ "$ENV_VAR_KEY" == "key1" ]]; then
        echo "✅ PASS: Environment variable COOL_VARIABLE correctly references secret key1"
        Q3_ENV_SCORE=1
    else
        echo "❌ FAIL: Environment variable COOL_VARIABLE not correctly configured"
        Q3_ENV_SCORE=0
    fi
fi

Q3_TOTAL=$((Q3_SECRET_SCORE + Q3_SECRET_VALUE_SCORE + Q3_POD_SCORE + Q3_IMAGE_SCORE + Q3_ENV_SCORE))
echo "Question 3 Score: $Q3_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q3_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 3 ends

# Evaluation for Question 4 starts

echo "=== Evaluating Question 4 ==="

# Check if the pod exists and is running
POD_NAME=$(kubectl get pod nginx-resources -n pod-resources -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod nginx-resources -n pod-resources -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'nginx-resources' does not exist in namespace 'pod-resources'"
    Q4_POD_SCORE=0
    Q4_IMAGE_SCORE=0
    Q4_CPU_SCORE=0
    Q4_MEMORY_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'nginx-resources' exists but is not running (status: $POD_STATUS)"
    Q4_POD_SCORE=0
    Q4_IMAGE_SCORE=0
    Q4_CPU_SCORE=0
    Q4_MEMORY_SCORE=0
else
    echo "✅ PASS: Pod 'nginx-resources' is running in namespace 'pod-resources'"
    Q4_POD_SCORE=1

    # Check if pod uses nginx image
    POD_IMAGE=$(kubectl get pod nginx-resources -n pod-resources -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

    if [[ "$POD_IMAGE" == *"nginx"* ]]; then
        echo "✅ PASS: Pod uses nginx image: $POD_IMAGE"
        Q4_IMAGE_SCORE=1
    else
        echo "❌ FAIL: Pod uses incorrect image: $POD_IMAGE (expected: nginx)"
        Q4_IMAGE_SCORE=0
    fi

    # Check CPU request
    CPU_REQUEST=$(kubectl get pod nginx-resources -n pod-resources -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)

    if [[ "$CPU_REQUEST" == "200m" ]]; then
        echo "✅ PASS: Pod requests 200m CPU"
        Q4_CPU_SCORE=1
    else
        echo "❌ FAIL: Pod CPU request is '$CPU_REQUEST' (expected: 200m)"
        Q4_CPU_SCORE=0
    fi

    # Check memory request
    MEMORY_REQUEST=$(kubectl get pod nginx-resources -n pod-resources -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)

    if [[ "$MEMORY_REQUEST" == "2Gi" ]]; then
        echo "✅ PASS: Pod requests 2Gi memory"
        Q4_MEMORY_SCORE=1
    else
        echo "❌ FAIL: Pod memory request is '$MEMORY_REQUEST' (expected: 2Gi)"
        Q4_MEMORY_SCORE=0
    fi
fi

Q4_TOTAL=$((Q4_POD_SCORE + Q4_IMAGE_SCORE + Q4_CPU_SCORE + Q4_MEMORY_SCORE))
echo "Question 4 Score: $Q4_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q4_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 4 ends

# Evaluation for Question 5 starts

echo "=== Evaluating Question 5 ==="

# Check if the ConfigMap exists in qtn5 namespace
CONFIGMAP_NAME=$(kubectl get configmap some-config -n qtn5 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$CONFIGMAP_NAME" ]]; then
    echo "❌ FAIL: ConfigMap 'some-config' does not exist in namespace 'qtn5'"
    Q5_CONFIGMAP_SCORE=0
    Q5_CONFIGMAP_VALUE_SCORE=0
else
    echo "✅ PASS: ConfigMap 'some-config' exists in namespace 'qtn5'"
    Q5_CONFIGMAP_SCORE=1

    # Check if ConfigMap has the correct key/value pair
    CONFIGMAP_VALUE=$(kubectl get configmap some-config -n qtn5 -o jsonpath='{.data.key4}' 2>/dev/null)

    if [[ "$CONFIGMAP_VALUE" == "value4" ]]; then
        echo "✅ PASS: ConfigMap contains correct key4=value4"
        Q5_CONFIGMAP_VALUE_SCORE=1
    else
        echo "❌ FAIL: ConfigMap key4 has incorrect value: '$CONFIGMAP_VALUE' (expected: 'value4')"
        Q5_CONFIGMAP_VALUE_SCORE=0
    fi
fi

# Check if the pod exists and is running
POD_NAME=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath='{.metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath='{.status.phase}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'nginx-configmap' does not exist in namespace 'qtn5'"
    Q5_POD_SCORE=0
    Q5_IMAGE_SCORE=0
    Q5_VOLUME_SCORE=0
elif [[ "$POD_STATUS" != "Running" ]]; then
    echo "⚠️  PARTIAL: Pod 'nginx-configmap' exists but is not running (status: $POD_STATUS)"
    Q5_POD_SCORE=0
    Q5_IMAGE_SCORE=0
    Q5_VOLUME_SCORE=0
else
    echo "✅ PASS: Pod 'nginx-configmap' is running in namespace 'qtn5'"
    Q5_POD_SCORE=1

    # Check if pod uses nginx image
    POD_IMAGE=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

    if [[ "$POD_IMAGE" == *"nginx"* ]]; then
        echo "✅ PASS: Pod uses nginx image: $POD_IMAGE"
        Q5_IMAGE_SCORE=1
    else
        echo "❌ FAIL: Pod uses incorrect image: $POD_IMAGE (expected: nginx)"
        Q5_IMAGE_SCORE=0
    fi

    # Check if volume mount exists at /yet/another/path
    VOLUME_MOUNT_PATH=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/yet/another/path")].mountPath}' 2>/dev/null)
    VOLUME_NAME=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/yet/another/path")].name}' 2>/dev/null)
    CONFIGMAP_VOLUME=$(kubectl get pod nginx-configmap -n qtn5 -o jsonpath="{.spec.volumes[?(@.name==\"$VOLUME_NAME\")].configMap.name}" 2>/dev/null)

    if [[ "$VOLUME_MOUNT_PATH" == "/yet/another/path" ]] && [[ "$CONFIGMAP_VOLUME" == "some-config" ]]; then
        echo "✅ PASS: ConfigMap 'some-config' mounted at /yet/another/path"
        Q5_VOLUME_SCORE=1
    else
        echo "❌ FAIL: ConfigMap not correctly mounted at /yet/another/path"
        Q5_VOLUME_SCORE=0
    fi
fi

Q5_TOTAL=$((Q5_CONFIGMAP_SCORE + Q5_CONFIGMAP_VALUE_SCORE + Q5_POD_SCORE + Q5_IMAGE_SCORE + Q5_VOLUME_SCORE))
echo "Question 5 Score: $Q5_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q5_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 5 ends

# Evaluation for Question 6 starts

echo "=== Evaluating Question 6 ==="

# Check if the deployment exists
DEPLOYMENT_NAME=$(kubectl get deployment appa -n frontend -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'appa' does not exist in namespace 'frontend'"
    Q6_DEPLOYMENT_SCORE=0
    Q6_SERVICE_ACCOUNT_SCORE=0
else
    echo "✅ PASS: Deployment 'appa' exists in namespace 'frontend'"
    Q6_DEPLOYMENT_SCORE=1

    # Check if the deployment is configured to use the restrictedservice service account
    SERVICE_ACCOUNT=$(kubectl get deployment appa -n frontend -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)

    if [[ "$SERVICE_ACCOUNT" == "restrictedservice" ]]; then
        echo "✅ PASS: Deployment configured to use service account 'restrictedservice'"
        Q6_SERVICE_ACCOUNT_SCORE=1
    else
        echo "❌ FAIL: Deployment not configured with correct service account (found: '$SERVICE_ACCOUNT', expected: 'restrictedservice')"
        Q6_SERVICE_ACCOUNT_SCORE=0
    fi
fi

Q6_TOTAL=$((Q6_DEPLOYMENT_SCORE + Q6_SERVICE_ACCOUNT_SCORE))
echo "Question 6 Score: $Q6_TOTAL/2"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q6_TOTAL))
MAX_SCORE=$((MAX_SCORE + 2))

# Evaluation for Question 6 ends

# Evaluation for Question 7 starts

echo "=== Evaluating Question 7 ==="

# Check if the pod exists
POD_NAME=$(kubectl get pod probe-http -n qtn7 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'probe-http' does not exist in namespace 'qtn7'"
    Q7_POD_SCORE=0
    Q7_LIVENESS_SCORE=0
    Q7_READINESS_SCORE=0
else
    echo "✅ PASS: Pod 'probe-http' exists in namespace 'qtn7'"
    Q7_POD_SCORE=1

    # Check liveness probe configuration (httpGet /healthz on port 8080)
    LIVENESS_PATH=$(kubectl get pod probe-http -n qtn7 -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
    LIVENESS_PORT=$(kubectl get pod probe-http -n qtn7 -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null)

    if [[ "$LIVENESS_PATH" == "/healthz" ]] && [[ "$LIVENESS_PORT" == "8080" ]]; then
        echo "✅ PASS: Liveness probe configured for /healthz on port 8080"
        Q7_LIVENESS_SCORE=1
    else
        echo "❌ FAIL: Liveness probe not correctly configured (path: '$LIVENESS_PATH', port: '$LIVENESS_PORT')"
        Q7_LIVENESS_SCORE=0
    fi

    # Check readiness probe configuration (httpGet /started on port 8080)
    READINESS_PATH=$(kubectl get pod probe-http -n qtn7 -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
    READINESS_PORT=$(kubectl get pod probe-http -n qtn7 -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)

    if [[ "$READINESS_PATH" == "/started" ]] && [[ "$READINESS_PORT" == "8080" ]]; then
        echo "✅ PASS: Readiness probe configured for /started on port 8080"
        Q7_READINESS_SCORE=1
    else
        echo "❌ FAIL: Readiness probe not correctly configured (path: '$READINESS_PATH', port: '$READINESS_PORT')"
        Q7_READINESS_SCORE=0
    fi
fi

Q7_TOTAL=$((Q7_POD_SCORE + Q7_LIVENESS_SCORE + Q7_READINESS_SCORE))
echo "Question 7 Score: $Q7_TOTAL/3"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q7_TOTAL))
MAX_SCORE=$((MAX_SCORE + 3))

# Evaluation for Question 7 ends

# Evaluation for Question 8 starts

echo "=== Evaluating Question 8 ==="

# Check if the file exists
FILE_PATH="/opt/KDOB00301/pod.txt"

if [[ ! -f "$FILE_PATH" ]]; then
    echo "❌ FAIL: File $FILE_PATH does not exist"
    Q8_FILE_SCORE=0
    Q8_CONTENT_SCORE=0
else
    echo "✅ PASS: File $FILE_PATH exists"
    Q8_FILE_SCORE=1

    # Check if the file contains the correct pod name
    FILE_CONTENT=$(cat "$FILE_PATH" | tr -d '[:space:]')

    if [[ "$FILE_CONTENT" == "stress-high" ]]; then
        echo "✅ PASS: File contains correct pod name 'stress-high'"
        Q8_CONTENT_SCORE=1
    else
        echo "❌ FAIL: File contains incorrect content: '$FILE_CONTENT' (expected: 'stress-high')"
        Q8_CONTENT_SCORE=0
    fi
fi

Q8_TOTAL=$((Q8_FILE_SCORE + Q8_CONTENT_SCORE))
echo "Question 8 Score: $Q8_TOTAL/2"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q8_TOTAL))
MAX_SCORE=$((MAX_SCORE + 2))

# Evaluation for Question 8 ends

# Evaluation for Question 9 starts

echo "=== Evaluating Question 9 ==="

# Check if the pod manifest file exists and has content
MANIFEST_FILE="/opt/KDPD00101/pod1.yml"

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "❌ FAIL: Pod manifest file $MANIFEST_FILE does not exist"
    Q9_MANIFEST_SCORE=0
elif [[ ! -s "$MANIFEST_FILE" ]]; then
    echo "❌ FAIL: Pod manifest file $MANIFEST_FILE is empty"
    Q9_MANIFEST_SCORE=0
else
    # Check if manifest contains required elements
    if grep -q "name: app1" "$MANIFEST_FILE" && \
       grep -q "name: app1cont" "$MANIFEST_FILE" && \
       grep -q "lfccncf/arg-output" "$MANIFEST_FILE" && \
       grep -q "\-Q" "$MANIFEST_FILE" && \
       grep -q "\--dep" "$MANIFEST_FILE" && \
       grep -q "test" "$MANIFEST_FILE"; then
        echo "✅ PASS: Pod manifest contains required elements"
        Q9_MANIFEST_SCORE=1
    else
        echo "❌ FAIL: Pod manifest missing required elements"
        Q9_MANIFEST_SCORE=0
    fi
fi

# Check if the pod exists (in default namespace since none specified)
POD_NAME=$(kubectl get pod app1 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'app1' does not exist"
    Q9_POD_SCORE=0
else
    echo "✅ PASS: Pod 'app1' exists"
    Q9_POD_SCORE=1
fi

# Check if the output JSON file exists and has content
OUTPUT_FILE="/opt/KDPD00101/out1.json"

if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "❌ FAIL: Output file $OUTPUT_FILE does not exist"
    Q9_OUTPUT_SCORE=0
elif [[ ! -s "$OUTPUT_FILE" ]]; then
    echo "❌ FAIL: Output file $OUTPUT_FILE is empty"
    Q9_OUTPUT_SCORE=0
else
    # Check if file contains valid JSON with pod name
    if grep -q '"name": "app1"' "$OUTPUT_FILE" || grep -q '"name":"app1"' "$OUTPUT_FILE"; then
        echo "✅ PASS: Output file contains pod information in JSON format"
        Q9_OUTPUT_SCORE=1
    else
        echo "❌ FAIL: Output file does not contain expected pod information"
        Q9_OUTPUT_SCORE=0
    fi
fi

Q9_TOTAL=$((Q9_MANIFEST_SCORE + Q9_POD_SCORE + Q9_OUTPUT_SCORE))
echo "Question 9 Score: $Q9_TOTAL/3"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q9_TOTAL))
MAX_SCORE=$((MAX_SCORE + 3))

# Evaluation for Question 9 ends

# Evaluation for Question 10 starts

echo "=== Evaluating Question 10 ==="

# Check if the deployment exists
DEPLOYMENT_NAME=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'nginx' does not exist in namespace 'kdpd00201'"
    Q10_DEPLOYMENT_SCORE=0
    Q10_REPLICAS_SCORE=0
    Q10_IMAGE_SCORE=0
    Q10_ENV_SCORE=0
    Q10_PORT_SCORE=0
else
    echo "✅ PASS: Deployment 'nginx' exists in namespace 'kdpd00201'"
    Q10_DEPLOYMENT_SCORE=1

    # Check replica count
    REPLICAS=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.spec.replicas}' 2>/dev/null)

    if [[ "$REPLICAS" == "3" ]]; then
        echo "✅ PASS: Deployment configured with 3 replicas"
        Q10_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: Deployment has $REPLICAS replicas (expected: 3)"
        Q10_REPLICAS_SCORE=0
    fi

    # Check image
    IMAGE=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

    if [[ "$IMAGE" == "lfccncf/nginx:1.12.2-alpine" ]]; then
        echo "✅ PASS: Deployment uses correct image: lfccncf/nginx:1.12.2-alpine"
        Q10_IMAGE_SCORE=1
    else
        echo "❌ FAIL: Deployment uses incorrect image: $IMAGE (expected: lfccncf/nginx:1.12.2-alpine)"
        Q10_IMAGE_SCORE=0
    fi

    # Check environment variable
    ENV_NAME=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="NGINX_PORT")].name}' 2>/dev/null)
    ENV_VALUE=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="NGINX_PORT")].value}' 2>/dev/null)

    if [[ "$ENV_NAME" == "NGINX_PORT" ]] && [[ "$ENV_VALUE" == "80" ]]; then
        echo "✅ PASS: Environment variable NGINX_PORT=80 is set"
        Q10_ENV_SCORE=1
    else
        echo "❌ FAIL: Environment variable NGINX_PORT=80 not correctly set"
        Q10_ENV_SCORE=0
    fi

    # Check if port 80 is exposed
    CONTAINER_PORT=$(kubectl get deployment nginx -n kdpd00201 -o jsonpath='{.spec.template.spec.containers[0].ports[?(@.containerPort==80)].containerPort}' 2>/dev/null)

    if [[ "$CONTAINER_PORT" == "80" ]]; then
        echo "✅ PASS: Port 80 is exposed"
        Q10_PORT_SCORE=1
    else
        echo "❌ FAIL: Port 80 is not exposed"
        Q10_PORT_SCORE=0
    fi
fi

Q10_TOTAL=$((Q10_DEPLOYMENT_SCORE + Q10_REPLICAS_SCORE + Q10_IMAGE_SCORE + Q10_ENV_SCORE + Q10_PORT_SCORE))
echo "Question 10 Score: $Q10_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q10_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 10 ends

# Evaluation for Question 11 starts

echo "=== Evaluating Question 11 ==="

# Check if the deployment exists
DEPLOYMENT_NAME=$(kubectl get deployment webapp -n kdpd00202 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'webapp' does not exist in namespace 'kdpd00202'"
    Q11_DEPLOYMENT_SCORE=0
    Q11_STRATEGY_SCORE=0
    Q11_ROLLBACK_SCORE=0
else
    echo "✅ PASS: Deployment 'webapp' exists in namespace 'kdpd00202'"
    Q11_DEPLOYMENT_SCORE=1

    # Check rolling update strategy configuration
    MAX_SURGE=$(kubectl get deployment webapp -n kdpd00202 -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
    MAX_UNAVAILABLE=$(kubectl get deployment webapp -n kdpd00202 -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)

    if [[ "$MAX_SURGE" == "4" ]] && [[ "$MAX_UNAVAILABLE" == "10%" ]]; then
        echo "✅ PASS: Rolling update strategy configured correctly (maxSurge: 4, maxUnavailable: 10%)"
        Q11_STRATEGY_SCORE=1
    else
        echo "❌ FAIL: Rolling update strategy not correctly configured (maxSurge: $MAX_SURGE, maxUnavailable: $MAX_UNAVAILABLE)"
        Q11_STRATEGY_SCORE=0
    fi

    # Check if deployment was rolled back (should be back to original image nginx:1.23.4)
    CURRENT_IMAGE=$(kubectl get deployment webapp -n kdpd00202 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

    # Check revision history to confirm rollback happened
    REVISION_COUNT=$(kubectl rollout history deployment/webapp -n kdpd00202 2>/dev/null | grep -c "^[0-9]" || echo "0")

    if [[ "$CURRENT_IMAGE" == "nginx:1.23.4" ]] && [[ "$REVISION_COUNT" -ge 2 ]]; then
        echo "✅ PASS: Deployment rolled back to original version (nginx:1.23.4) with $REVISION_COUNT revisions in history"
        Q11_ROLLBACK_SCORE=1
    else
        echo "❌ FAIL: Deployment not properly rolled back (current image: $CURRENT_IMAGE, revisions: $REVISION_COUNT)"
        Q11_ROLLBACK_SCORE=0
    fi
fi

Q11_TOTAL=$((Q11_DEPLOYMENT_SCORE + Q11_STRATEGY_SCORE + Q11_ROLLBACK_SCORE))
echo "Question 11 Score: $Q11_TOTAL/3"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q11_TOTAL))
MAX_SCORE=$((MAX_SCORE + 3))

# Evaluation for Question 11 ends

# Evaluation for Question 12 starts

echo "=== Evaluating Question 12 ==="

# Check if the deployment exists
DEPLOYMENT_NAME=$(kubectl get deployment deployment-007 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'deployment-007' does not exist in default namespace"
    Q12_DEPLOYMENT_SCORE=0
    Q12_CONTAINERS_SCORE=0
    Q12_VOLUME_SCORE=0
    Q12_COMMAND_SCORE=0
    Q12_CONFIGMAP_SCORE=0
else
    echo "✅ PASS: Deployment 'deployment-007' exists in default namespace"
    Q12_DEPLOYMENT_SCORE=1

    # Check containers
    CONTAINER_COUNT=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
    LOGGER_IMAGE=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="logger-123")].image}' 2>/dev/null)
    ADAPTOR_IMAGE=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="adaptor-dev")].image}' 2>/dev/null)

    if [[ "$CONTAINER_COUNT" == "2" ]] && [[ "$LOGGER_IMAGE" == "lfccncf/busybox:1" ]] && [[ "$ADAPTOR_IMAGE" == "lfccncf/fluentd:v0.12" ]]; then
        echo "✅ PASS: Deployment has correct containers (logger-123: lfccncf/busybox:1, adaptor-dev: lfccncf/fluentd:v0.12)"
        Q12_CONTAINERS_SCORE=1
    else
        echo "❌ FAIL: Containers not correctly configured (count: $CONTAINER_COUNT, logger: $LOGGER_IMAGE, adaptor: $ADAPTOR_IMAGE)"
        Q12_CONTAINERS_SCORE=0
    fi

    # Check shared volume mounted at /tmp/log on both containers
    LOGGER_MOUNT=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="logger-123")].volumeMounts[?(@.mountPath=="/tmp/log")].mountPath}' 2>/dev/null)
    ADAPTOR_MOUNT=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="adaptor-dev")].volumeMounts[?(@.mountPath=="/tmp/log")].mountPath}' 2>/dev/null)
    VOLUME_TYPE=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.volumes[0].emptyDir}' 2>/dev/null)

    if [[ "$LOGGER_MOUNT" == "/tmp/log" ]] && [[ "$ADAPTOR_MOUNT" == "/tmp/log" ]] && [[ ! -z "$VOLUME_TYPE" ]]; then
        echo "✅ PASS: Shared emptyDir volume mounted at /tmp/log on both containers"
        Q12_VOLUME_SCORE=1
    else
        echo "❌ FAIL: Shared volume not correctly configured"
        Q12_VOLUME_SCORE=0
    fi

    # Check logger command
    LOGGER_COMMAND=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="logger-123")].command}' 2>/dev/null)

    if echo "$LOGGER_COMMAND" | grep -q "i luv cncf" && echo "$LOGGER_COMMAND" | grep -q "/tmp/log/input.log"; then
        echo "✅ PASS: Logger container has correct command"
        Q12_COMMAND_SCORE=1
    else
        echo "❌ FAIL: Logger container command not correctly configured"
        Q12_COMMAND_SCORE=0
    fi

    # Check if ConfigMap is created and mounted to adaptor-dev
    CONFIGMAP_EXISTS=$(kubectl get configmap fluentd-config -o jsonpath='{.metadata.name}' 2>/dev/null)
    CONFIGMAP_MOUNT=$(kubectl get deployment deployment-007 -o jsonpath='{.spec.template.spec.containers[?(@.name=="adaptor-dev")].volumeMounts[?(@.mountPath=="/fluentd/etc")].mountPath}' 2>/dev/null)

    if [[ "$CONFIGMAP_EXISTS" == "fluentd-config" ]] && [[ "$CONFIGMAP_MOUNT" == "/fluentd/etc" ]]; then
        echo "✅ PASS: ConfigMap created and mounted at /fluentd/etc in adaptor-dev"
        Q12_CONFIGMAP_SCORE=1
    else
        echo "❌ FAIL: ConfigMap not correctly created or mounted (exists: $CONFIGMAP_EXISTS, mount: $CONFIGMAP_MOUNT)"
        Q12_CONFIGMAP_SCORE=0
    fi
fi

Q12_TOTAL=$((Q12_DEPLOYMENT_SCORE + Q12_CONTAINERS_SCORE + Q12_VOLUME_SCORE + Q12_COMMAND_SCORE + Q12_CONFIGMAP_SCORE))
echo "Question 12 Score: $Q12_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q12_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 12 ends

# Evaluation for Question 13 starts

echo "=== Evaluating Question 13 ==="

# Check if the manifest file exists and has content
MANIFEST_FILE="/opt/KDPD00301/periodic.yaml"

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "❌ FAIL: Manifest file $MANIFEST_FILE does not exist"
    Q13_MANIFEST_SCORE=0
elif [[ ! -s "$MANIFEST_FILE" ]]; then
    echo "❌ FAIL: Manifest file $MANIFEST_FILE is empty"
    Q13_MANIFEST_SCORE=0
else
    # Check if manifest contains required elements for CronJob
    if grep -q "kind: CronJob" "$MANIFEST_FILE" && \
       grep -q "name: hello" "$MANIFEST_FILE" && \
       grep -q "busybox" "$MANIFEST_FILE" && \
       grep -q "uname" "$MANIFEST_FILE" && \
       grep -q "schedule:" "$MANIFEST_FILE"; then
        echo "✅ PASS: Manifest contains required CronJob elements"
        Q13_MANIFEST_SCORE=1
    else
        echo "❌ FAIL: Manifest missing required CronJob elements"
        Q13_MANIFEST_SCORE=0
    fi
fi

# Check if the CronJob exists
CRONJOB_NAME=$(kubectl get cronjob hello -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$CRONJOB_NAME" ]]; then
    echo "❌ FAIL: CronJob 'hello' does not exist"
    Q13_CRONJOB_SCORE=0
    Q13_SCHEDULE_SCORE=0
    Q13_JOB_SCORE=0
else
    echo "✅ PASS: CronJob 'hello' exists"
    Q13_CRONJOB_SCORE=1

    # Check schedule (every minute: */1 * * * * or * * * * *)
    SCHEDULE=$(kubectl get cronjob hello -o jsonpath='{.spec.schedule}' 2>/dev/null)

    if [[ "$SCHEDULE" == "*/1 * * * *" ]] || [[ "$SCHEDULE" == "* * * * *" ]]; then
        echo "✅ PASS: CronJob schedule configured to run every minute"
        Q13_SCHEDULE_SCORE=1
    else
        echo "❌ FAIL: CronJob schedule is '$SCHEDULE' (expected: '*/1 * * * *' or '* * * * *')"
        Q13_SCHEDULE_SCORE=0
    fi

    # Check if at least one job has been created
    JOB_COUNT=$(kubectl get jobs -l app=hello 2>/dev/null | grep -c "hello-" || echo "0")

    # Alternative: check jobs created by cronjob using different label
    if [[ "$JOB_COUNT" == "0" ]]; then
        JOB_COUNT=$(kubectl get jobs --all-namespaces 2>/dev/null | grep -c "hello-" || echo "0")
    fi

    if [[ "$JOB_COUNT" -gt 0 ]]; then
        echo "✅ PASS: At least one job has been created from the CronJob"
        Q13_JOB_SCORE=1
    else
        echo "❌ FAIL: No jobs created from the CronJob yet"
        Q13_JOB_SCORE=0
    fi
fi

Q13_TOTAL=$((Q13_MANIFEST_SCORE + Q13_CRONJOB_SCORE + Q13_SCHEDULE_SCORE + Q13_JOB_SCORE))
echo "Question 13 Score: $Q13_TOTAL/4"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q13_TOTAL))
MAX_SCORE=$((MAX_SCORE + 4))

# Evaluation for Question 13 ends

# Evaluation for Question 14 starts

echo "=== Evaluating Question 14 ==="

# Check if the deployment exists
DEPLOYMENT_NAME=$(kubectl get deployment kdsn00101-deployment -n kdsn00101 -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$DEPLOYMENT_NAME" ]]; then
    echo "❌ FAIL: Deployment 'kdsn00101-deployment' does not exist in namespace 'kdsn00101'"
    Q14_LABEL_SCORE=0
    Q14_REPLICAS_SCORE=0
    Q14_SERVICE_SCORE=0
    Q14_SERVICE_TYPE_SCORE=0
    Q14_SERVICE_PORT_SCORE=0
    Q14_SERVICE_SELECTOR_SCORE=0
else
    # Check if tier=dmz label is added to pod template metadata
    TIER_LABEL=$(kubectl get deployment kdsn00101-deployment -n kdsn00101 -o jsonpath='{.spec.template.metadata.labels.tier}' 2>/dev/null)

    if [[ "$TIER_LABEL" == "dmz" ]]; then
        echo "✅ PASS: Deployment has tier=dmz label in pod template metadata"
        Q14_LABEL_SCORE=1
    else
        echo "❌ FAIL: Deployment missing tier=dmz label in pod template metadata"
        Q14_LABEL_SCORE=0
    fi

    # Check if deployment has 4 replicas
    REPLICAS=$(kubectl get deployment kdsn00101-deployment -n kdsn00101 -o jsonpath='{.spec.replicas}' 2>/dev/null)

    if [[ "$REPLICAS" == "4" ]]; then
        echo "✅ PASS: Deployment scaled to 4 replicas"
        Q14_REPLICAS_SCORE=1
    else
        echo "❌ FAIL: Deployment has $REPLICAS replicas (expected: 4)"
        Q14_REPLICAS_SCORE=0
    fi

    # Check if service exists
    SERVICE_NAME=$(kubectl get service cherry -n kdsn00101 -o jsonpath='{.metadata.name}' 2>/dev/null)

    if [[ -z "$SERVICE_NAME" ]]; then
        echo "❌ FAIL: Service 'cherry' does not exist in namespace 'kdsn00101'"
        Q14_SERVICE_SCORE=0
        Q14_SERVICE_TYPE_SCORE=0
        Q14_SERVICE_PORT_SCORE=0
        Q14_SERVICE_SELECTOR_SCORE=0
    else
        echo "✅ PASS: Service 'cherry' exists in namespace 'kdsn00101'"
        Q14_SERVICE_SCORE=1

        # Check service type
        SERVICE_TYPE=$(kubectl get service cherry -n kdsn00101 -o jsonpath='{.spec.type}' 2>/dev/null)

        if [[ "$SERVICE_TYPE" == "NodePort" ]]; then
            echo "✅ PASS: Service is of type NodePort"
            Q14_SERVICE_TYPE_SCORE=1
        else
            echo "❌ FAIL: Service type is '$SERVICE_TYPE' (expected: NodePort)"
            Q14_SERVICE_TYPE_SCORE=0
        fi

        # Check service port
        SERVICE_PORT=$(kubectl get service cherry -n kdsn00101 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)

        if [[ "$SERVICE_PORT" == "8080" ]]; then
            echo "✅ PASS: Service exposes port 8080"
            Q14_SERVICE_PORT_SCORE=1
        else
            echo "❌ FAIL: Service exposes port $SERVICE_PORT (expected: 8080)"
            Q14_SERVICE_PORT_SCORE=0
        fi

        # Check service selector for tier=dmz
        SERVICE_SELECTOR=$(kubectl get service cherry -n kdsn00101 -o jsonpath='{.spec.selector.tier}' 2>/dev/null)

        if [[ "$SERVICE_SELECTOR" == "dmz" ]]; then
            echo "✅ PASS: Service selector includes tier=dmz"
            Q14_SERVICE_SELECTOR_SCORE=1
        else
            echo "❌ FAIL: Service selector does not include tier=dmz"
            Q14_SERVICE_SELECTOR_SCORE=0
        fi
    fi
fi

Q14_TOTAL=$((Q14_LABEL_SCORE + Q14_REPLICAS_SCORE + Q14_SERVICE_SCORE + Q14_SERVICE_TYPE_SCORE + Q14_SERVICE_PORT_SCORE + Q14_SERVICE_SELECTOR_SCORE))
echo "Question 14 Score: $Q14_TOTAL/6"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q14_TOTAL))
MAX_SCORE=$((MAX_SCORE + 6))

# Evaluation for Question 14 ends

# Evaluation for Question 15 starts

echo "=== Evaluating Question 15 ==="

# Check if nginxsvc service is updated to port 9090
SERVICE_PORT=$(kubectl get service nginxsvc -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)

if [[ "$SERVICE_PORT" == "9090" ]]; then
    echo "✅ PASS: Service nginxsvc updated to port 9090"
    Q15_SERVICE_SCORE=1
else
    echo "❌ FAIL: Service nginxsvc port is $SERVICE_PORT (expected: 9090)"
    Q15_SERVICE_SCORE=0
fi

# Check if ConfigMap haproxy-config exists
CONFIGMAP_NAME=$(kubectl get configmap haproxy-config -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$CONFIGMAP_NAME" == "haproxy-config" ]]; then
    echo "✅ PASS: ConfigMap haproxy-config exists"
    Q15_CONFIGMAP_SCORE=1
else
    echo "❌ FAIL: ConfigMap haproxy-config does not exist"
    Q15_CONFIGMAP_SCORE=0
fi

# Check if poller pod has ambassador container and correct configuration
POD_EXISTS=$(kubectl get pod poller -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_EXISTS" ]]; then
    echo "❌ FAIL: Poller pod does not exist"
    Q15_POD_SCORE=0
else
    # Check for ambassador container
    AMBASSADOR_CONTAINER=$(kubectl get pod poller -o jsonpath='{.spec.containers[?(@.name=="ambassador")].name}' 2>/dev/null)

    if [[ "$AMBASSADOR_CONTAINER" == "ambassador" ]]; then
        # Check if poller args connect to localhost
        POLLER_ARGS=$(kubectl get pod poller -o jsonpath='{.spec.containers[?(@.name=="poller")].args}' 2>/dev/null)

        if echo "$POLLER_ARGS" | grep -q "localhost:60"; then
            echo "✅ PASS: Poller pod updated with ambassador container and connects to localhost:60"
            Q15_POD_SCORE=1
        else
            echo "❌ FAIL: Poller container args not updated to connect to localhost:60"
            Q15_POD_SCORE=0
        fi
    else
        echo "❌ FAIL: Ambassador container not found in poller pod"
        Q15_POD_SCORE=0
    fi
fi

Q15_TOTAL=$((Q15_SERVICE_SCORE + Q15_CONFIGMAP_SCORE + Q15_POD_SCORE))
echo "Question 15 Score: $Q15_TOTAL/3"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q15_TOTAL))
MAX_SCORE=$((MAX_SCORE + 3))

# Evaluation for Question 15 ends

# Evaluation for Question 16 starts

echo "=== Evaluating Question 16 ==="

# Check if PVC exists in storage namespace
PVC_NAME=$(kubectl get pvc app-pvc -n storage -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$PVC_NAME" ]]; then
    echo "❌ FAIL: PersistentVolumeClaim 'app-pvc' does not exist in namespace 'storage'"
    Q16_PVC_SCORE=0
    Q16_PVC_SIZE_SCORE=0
    Q16_PVC_STATUS_SCORE=0
else
    echo "✅ PASS: PersistentVolumeClaim 'app-pvc' exists in namespace 'storage'"
    Q16_PVC_SCORE=1

    # Check PVC storage size
    PVC_SIZE=$(kubectl get pvc app-pvc -n storage -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)

    if [[ "$PVC_SIZE" == "2Gi" ]]; then
        echo "✅ PASS: PVC requests 2Gi of storage"
        Q16_PVC_SIZE_SCORE=1
    else
        echo "❌ FAIL: PVC requests $PVC_SIZE (expected: 2Gi)"
        Q16_PVC_SIZE_SCORE=0
    fi

    # Check PVC status (should be Bound)
    PVC_STATUS=$(kubectl get pvc app-pvc -n storage -o jsonpath='{.status.phase}' 2>/dev/null)

    if [[ "$PVC_STATUS" == "Bound" ]]; then
        echo "✅ PASS: PVC is in Bound state"
        Q16_PVC_STATUS_SCORE=1
    else
        echo "⚠️  WARNING: PVC status is '$PVC_STATUS' (expected: Bound, but this may depend on cluster storage provisioner)"
        Q16_PVC_STATUS_SCORE=0
    fi
fi

# Check if pod exists and is using the PVC
POD_NAME=$(kubectl get pod storage-pod -n storage -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ -z "$POD_NAME" ]]; then
    echo "❌ FAIL: Pod 'storage-pod' does not exist in namespace 'storage'"
    Q16_POD_SCORE=0
    Q16_VOLUME_SCORE=0
else
    echo "✅ PASS: Pod 'storage-pod' exists in namespace 'storage'"
    Q16_POD_SCORE=1

    # Check if PVC is mounted at correct path
    VOLUME_MOUNT=$(kubectl get pod storage-pod -n storage -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/usr/share/nginx/html")].mountPath}' 2>/dev/null)
    PVC_CLAIM=$(kubectl get pod storage-pod -n storage -o jsonpath='{.spec.volumes[?(@.persistentVolumeClaim.claimName=="app-pvc")].persistentVolumeClaim.claimName}' 2>/dev/null)

    if [[ "$VOLUME_MOUNT" == "/usr/share/nginx/html" ]] && [[ "$PVC_CLAIM" == "app-pvc" ]]; then
        echo "✅ PASS: PVC 'app-pvc' mounted at /usr/share/nginx/html"
        Q16_VOLUME_SCORE=1
    else
        echo "❌ FAIL: PVC not correctly mounted (mount: $VOLUME_MOUNT, claim: $PVC_CLAIM)"
        Q16_VOLUME_SCORE=0
    fi
fi

Q16_TOTAL=$((Q16_PVC_SCORE + Q16_PVC_SIZE_SCORE + Q16_PVC_STATUS_SCORE + Q16_POD_SCORE + Q16_VOLUME_SCORE))
echo "Question 16 Score: $Q16_TOTAL/5"
echo ""

TOTAL_SCORE=$((TOTAL_SCORE + Q16_TOTAL))
MAX_SCORE=$((MAX_SCORE + 5))

# Evaluation for Question 16 ends

# Final Score Summary
echo "========================================"
echo "TOTAL SCORE: $TOTAL_SCORE/$MAX_SCORE"
echo "========================================"