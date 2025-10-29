## Setup Testing Environment
- Run following commands on your test Kubernetes environment:
    ```
    git clone https://github.com/kmriyad/ckad.git
    chmod +x ckad/scripts/setup.sh
    chmod +x ckad/scripts/evaluate.sh
    ckad/scripts/setup.sh
    ```
- Student answers questions in your test Kubernetes environment by following the directions in questions.md
- Administrator runs evaluate.sh to evaluate students's answers

## Setup Testing Environment - Set 2 (Advanced Topics)
- Run following commands on your test Kubernetes environment:
    ```
    chmod +x ckad/scripts/setup2.sh
    chmod +x ckad/scripts/evaluate2.sh
    ckad/scripts/setup2.sh
    ```
- Student answers questions in questions2.md (covers DaemonSets, StatefulSets, RBAC, Jobs, Resource Management, Ingress, Advanced Troubleshooting)
- Administrator runs evaluate2.sh to evaluate student's answers

Note: Both sets can be run independently. Set 1 covers foundational concepts, Set 2 covers advanced CKAD topics.

