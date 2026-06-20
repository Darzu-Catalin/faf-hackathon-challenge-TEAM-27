# syntax=docker/dockerfile:1
# Parrot — FastAPI LLM assistant. Deploy TWO identical containers (parrot + parrot-b)
# so the gateway round-robins PARROT_SERVICE_URL. Both need identical valid LLM_* env.
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV PORT=3003
EXPOSE 3003
HEALTHCHECK --interval=15s --timeout=4s --start-period=10s --retries=5 \
  CMD python -c "import os,urllib.request; urllib.request.urlopen('http://localhost:%s/health'%os.environ.get('PORT','3003'))" || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3003"]
