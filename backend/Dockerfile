# ==========================================
# Stage 1: Builder
# ==========================================
FROM dhi.io/node:26-alpine3.23-dev AS builder

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build

RUN pnpm prune --prod


# ==========================================
# Stage 2: Production
# ==========================================
FROM dhi.io/node:26-alpine3.23 AS production

WORKDIR /app

COPY --from=builder --chown=node:node /app/package.json ./package.json
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist

USER node

EXPOSE 3000

CMD ["node", "dist/main"]