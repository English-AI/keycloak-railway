FROM quay.io/keycloak/keycloak:latest AS builder

ARG KC_HEALTH_ENABLED KC_METRICS_ENABLED KC_FEATURES KC_DB KC_HTTP_ENABLED PROXY_ADDRESS_FORWARDING QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY KC_HOSTNAME KC_LOG_LEVEL KC_DB_POOL_MIN_SIZE

ADD --chown=keycloak:keycloak https://github.com/klausbetz/apple-identity-provider-keycloak/releases/download/1.7.1/apple-identity-provider-1.7.1.jar /opt/keycloak/providers/apple-identity-provider-1.7.1.jar
ADD --chown=keycloak:keycloak https://github.com/wadahiro/keycloak-discord/releases/download/v0.5.0/keycloak-discord-0.5.0.jar /opt/keycloak/providers/keycloak-discord-0.5.0.jar
ADD --chown=keycloak:keycloak https://github.com/English-AI/public/releases/download/keycloak/io.phasetwo.keycloak-keycloak-themes-0.30.jar /opt/keycloak/providers/io.phasetwo.keycloak-keycloak-themes-0.30.jar
ADD --chown=keycloak:keycloak https://github.com/English-AI/public/releases/download/keycloak/phasetwo-admin-ui-25.0.0.jar /opt/keycloak/providers/phasetwo-admin-ui-25.0.0.jar

RUN /opt/keycloak/bin/kc.sh build --spi-email-template-provider=freemarker-plus-mustache --spi-email-template-freemarker-plus-mustache-enabled=true --spi-theme-cache-themes=false 
FROM quay.io/keycloak/keycloak:latest

COPY java.config /etc/crypto-policies/back-ends/java.config

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

CMD ["start", "--optimized", "--import-realm", "--spi-email-template-provider=freemarker-plus-mustache", "--spi-email-template-freemarker-plus-mustache-enabled=true", "--spi-theme-cache-themes=false", "--spi-theme-cache-templates=false", "--hostname-strict=false", "--proxy-headers=xforwarded"]
