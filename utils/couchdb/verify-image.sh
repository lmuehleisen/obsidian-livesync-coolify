#!/bin/sh
# Synthetic offline fixture only: no production credentials, data or host ports.
set -eu
image=${1:?Pass the built CouchDB image}
name="livesync-image-smoke-$$"
if docker inspect "$name" >/dev/null 2>&1; then exit 1; fi
docker run -d --name "$name" --network none \
  -e COUCHDB_USER=smoke -e COUCHDB_PASSWORD=local-only-fixture-password \
  "$image" >/dev/null
trap 'docker rm -fv "$name" >/dev/null' EXIT
ready=false
for attempt in $(seq 1 45); do
  if docker exec "$name" curl -fsS -u smoke:local-only-fixture-password \
    http://127.0.0.1:5984/_up >/dev/null; then ready=true; break; fi
  sleep 1
done
[ "$ready" = true ]
docker exec "$name" curl -fsS -u smoke:local-only-fixture-password \
  http://127.0.0.1:5984/ | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"] == "3.5.3"'
version=$(docker exec "$name" dpkg-query -W '-f=${Version}' libbrotli1)
docker exec "$name" dpkg --compare-versions "$version" ge '1.1.0-2+deb13u1'
printf 'CouchDB 3.5.3 is ready; Brotli %s meets the security floor.\n' "$version"
