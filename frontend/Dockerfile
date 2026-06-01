# ================================
# STAGE 1: Build React App
# ================================
FROM node:14-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Cài dependencies (use silent install to reduce output)
RUN npm ci --silent

# Copy toàn bộ source frontend
COPY . .

# Build production bundle
# Biến này để React biết đường dẫn API backend
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL

# Ensure production mode for the build
ENV NODE_ENV=production

RUN npm run build

# ================================
# STAGE 2: Serve với Nginx
# ================================
FROM nginx:1.25-alpine AS production

# Xoá config mặc định của Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copy Nginx config tùy chỉnh (tạo file này - xem bên dưới)
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files từ build stage
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]