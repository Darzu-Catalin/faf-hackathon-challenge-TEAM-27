#!/usr/bin/env bash
# Reset Purrlington data BEFORE each test window (20:30 / 08:30).
# Clears runtime data and re-applies seed data so rooms(20) + activities(20) exist.
# Run from the repo root (where docker-compose.yml lives). Works locally and on Coolify
# (which runs the compose stack). See docs/DEPLOYMENT.md and the /db-reset-seed skill.
set -uo pipefail
cd "$(dirname "$0")"

DC="docker compose"
DBU="${DB_USER:-postgres}"

echo "[reset] hotel: clearing reservations (rooms are static and survive)..."
$DC exec -T postgres psql -U "$DBU" -d hotel -c 'TRUNCATE "Reservation" RESTART IDENTITY CASCADE;' || true

echo "[reset] beach: clearing bookings/visitors + reseeding the 20 activities..."
# activity_bookings only exists once BCH-1 is implemented; ignore if absent.
$DC exec -T postgres psql -U "$DBU" -d beach -c 'TRUNCATE activity_bookings RESTART IDENTITY CASCADE;' >/dev/null 2>&1 || true
$DC exec -T postgres psql -U "$DBU" -d beach -c 'TRUNCATE activities, visitors RESTART IDENTITY CASCADE;' || true
$DC exec -T postgres psql -U "$DBU" -d beach -f /beach-init/seed_activities.sql || true

echo "[reset] airport: wiping SQLite + in-memory queues..."
$DC exec -T airport sh -c 'rm -f /data/airport.db /data/airport.db-*' >/dev/null 2>&1 || true
$DC restart airport >/dev/null 2>&1 || true

echo "[reset] hotel: re-seeding rooms (restart triggers idempotent upsert)..."
$DC restart hotel >/dev/null 2>&1 || true

echo "[reset] done."
echo "[reset] VERIFY: curl \$GATEWAY/api/hotel/rooms  -> 20 rooms"
echo "[reset]         curl \$GATEWAY/api/beach/activities -> 20 activities"
echo "[reset]         curl \$GATEWAY/health -> services up"
