#!/usr/bin/env bash

########################################
# ABOUTME: CKAD Exam Simulation Setup Script - Set 3
# ABOUTME: Sets up environment for advanced Kubernetes questions covering init containers, security contexts, affinity, etc.
#########################################

set -e

echo "=========================================="
echo "CKAD Set 3 Setup - Advanced Topics"
echo "=========================================="
echo ""

# Setup for Question 1 starts
echo "Setting up Question 1: Init Containers - Basic..."

kubectl create namespace init-basic --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDINIT00101

# Create the db-service that init container will wait for
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: db-service
  namespace: init-basic
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: Pod
metadata:
  name: database
  namespace: init-basic
  labels:
    app: database
spec:
  containers:
  - name: db
    image: nginx
    ports:
    - containerPort: 5432
EOF

echo "Created init-basic namespace with db-service"
# Setup for Question 1 ends

# Setup for Question 2 starts
echo "Setting up Question 2: Init Containers - Multiple..."

kubectl create namespace init-multi --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDINIT00201

echo "Created init-multi namespace"
# Setup for Question 2 ends

# Setup for Question 3 starts
echo "Setting up Question 3: Security Context - User..."

kubectl create namespace security-user --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDSEC00101
touch /opt/KDSEC00101/user-info.txt

echo "Created security-user namespace and /opt/KDSEC00101/user-info.txt"
# Setup for Question 3 ends

# Setup for Question 4 starts
echo "Setting up Question 4: Security Context - Capabilities..."

kubectl create namespace security-caps --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDSEC00201
touch /opt/KDSEC00201/capabilities.txt

echo "Created security-caps namespace and /opt/KDSEC00201/capabilities.txt"
# Setup for Question 4 ends

# Setup for Question 5 starts
echo "Setting up Question 5: Pod Affinity..."

kubectl create namespace affinity --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDAFF00101

# Create cache pods for affinity testing
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache-1
  namespace: affinity
  labels:
    app: cache
spec:
  containers:
  - name: redis
    image: redis:alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: cache-2
  namespace: affinity
  labels:
    app: cache
spec:
  containers:
  - name: redis
    image: redis:alpine
EOF

echo "Created affinity namespace with cache pods"
# Setup for Question 5 ends

# Setup for Question 6 starts
echo "Setting up Question 6: Pod Anti-Affinity..."

kubectl create namespace anti-affinity --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDAFF00201
touch /opt/KDAFF00201/observations.txt

echo "Created anti-affinity namespace and /opt/KDAFF00201/observations.txt"
# Setup for Question 6 ends

# Setup for Question 7 starts
echo "Setting up Question 7: Startup Probe..."

kubectl create namespace startup-probe --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDPROBE00101

echo "Created startup-probe namespace"
# Setup for Question 7 ends

# Setup for Question 8 starts
echo "Setting up Question 8: Pod Disruption Budget..."

kubectl create namespace pdb --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDPDB00101
touch /opt/KDPDB00101/pdb-status.txt

# Create the critical-app deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: pdb
spec:
  replicas: 3
  selector:
    matchLabels:
      app: critical
  template:
    metadata:
      labels:
        app: critical
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
EOF

echo "Created pdb namespace with critical-app deployment"
# Setup for Question 8 ends

# Setup for Question 9 starts
echo "Setting up Question 9: Priority Classes..."

kubectl create namespace priority --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDPRI00101
touch /opt/KDPRI00101/priorities.txt

echo "Created priority namespace and /opt/KDPRI00101/priorities.txt"
# Setup for Question 9 ends

# Setup for Question 10 starts
echo "Setting up Question 10: Projected Volumes..."

kubectl create namespace projected --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDPROJ00101

# Create ConfigMap and Secret for projected volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: projected
data:
  config.yaml: "setting: value1"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: projected
type: Opaque
stringData:
  credentials: "password123"
EOF

echo "Created projected namespace with ConfigMap and Secret"
# Setup for Question 10 ends

# Setup for Question 11 starts
echo "Setting up Question 11: EmptyDir with sizeLimit..."

kubectl create namespace emptydir --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDEMPTY00101

echo "Created emptydir namespace"
# Setup for Question 11 ends

# Setup for Question 12 starts
echo "Setting up Question 12: Ephemeral Containers..."

kubectl create namespace debug --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDEPH00101
touch /opt/KDEPH00101/debug-command.txt
touch /opt/KDEPH00101/process-list.txt

# Create target pod for debugging
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: target-pod
  namespace: debug
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
EOF

echo "Created debug namespace with target-pod"
# Setup for Question 12 ends

# Setup for Question 13 starts
echo "Setting up Question 13: Canary Deployment..."

kubectl create namespace canary --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDCAN00101

echo "Created canary namespace"
# Setup for Question 13 ends

# Setup for Question 14 starts
echo "Setting up Question 14: Service Troubleshooting..."

kubectl create namespace svc-debug --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDSVC00101
touch /opt/KDSVC00101/issue.txt
touch /opt/KDSVC00101/endpoints.txt

