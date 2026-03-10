# 🍪 Secure Snack Order System — K8s + DevSecOps

Full-stack microservices sample application (Next.js frontend, NestJS backend, PostgreSQL) designed to run on a local Kubernetes cluster (kind) with Podman-built container images. The repository focuses on DevSecOps & security-minded defaults and provides Kubernetes manifests, local deployment scripts and developer instructions.

---

## Key points

- Frontend: Next.js (project uses next@16.1.6)
- Backend: NestJS + TypeORM (Nest v11, TypeORM v0.3)
- Database: PostgreSQL (postgres:15-alpine in manifests)
- Local infra: Podman, kind (Kubernetes-in-Docker/VM), kubectl
- Automation: `run.sh` builds images, loads them into kind and deploys the manifests in `k8s/`

## Prerequisites

- macOS (this repository has been tested locally on macOS)
- Podman (and `podman machine` configured)
- kind (Kubernetes in Docker/VM)
- kubectl (targeting the `kind` cluster)
- Node.js (for local frontend/backend dev) and npm/yarn/pnpm as needed

If you don't have these tools installed, please install them first. The `run.sh` script expects `podman`, `kind` and `kubectl` on PATH.

## Quick start (recommended)

This project includes a convenience script `run.sh` at the repository root that:

- starts the Podman machine (if needed)
- builds frontend and backend images with Podman
- saves and loads the images into the kind cluster
- applies the Kubernetes manifests under `k8s/`
- opens background port-forwards for frontend and backend

Make the script executable and run it:

```bash
chmod +x run.sh
./run.sh
```

When the script completes you should see the two services accessible locally:

- Frontend: http://localhost:8080
- Backend API: http://localhost:3000

Note: `run.sh` uses `podman build` + `kind load image-archive` to make locally-built images available to the cluster. It also starts background `kubectl port-forward` processes.

## Manual deploy steps (what `run.sh` does)

1. Start Podman machine:

```bash
podman machine start
```

2. Build images (example tags used in manifests):

```bash
podman build -t localhost/order-api:1.0.0 ./order-service
podman build -t localhost/snack-frontend:1.0.0 ./frontend
```

3. Save & load images into kind:

```bash
podman save -o backend.tar localhost/order-api:1.0.0
kind load image-archive backend.tar --name snack-cluster
rm backend.tar

podman save -o frontend.tar localhost/snack-frontend:1.0.0
kind load image-archive frontend.tar --name snack-cluster
rm frontend.tar
```

4. Apply Kubernetes manifests:

```bash
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
```

5. Port-forward / access services

The included manifests expose NodePorts (30001 and 30002) — the `run.sh` script instead creates kubectl port-forwards from the services to local ports 3000 and 8080 respectively.

Manual port-forwarding example:

```bash
kubectl port-forward svc/order-api-service 3000:80
kubectl port-forward svc/snack-frontend-service 8080:80
```

## Development (local)

Frontend (Next.js)

```bash
cd frontend
npm install
npm run dev
# open http://localhost:3000
```

Backend (NestJS)

```bash
cd order-service
npm install
npm run start:dev
# API listens on PORT env or 3000 by default
```

## Project structure (top-level)

- `frontend/` — Next.js frontend app
- `order-service/` — NestJS backend service
- `k8s/` — Kubernetes manifests (postgres, backend, frontend)
- `run.sh` — convenience script to build, load and deploy locally
- `run.txt` — helper cleanup commands and notes

## License & author

Developed by: Fame (Web Developer & DevSecOps Trainee)
