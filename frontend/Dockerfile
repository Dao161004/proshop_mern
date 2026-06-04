# ==============================================================================
# STAGE 1: Build React App
# ==============================================================================
FROM oven/bun:1-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN bun install --frozen-lockfile

COPY . .

ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL
# ==============================================================================
# STAGE 1: Build React App (Bun - fast)
# ==============================================================================
FROM oven/bun:1-alpine AS builder

WORKDIR /app

# Copy dependency files first (cache optimization)
COPY package.json package-lock.json ./

RUN bun install --frozen-lockfile

# Copy source
COPY . .

# Env for React build
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV NODE_ENV=production

# Build
RUN bun run build

# Remove source maps (optional optimization)
RUN find build -type f -name "*.map" -delete

# Install gzip for precompression
RUN apk add --no-cache gzip

# Precompress static assets
RUN find build -type f \( \
    -name "*.html" -o \
    -name "*.css" -o \
    -name "*.js" -o \
    -name "*.json" -o \
    -name "*.svg" \
\) -exec gzip -9 -k -f {} \;


# ==============================================================================
# STAGE 2: Nginx Production (FIXED PERMISSION SAFE)
# ==============================================================================
FROM nginx:1.25-alpine AS production

# Remove default config
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build output
COPY --from=builder /app/build /usr/share/nginx/html

# Fix permissions ONLY for static files (safe minimal fix)
RUN chmod -R 755 /usr/share/nginx/html

# Ensure nginx dirs exist (avoid runtime crash)
RUN mkdir -p /var/cache/nginx /var/run/nginx

# Expose port
EXPOSE 80

# Healthcheck WITHOUT wget/curl dependency issues
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost >/dev/null 2>&1 || exit 1

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]