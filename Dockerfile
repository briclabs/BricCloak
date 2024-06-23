ARG KEYCLOAK_VERSION=23.0.6

FROM quay.io/keycloak/keycloak:$KEYCLOAK_VERSION as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:$KEYCLOAK_VERSION
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=postgres

# unneeded features
ENV KC_FEATURES_DISABLED=kerberos

# hardening
ENV KC_PROXY=edge
ENV KC_HTTPS_CLIENT_AUTH=required
ENV KC_HTTP_ENABLED=false

 ## Load shedding (protects against DoS)
ENV KC_HTTP-MAX-QUEUED-REQUESTS=50

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]