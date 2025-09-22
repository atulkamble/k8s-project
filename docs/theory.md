# Theory Notes

This project demonstrates a common Kubernetes deployment pattern using Kustomize overlays for environments.

## Components
- Namespace: logical isolation of resources (here: `demo`).
- Deployment: desired state for pods (replicas, rolling updates). Uses a simple `nginx` container.
- Service: stable virtual IP and DNS for pods. In dev we use `NodePort`; in prod we use `LoadBalancer`.
- Ingress: optional HTTP routing. In dev, an NGINX Ingress can be used locally; in prod, ALB is common on EKS.
- Kustomize: composes `base/` manifests with environment-specific `overlays/`.

## Environments
- Dev overlay (`overlays/dev`):
  - `namePrefix: dev-` and `env: dev` labels
  - Patches set `Service` to `NodePort` 30080 and an optional dev host on Ingress
  - Designed for Kind with host port 8080 -> NodePort 30080
- Prod overlay (`overlays/prod`):
  - `namePrefix: prod-` and `env: prod` labels
  - Patches set `Service` to `LoadBalancer` (NLB) and configure ALB Ingress annotations

## Local vs Cloud Traffic
- Local (Kind): `user -> localhost:8080 -> NodePort 30080 -> Service -> Pods`
- AWS (EKS): `user -> ALB hostname -> NLB (Service) -> Pods` or directly `EXTERNAL-IP` of the Service if no ALB.

## CI
- GitHub Actions validates Kustomize builds and performs a Kind smoke test, ensuring manifests are valid and rollouts succeed.

## Customization
- Swap the container image in `overlays/dev/patch-deployment.yaml`.
- Update Ingress hosts and annotations to match your DNS and controller setup.
- Adjust instance types and scaling in `eksctl-config.yaml` as needed.
