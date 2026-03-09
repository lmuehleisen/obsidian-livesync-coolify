#!/bin/sh
set -eu

: "${COUCHDB_USER:?COUCHDB_USER must be set}"
: "${COUCHDB_PASSWORD:?COUCHDB_PASSWORD must be set}"

exec /docker-entrypoint.sh /opt/couchdb/bin/couchdb