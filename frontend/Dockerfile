# --- STAGE 1: Install dependencies ---
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# ติดตั้ง dependencies ตาม package-lock.json
COPY package.json package-lock.json ./
RUN npm ci

# --- STAGE 2: Build the application ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# สั่ง Build (ต้องมั่นใจว่าใน next.config.ts ตั้ง output: 'standalone')
RUN npm run build

# --- STAGE 3: Production runner ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
# 🛡️ Security Best Practice: ไม่รันด้วย Root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# ก๊อปปี้ไฟล์เฉพาะที่จำเป็นจาก stage builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# เปลี่ยนเจ้าของไฟล์เป็น user nextjs
USER nextjs

EXPOSE 3000
ENV PORT 3000
# กำหนด hostname เป็น 0.0.0.0 เพื่อให้ K8s เข้าถึงได้
ENV HOSTNAME "0.0.0.0"

# รันด้วย server.js ที่ Next.js สร้างให้ในโหมด standalone
CMD ["node", "server.js"]