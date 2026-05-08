# Stage 1: Build
FROM node:20-slim AS builder
WORKDIR /app

# Root config copy karo
COPY package.json ./

# Backend aur shared logic copy karo (Frontend ignore)
COPY backend/package.json ./backend/
COPY shared ./shared

# Dependencies install (Shared workspace ke liye root level zaroori hai)
RUN npm install --legacy-peer-deps

# Poora backend source copy aur build
COPY backend ./backend
WORKDIR /app/backend
RUN npm run build

# Stage 2: Runner
FROM node:20-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

# Builder stage se sirf compiled files uthao
COPY --from=builder /app/backend/dist ./dist
COPY --from=builder /app/backend/package.json ./package.json

# Production deps install karo
RUN npm install --omit=dev --legacy-peer-deps

EXPOSE 5000

# Direct node se start karo, bina workspace flag ke
CMD ["node", "--enable-source-maps", "./dist/index.mjs"]
