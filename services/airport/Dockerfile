# syntax=docker/dockerfile:1
# Airport — Flask + SQLite. CRITICAL: exactly ONE worker / ONE replica.
# Gate worker threads and queues live in-process; >1 worker corrupts the simulation.
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN mkdir -p /data
ENV PORT=3001 DATABASE_PATH=/data/airport.db
EXPOSE 3001
HEALTHCHECK --interval=15s --timeout=4s --start-period=10s --retries=5 \
  CMD python -c "import os,urllib.request; urllib.request.urlopen('http://localhost:%s/health'%os.environ.get('PORT','3001'))" || exit 1
# 1 worker is mandatory; threads handle concurrency within the single process.
CMD ["gunicorn", "-w", "1", "--threads", "8", "-b", "0.0.0.0:3001", "app:app"]
