# syntax=docker/dockerfile:1
# Gateway — Go reverse proxy. The ONLY service published publicly in Coolify.
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/gateway .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates wget
WORKDIR /app
COPY --from=build /out/gateway /app/gateway
ENV PORT=8000
EXPOSE 8000
# /health always returns HTTP 200 while the gateway process is up (body says healthy|degraded).
HEALTHCHECK --interval=15s --timeout=4s --start-period=10s --retries=5 \
  CMD wget -qO- "http://localhost:${PORT}/health" >/dev/null 2>&1 || exit 1
ENTRYPOINT ["/app/gateway"]
