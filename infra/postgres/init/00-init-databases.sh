#!/bin/bash
# Runs ONCE on first Postgres volume init (docker-entrypoint-initdb.d).
# Creates the hotel + beach databases and seeds the 20 beach activities.
# Hotel rooms are seeded by the hotel container at boot (idempotent upsert).
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE hotel;
  CREATE DATABASE beach;
EOSQL

# Seed beach activities (the .sql CREATEs the table IF NOT EXISTS then INSERTs 20 rows).
# Exposed re-creates the table idempotently when the beach app boots, so order is safe.
if [ -f /beach-init/seed_activities.sql ]; then
  echo "[postgres-init] seeding beach activities..."
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname beach -f /beach-init/seed_activities.sql
else
  echo "[postgres-init] WARNING: /beach-init/seed_activities.sql not found — beach activities NOT seeded."
fi

echo "[postgres-init] databases hotel + beach ready."
