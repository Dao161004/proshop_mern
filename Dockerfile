# ================================
# STAGE 1: Build stage (dev deps)
# ================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first (leverage Docker cache)
COPY package*.json ./

# Install production dependencies only in builder to keep final image slim
RUN npm ci --production --silent

# ================================
# STAGE 2: Production stage
# ================================
FROM node:18-alpine AS production

# Tạo user non-root để chạy app (bảo mật)
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

WORKDIR /app

# Copy node_modules từ builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy source code backend
COPY backend/ ./backend/
COPY package*.json ./

# Chuyển ownership sang user non-root
RUN chown -R nodeuser:nodejs /app
USER nodeuser

# Expose port backend (mặc định ProShop dùng port 5000)
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/api/health || exit 1

# Run app in production mode
ENV NODE_ENV=production
CMD ["node", "backend/server.js"]