# Create deployment with one label and service with different selector (broken)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: svc-debug
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: svc-debug
spec:
  selector:
    app: webapp  # Intentionally wrong - should be web-app
  ports:
  - port: 80
    targetPort: 80
EOF

echo "Created svc-debug namespace with broken service selector"
# Setup for Question 14 ends

# Setup for Question 15 starts
echo "Setting up Question 15: Complex Network Policy..."

kubectl create namespace netpol-tiers --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDNET00101

# Create pods for each tier
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: netpol-tiers
  labels:
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: netpol-tiers
  labels:
    tier: backend
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: database
  namespace: netpol-tiers
  labels:
    tier: database
spec:
  containers:
  - name: nginx
    image: nginx
EOF

echo "Created netpol-tiers namespace with frontend, backend, and database pods"
# Setup for Question 15 ends

# Setup for Question 16 starts
echo "Setting up Question 16: Deployment Strategy - Recreate..."

kubectl create namespace recreate --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDDEP00101
touch /opt/KDDEP00101/update-behavior.txt

# Create deployment with RollingUpdate strategy
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: recreate
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: legacy
  template:
    metadata:
      labels:
        app: legacy
    spec:
      containers:
      - name: app
        image: nginx:1.24
        ports:
        - containerPort: 80
EOF

echo "Created recreate namespace with legacy-app deployment"
# Setup for Question 16 ends

# Setup for Question 17 starts
echo "Setting up Question 17: Combined Probes Troubleshooting..."

kubectl create namespace probe-fix --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDCOMB00101
touch /opt/KDCOMB00101/fix-description.txt

# Create pod with broken probes (liveness starts too soon for slow app simulation)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-probe
  namespace: probe-fix
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
    # Simulating a slow start by checking wrong path initially
    livenessProbe:
      httpGet:
        path: /nonexistent
        port: 80
      initialDelaySeconds: 1
      periodSeconds: 1
      failureThreshold: 1
EOF

echo "Created probe-fix namespace with broken-probe pod"
# Setup for Question 17 ends

# Setup for Question 18 starts
echo "Setting up Question 18: Multi-issue Pod Debugging..."

kubectl create namespace multi-debug --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDDEBUG00101
touch /opt/KDDEBUG00101/issues-found.txt

# Create deployment with multiple issues
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: buggy-app
  namespace: multi-debug
spec:
  replicas: 2
  selector:
    matchLabels:
      app: buggy
  template:
    metadata:
      labels:
        app: buggy
    spec:
      securityContext:
        runAsUser: 0  # Will conflict with container securityContext
      containers:
      - name: app
        image: nginx:nonexistent-tag-12345  # Issue 1: wrong image tag
        securityContext:
          runAsNonRoot: true  # Issue 2: conflicts with runAsUser: 0
        resources:
          limits:
            memory: "5Mi"  # Issue 3: too low, will OOMKill
            cpu: "10m"
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: missing-config  # Issue 4: ConfigMap doesn't exist
EOF

echo "Created multi-debug namespace with buggy-app deployment (multiple issues)"
# Setup for Question 18 ends

# Setup for Question 19 starts
echo "Setting up Question 19: kubectl Custom Columns..."

kubectl create namespace report --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDCLI00201
touch /opt/KDCLI00201/pod-report.txt
touch /opt/KDCLI00201/restarts.txt
touch /opt/KDCLI00201/node-capacity.txt

# Create some pods in report namespace for reporting
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: report-pod-1
  namespace: report
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: report-pod-2
  namespace: report
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: report-pod-3
  namespace: report
spec:
  containers:
  - name: nginx
    image: nginx
EOF

echo "Created report namespace with sample pods"
# Setup for Question 19 ends

# Setup for Question 20 starts
echo "Setting up Question 20: Comprehensive Scenario..."

kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/KDCOMP00101

echo "Created production namespace"
# Setup for Question 20 ends

# Setup alias for easy evaluation
echo ""
echo "=========================================="
echo "Setting up 'score3' alias for evaluation"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALUATE_SCRIPT="$SCRIPT_DIR/evaluate3.sh"

# Function to add alias to shell config file
add_alias_to_file() {
    local config_file=$1

    # Create config file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
        echo "Created $config_file"
    fi

    # Check if alias already exists
    if ! grep -q "alias score3=" "$config_file" 2>/dev/null; then
        echo "" >> "$config_file"
        echo "# CKAD exam Set 3 evaluation alias" >> "$config_file"
        echo "alias score3='$EVALUATE_SCRIPT'" >> "$config_file"
        echo "Added 'score3' alias to $config_file"
    else
        echo "'score3' alias already exists in $config_file"
    fi
}

# Add alias to both bash and zsh config files
add_alias_to_file "$HOME/.bashrc"
add_alias_to_file "$HOME/.zshrc"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "To activate the alias in your current session, run:"
echo "  source ~/.zshrc    (for zsh)"
echo "  source ~/.bashrc   (for bash)"
echo ""
echo "Or simply open a new terminal window."
echo "Then you can run 'score3' to evaluate your answers!"
echo ""
echo "Questions are in questions3.md"
echo "=========================================="
