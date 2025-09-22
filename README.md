# Kubernetes Project Scaffold

This repository provides a minimal, production-ready Kubernetes scaffold using Kustomize with dev and prod overlays.

- See docs: [Architecture](docs/architecture.md), [Theory](docs/theory.md)

## Prerequisites
- kubectl
- kustomize (or kubectl >= 1.14 which includes `-k`)
- kind or a Kubernetes cluster
- (AWS) awscli and eksctl with credentials configured

## Structure
```
k8s-project/
  base/                # Base resources
  overlays/
    dev/               # Dev overlay
    prod/              # Prod overlay
  scripts/             # Helper scripts
  Makefile
```

## Quick start (kind)
```bash
make kind-up
make apply-dev
open http://localhost:8080
```

## Quick start (AWS EKS 2-node)
```bash
make eks-up                          # creates EKS in us-east-1 by default
make apply-prod
kubectl get svc -n demo | grep web
# copy the EXTERNAL-IP and open http://<external-ip>
```

To customize:
```bash
make eks-up EKS_CLUSTER_NAME=myproj EKS_REGION=us-west-2
```

Tear down:
```bash
make eks-down EKS_CLUSTER_NAME=myproj EKS_REGION=us-west-2
```

## Apply/delete
```bash
make apply-dev     # apply dev overlay (NodePort 30080 -> localhost:8080)
make delete-dev    # delete dev overlay
make apply-prod    # apply prod overlay (Service LoadBalancer)
make delete-prod   # delete prod overlay
```

## Other handy targets
```bash
make help          # list all targets
make diff          # show server diff for current OVERLAY (default dev)
make build         # render manifests to build.yaml
make context       # show kubectl context and namespace
```

## Configuration
- `OVERLAY` controls which overlay is used (default `dev`).
- `NAMESPACE` optionally sets `kubectl -n` for commands.
- `CLUSTER_NAME` and `KIND_CONFIG` customize Kind cluster creation.
- `EKS_CLUSTER_NAME`, `EKS_REGION`, and `EKSCTL_CONFIG` customize EKS creation.

## Notes
- Base uses `nginx` as a placeholder app. Replace image and manifests as needed.
- Ingress hostnames are placeholders. For Kind, use `http://localhost:8080`. For EKS, use the Service `EXTERNAL-IP` unless you configure an ALB Ingress Controller and DNS.

## 👨‍💻 Author

**Atul Kamble**

- 💼 [LinkedIn](https://www.linkedin.com/in/atuljkamble)
- 🐙 [GitHub](https://github.com/atulkamble)
- 🐦 [X](https://x.com/Atul_Kamble)
- 📷 [Instagram](https://www.instagram.com/atuljkamble)
- 🌐 [Website](https://www.atulkamble.in)

---
