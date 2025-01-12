#!/usr/bin/env bash

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

