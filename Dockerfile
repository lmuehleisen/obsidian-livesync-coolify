# Use CouchDB as the base image
FROM couchdb:3.5.3@sha256:4e8e0a366208a87d5059b0f4fcbefff13c32401a655d4629c19be6288ea77675

# Create necessary directories
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl libbrotli1 \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/couchdb/data /opt/couchdb/etc/local.d

# Copy configuration files
COPY local.ini /opt/couchdb/etc/local.d/obsidian-livesync.ini
COPY utils/couchdb/docker-entrypoint-coolify.sh /usr/local/bin/docker-entrypoint-coolify.sh

# Set ownership
RUN chmod +x /usr/local/bin/docker-entrypoint-coolify.sh \
 && chown -R couchdb:couchdb /opt/couchdb/data /opt/couchdb/etc

# Expose port
EXPOSE 5984

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f -u "$COUCHDB_USER:$COUCHDB_PASSWORD" http://localhost:5984/_up || exit 1

# Start CouchDB
CMD ["/usr/local/bin/docker-entrypoint-coolify.sh"]