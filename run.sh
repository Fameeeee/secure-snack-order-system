#!/bin/bash

# 1. ปลุก Podman
podman machine start

# 2. สร้าง Cluster (ถ้ายังไม่มี)
kind create cluster --name snack-cluster || echo "Cluster already exists"

# 3. เคลียร์ Port-forward เก่าที่ค้างอยู่ (ป้องกัน Error: port already in use)
echo "🧹 Cleaning up old tunnels..."
pkill -f "port-forward" || echo "No old tunnels found"

# 4. Build & Load Backend
echo "🔨 Building Backend..."
podman build -t localhost/order-api:1.0.0 ./order-service
podman save -o backend.tar localhost/order-api:1.0.0
kind load image-archive backend.tar --name snack-cluster
rm backend.tar

# 5. Build & Load Frontend
echo "🔨 Building Frontend..."
podman build -t localhost/snack-frontend:1.0.0 ./frontend
podman save -o frontend.tar localhost/snack-frontend:1.0.0
kind load image-archive frontend.tar --name snack-cluster
rm frontend.tar

# 6. Deploy to Kubernetes
echo "🚀 Deploying to K8s..."
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# 7. บังคับ Update แอป
kubectl rollout restart deployment order-api-deployment
kubectl rollout restart deployment snack-frontend-deployment

# 8. รอให้ Pods พร้อม (เอา -w ออก เพื่อให้สคริปต์ไปต่อได้เมื่อ Ready)
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=order-api --timeout=60s
kubectl wait --for=condition=ready pod -l app=snack-frontend --timeout=60s

# 9. เปิดอุโมงค์ (Port-forward)
echo "🌐 Opening tunnels in background..."
kubectl port-forward svc/order-api-service 3000:80 > /dev/null 2>&1 & 
kubectl port-forward svc/snack-frontend-service 8080:80 > /dev/null 2>&1 &

echo "----------------------------------------------------"
echo "✅ ALL SET! ระบบพร้อมใช้งานแล้ว"
echo "🌐 Frontend: http://localhost:8080"
echo "⚙️ Backend API: http://localhost:3000"
echo "----------------------------------------------------"
echo "กด Ctrl+C เพื่อหยุดการรัน (อุโมงค์จะถูกปิด)"
wait