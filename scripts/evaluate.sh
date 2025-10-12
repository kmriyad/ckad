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

# Final Score Summary
echo "========================================"
echo "TOTAL SCORE: $TOTAL_SCORE/$MAX_SCORE"
echo "========================================"