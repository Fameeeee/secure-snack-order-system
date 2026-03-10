#!/bin/bash

# 1. ปลุก Podman
podman machine start

# 2. สร้าง Cluster (ถ้ายังไม่มี)
kind create cluster --name snack-cluster || echo "Cluster already exists"

# 3. Build & Load Backend
echo "🔨 Building Backend..."
podman build -t localhost/order-api:1.0.0 ./order-service
podman save -o backend.tar localhost/order-api:1.0.0
kind load image-archive backend.tar --name snack-cluster
rm backend.tar

# 4. Build & Load Frontend
echo "🔨 Building Frontend..."
podman build -t localhost/snack-frontend:1.0.0 ./frontend
podman save -o frontend.tar localhost/snack-frontend:1.0.0
kind load image-archive frontend.tar --name snack-cluster
rm frontend.tar

# 5. Deploy to Kubernetes
echo "🚀 Deploying to K8s..."
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

echo "✅ All set! Don't forget to run port-forward commands."