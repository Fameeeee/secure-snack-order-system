# --- STAGE 1: Builder (โรงงานประกอบร่าง) ---
FROM node:20-alpine AS builder
WORKDIR /app

# ก๊อปปี้แค่ไฟล์ Dependencies มาก่อน เพื่อใช้ประโยชน์จาก Docker Cache
COPY package*.json ./
RUN npm ci

# ก๊อปปี้ Source Code ที่เหลือแล้วสั่ง Build
COPY . .
RUN npm run build

# ลบ Dependencies ฝั่ง Dev ทิ้งให้หมด (เช่น ลบ Jest, ESLint ทิ้ง ไม่เอาขึ้น Production)
RUN npm ci --omit=dev && npm cache clean --force

# --- STAGE 2: Production (เวทีจริง) ---
FROM node:20-alpine AS production
WORKDIR /app

# ตั้งค่า Environment ให้ Node.js รู้ตัวว่าอยู่บน Production
ENV NODE_ENV=production

# ดึงเฉพาะของที่ "สุกแล้ว" จาก Stage 1 มาใช้
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# 🛡️ กฎเหล็ก DevSecOps: ปลดอาวุธ ห้ามรันด้วยสิทธิ์ Root เด็ดขาด
USER node

EXPOSE 3000

# รันแอปจากไฟล์ที่ถูก Compile แล้ว (ห้ามใช้ npm run start:prod ใน Docker)
CMD ["node", "dist/main"]