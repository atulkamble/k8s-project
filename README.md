Awesome—built you a **production-style Kubernetes project** end-to-end (frontend + backend + DB + cache + ingress + HPA + PDB + kustomize overlays + CI skeleton). Grab it here:

[Download the project (cloudnautic-k8s-starter.zip)](sandbox:/mnt/data/cloudnautic-k8s-starter.zip)

### What you’re getting

* **Frontend**: NGINX serving a clean, minimal UI (no heavy deps)
* **Backend**: FastAPI + Uvicorn, `/api/items` CRUD with Postgres and Redis cache hooks
* **Data**: PostgreSQL **StatefulSet** + PVC, Redis **Deployment**
* **Ops**: Readiness/Liveness probes, **HPA**, **PodDisruptionBudget**, **resources**, **NetworkPolicy**
* **Routing**: NGINX **Ingress** (path routing: `/` → frontend, `/api` → backend) using `app.localtest.me`
* **Deploy**: **Kustomize** overlays: `dev` (1 replica) and `prod` (3 replicas)
* **CI/CD**: GitHub Actions workflow to build & push Docker images (Docker Hub)
* **DX**: Makefile targets (`build`, `deploy-dev`, `deploy-prod`, `destroy`)

### Run it on Minikube (quick)

```bash
minikube start --memory=4096 --cpus=4
minikube addons enable ingress
eval $(minikube -p minikube docker-env)     # build images inside Minikube
make build
make deploy-dev

kubectl get pods -n cloudnautic-app
kubectl get ingress -n cloudnautic-app
# Open in browser:
# http://app.localtest.me/
```

### Expected output & UI

* Visit **[http://app.localtest.me/](http://app.localtest.me/)** → UI loads with a form and items table.
* `curl http://app.localtest.me/api/items` → returns `[]` initially.
* POST:

  ```bash
  curl -X POST http://app.localtest.me/api/items \
    -H 'Content-Type: application/json' \
    -d '{"name":"notebook","qty":10}'
  ```

  → `{"id":1,"name":"notebook","qty":10}` and the UI shows it in the table.
* Probes:

  * `GET /healthz` → `{"status":"ok","uptime_sec":...}`
  * `GET /readyz` → `{"ready": true}` once Postgres & Redis are reachable.

### Production touches you can flip on

* Swap to `overlays/prod` (`make deploy-prod`) after pushing images to Docker Hub (`DOCKER_USER` + `TAG`).
* Wire **TLS** via cert-manager (left out to keep this portable).
* Tighten **NetworkPolicies** per service, add **ServiceMonitor** if you use Prometheus.
* Replace sample secrets in `k8s/base/secret.yaml` or use your secret manager.

Want me to tailor this for **EKS**/**AKS** (with Terraform), add **cert-manager TLS**, or plug in **Prometheus/Grafana** dashboards next?
