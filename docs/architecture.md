# Architecture

This project deploys a simple web application via Kubernetes using Kustomize overlays (`dev`, `prod`). The diagram illustrates request flow for both local Kind and AWS EKS.

```mermaid
flowchart LR
  user[User Browser]

  subgraph KindLocal["Kind (Local)"]
    kind_ing["Ingress (dev)<br/>optional"]
    kind_svc["Service (NodePort 30080)"]
    kind_pods["Pods (Deployment)"]
  end

  subgraph EKSCluster["EKS (AWS)"]
    eks_alb["Ingress (ALB)<br/>optional"]
    eks_lb["Service (LoadBalancer/NLB)"]
    eks_pods["Pods (Deployment)"]
  end

  user -->|"http://localhost:8080"| kind_ing
  kind_ing --> kind_svc
  user -->|"EXTERNAL-IP"| eks_alb
  eks_alb --> eks_lb

  kind_svc --> kind_pods
  eks_lb --> eks_pods
```

Key points:
- Dev overlay exposes `Service` as NodePort 30080. With Kind port-mapping 30080→8080, open `http://localhost:8080`.
- Prod overlay exposes `Service` as `LoadBalancer` (NLB). Use the service `EXTERNAL-IP` or front with an ALB `Ingress` and DNS when needed.
