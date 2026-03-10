#!/bin/bash

echo "🚀 Starting Podman Machine..."
podman machine start

echo "⏳ Waiting for Kubernetes to be ready..."
until kubectl cluster-info > /dev/null 2>&1; do
  sleep 2
done

echo "📦 Applying Kubernetes Manifests..."
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/backend.yaml

echo "🔍 Checking Pod Status..."
sleep 5
kubectl get pods

echo "🔌 Opening Port-Forward to Backend (localhost:3000)..."
kubectl port-forward svc/order-api-service 3000:80