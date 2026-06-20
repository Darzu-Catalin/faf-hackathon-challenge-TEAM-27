# syntax=docker/dockerfile:1
# Hotel — NestJS + Prisma 7 + Postgres.
# Single-stage on purpose: the seed runs via `ts-node prisma/seed.ts` at boot, so ts-node
# + typescript + the prisma source must remain in the runtime image (see entrypoint.sh).
FROM node:24-slim
WORKDIR /app
# openssl is required by Prisma 7 engines.
RUN apt-get update && apt-get install -y --no-install-recommends openssl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# Generate the Prisma client (output dir generated/prisma is gitignored) BEFORE building.
RUN pnpm exec prisma generate
RUN pnpm run build
RUN chmod +x entrypoint.sh
ENV PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=4s --start-period=30s --retries=5 \
  CMD node -e "fetch('http://localhost:'+(process.env.PORT||3000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
ENTRYPOINT ["./entrypoint.sh"]
