# ==============================================================================
# STAGE 1: Install dependencies (production only)
# ==============================================================================
FROM oven/bun:1-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json ./

# Bun vẫn đọc được package-lock.json → đảm bảo reproducible
RUN bun install --production --frozen-lockfile

# ==============================================================================
# STAGE 2: Production runtime
# ==============================================================================
FROM oven/bun:1-alpine AS production
WORKDIR /app

COPY --from=deps --chown=bun:bun /app/node_modules ./node_modules
COPY --chown=bun:bun package.json ./
COPY --chown=bun:bun backend/ ./backend/

USER bun
ENV NODE_ENV=production
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000 || exit 1

CMD ["bun", "run", "backend/server.js"]