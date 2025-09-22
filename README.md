# Kubernetes Project Scaffold

This repository provides a minimal, production-ready Kubernetes scaffold using Kustomize with dev and prod overlays.

## Prerequisites
- kubectl
- kustomize (or kubectl >= 1.14 which includes `-k`)
- kind or a Kubernetes cluster

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
kubectl get all -n demo
```

## Apply/delete
```bash
make apply-dev     # apply dev overlay
make delete-dev    # delete dev overlay
make apply-prod    # apply prod overlay
make delete-prod   # delete prod overlay
```

## Notes
- Base uses `nginx` as a placeholder app. Replace image and manifests as needed.
- Ingress hostnames are placeholders (`dev.example.local`, `example.com`). Update to your domains or use `nip.io` for quick testing.
