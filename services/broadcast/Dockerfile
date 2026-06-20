# syntax=docker/dockerfile:1
# Broadcast ("Lighthouse") — Express + SSE. MUST run on PORT 3002 (the rest of the stack
# proxies BROADCAST_SERVICE_URL=http://broadcast:3002). Uses npm (package-lock.json present).
FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build
ENV PORT=3002
EXPOSE 3002
HEALTHCHECK --interval=15s --timeout=4s --start-period=10s --retries=5 \
  CMD node -e "fetch('http://localhost:'+(process.env.PORT||3002)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist/server.js"]
