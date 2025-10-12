#!/usr/bin/env bash

########################################
# CKAD Exam Simulation Setup Script 
# This script sets up the environment for various Kubernetes questions that asked in questions.md
# It creates necessary directories, files, and Kubernetes resources.
#########################################

# Setup for Question 1 starts

# Create the directory if it doesn't exist
mkdir -p /opt/KDOB00201

# Write the YAML spec file
cat << 'EOF' > /opt/KDOB00201/counter-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: counter-pod
spec:
  containers:
    - name: counter-container
      image: busybox
      command: [ "sh", "-c" ]
      args:
        - |
          i=0
          while true
          do
            echo "Counter: $i"
            i=$((i+1))
            sleep 5
          done
EOF

# Create/overwrite the log output file (empty by default)
: > /opt/KDOB00201/log_output.txt

# Optional: You can echo some confirmation messages if desired
echo "Created /opt/KDOB00201/counter-pod.yaml"
echo "Created /opt/KDOB00201/log_output.txt"

# Setup for Question 1 ends

# Setup for Question 2 starts

kubectl create ns web

# Setup for Question 2 ends

# Setup for Question 3 starts
kubectl create namespace qtn3 
# Setup for Question 3 ends

# Setup for Question 4 starts
kubectl create ns pod-resources
# Setup for Question 4 ends

# Setup for Question 5 starts
kubectl create namespace qtn5
# Setup for Question 5 ends

# Setup for Question 6 starts
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -

kubectl create serviceaccount restrictedservice --namespace=frontend

cat <<EOF | kubectl apply -n frontend -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: appa
  template:
    metadata:
      labels:
        app: appa
    spec:
      containers:
      - name: appa-container
        image: nginx
        ports:
        - containerPort: 80
EOF

echo "ServiceAccount 'restrictedservice' and Deployment 'appa' have been created in the 'frontend' namespace."
# Setup for Question 6 ends

# Setup for Question 7 starts

kubectl create namespace qtn7 --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -n qtn7 -f -
apiVersion: v1
kind: Pod
metadata:
  name: probe-http
  labels:
    app: probe-http
spec:
  containers:
  - name: probe-http
    image: nginxdemos/hello
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: probe-http
spec:
  selector:
    app: probe-http
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF

echo "Pod 'probe-http' and Service 'probe-http' created in namespace 'qtn7'"

# Setup for Question 7 ends

# Setup for Question 8 starts

kubectl create namespace stress --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /opt/KDOB00301
touch /opt/KDOB00301/pod.txt

# Create a Pod that consumes HIGH CPU
kubectl run stress-high \
  --image=busybox \
  --namespace=stress \
  --restart=Never \
  -- /bin/sh -c "while true; do yes > /dev/null; done"

# Create a Pod that consumes MEDIUM CPU
kubectl run stress-medium \
  --image=busybox \
  --namespace=stress \
  --restart=Never \
  -- /bin/sh -c \"while true; do yes > /dev/null; sleep 0.5; done\"

# Create a Pod that consumes LOWER CPU
kubectl run stress-low \
  --image=busybox \
  --namespace=stress \
  --restart=Never \
  -- /bin/sh -c \"while true; do yes > /dev/null; sleep 3; done\"

echo "Three pods (stress-high, stress-medium, and stress-low) have been created in the 'stress' namespace."

# Setup for Question 8 ends

# Setup for Question 9 starts
mkdir -p /opt/KDPD00101
touch /opt/KDPD00101/pod1.yml
touch /opt/KDPD00101/out1.json
# Setup for Question 9 ends

# Setup for Question 10 starts
kubectl create namespace kdpd00201 --dry-run=client -o yaml | kubectl apply -f -
# Setup for Question 10 ends

# Setup for Question 11 starts
kubectl create namespace kdpd00202 --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: kdpd00202
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
        - name: webapp
          image: nginx:1.23.4
          ports:
            - containerPort: 80
EOF

echo "Deployment 'webapp' created in namespace 'kdpd00202' using nginx:1.23.4."

# Setup for Question 11 ends

# Setup for Question 12 starts
mkdir -p /opt/KDMC00102

cat << 'EOF' > /opt/KDMC00102/fluentd-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /tmp/log/input.log
      pos_file /tmp/log/input.log.pos
      tag input.logs
      <parse>
        @type none
      </parse>
    </source>

    <match input.logs>
      @type file
      path /tmp/log/output
      <format>
        @type json
      </format>
    </match>
EOF

echo "Created /opt/KDMC00102/fluentd-configmap.yaml"

# Setup for Question 12 ends
