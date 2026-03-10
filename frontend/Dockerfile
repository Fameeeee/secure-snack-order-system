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
# ... (Stage builder ด้านบนที่สั่ง npm run build)

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME "0.0.0.0"
ENV PORT 3000

# 🛡️ สร้าง User เพื่อความปลอดภัย (DevSecOps Standard)
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# ✅ จุดสำคัญ: ต้องก๊อปปี้จาก .next/standalone มาไว้ที่ ./ (Root ของ WORKDIR)
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

# รันไฟล์ server.js ที่ Next.js สร้างให้
CMD ["node", "server.js"]