# syntax=docker/dockerfile:1
# Frontend — React + Vite SPA, served as a static build by nginx.
# VITE_* are COMPILE-TIME: pass VITE_GATEWAY_URL (the PUBLIC gateway URL) as a build ARG.
# Building with the localhost default will NOT work once deployed.
FROM node:22-slim AS build
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.18.0 --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
ARG VITE_GATEWAY_URL=http://localhost:8000
ARG VITE_SIMULATION_START_TIME=2026-06-20T00:00:00Z
ARG VITE_GAME_SPEED=300
ARG VITE_MOCK=false
ARG VITE_TRAFFIC_GENERATOR=on
ENV VITE_GATEWAY_URL=$VITE_GATEWAY_URL \
    VITE_SIMULATION_START_TIME=$VITE_SIMULATION_START_TIME \
    VITE_GAME_SPEED=$VITE_GAME_SPEED \
    VITE_MOCK=$VITE_MOCK \
    VITE_TRAFFIC_GENERATOR=$VITE_TRAFFIC_GENERATOR
RUN pnpm build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=15s --timeout=4s --start-period=5s --retries=5 \
  CMD wget -qO- http://localhost/ >/dev/null 2>&1 || exit 1
