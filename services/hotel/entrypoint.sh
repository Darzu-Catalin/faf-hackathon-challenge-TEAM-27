#!/bin/sh
set -e

# Apply DB schema, then seed the 20 rooms (idempotent upsert), then start.
# NOTE: `nest build` (sourceRoot=src) never emits dist/prisma/seed.js, so we run the
# TypeScript seed directly via ts-node — matches package.json `db:seed` / prisma.config.ts.
echo "[hotel] prisma migrate deploy..."
pnpm exec prisma migrate deploy
echo "[hotel] seeding rooms (idempotent)..."
pnpm exec ts-node prisma/seed.ts
echo "[hotel] starting NestJS..."
exec node dist/src/main.js
