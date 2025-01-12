#!/usr/bin/env bash

# Question 1 starts

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

# Q2
kubectl create ns web

# Q4 
kubectl create ns pod-resources

# Q6
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