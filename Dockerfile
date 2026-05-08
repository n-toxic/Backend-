# Stage 1: Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Copy root configurations
COPY package.json ./

# Copy specific folders needed for backend
COPY backend/package.json ./backend/
COPY shared/db ./shared/db
COPY shared/api-zod ./shared/api-zod

# Install dependencies (including shared workspace deps)
RUN npm install --legacy-peer-deps

# Copy backend source code
COPY backend ./backend

# Build the backend
WORKDIR /app/backend
RUN npm run build

# Stage 2: Runner stage
FROM node:20-slim AS runner

WORKDIR /app

# Environment defaults
ENV NODE_ENV=production
ENV PORT=5000

# Builder stage se sirf zaroori files uthao
COPY --from=builder /app/backend/dist ./dist
COPY --from=builder /app/backend/package.json ./package.json
COPY --from=builder /app/backend/build.mjs ./build.mjs

# Production dependencies install karo
RUN npm install --omit=dev --legacy-peer-deps

# Port expose karo
EXPOSE 5000

# Backend start karo
CMD ["node", "--enable-source-maps", "./dist/index.mjs"]

