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
kubectl run pod1 --image=nginx -n resource-check --requests=cpu=100m -- sleep 3600
kubectl run pod2 --image=nginx -n resource-check --requests=cpu=200m -- sleep 3600
kubectl run pod3 --image=nginx -n resource-check --requests=cpu=150m -- sleep 3600

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
