CLIENT_SECRET=eaa89eb2-d222-4be9-b6b8-e8e489394461
KONG_SERVICE_ID=16536acf-6246-41b9-a116-382a3180fdb9
REALM=kitajaga-internal
CLIENT_ID=kong
HOST_IP=keycloak-host

.PHONY: run
run:
	docker-compose up -d

.PHONY: restart
restart:
	docker-compose down && docker-compose up -d

.PHONY: status
status:
	docker-compose ps

.PHONY: log-kong
log-kong:
	docker logs kong-konga-keycloak_kong_1

.PHONY: log-konga
log-konga:
	docker logs konga

.PHONY: log-keycloak
log-keycloak:
	docker logs kong-konga-keycloak_keycloak_1

.PHONY: log-db
log-db:
	docker lgos kong-konga-keycloak_db_1

.PHONY: kong
kong:
	docker build -t kong-oidc:local -f kong-Dockerfile .

.PHONY: arm64-keycloak
arm64-keycloak:
	./arm64-keycloak-image-builder.sh

.PHONY: add-plugin
add-plugin:
	curl -s -X POST http://localhost:8001/services/${KONG_SERVICE_ID}/plugins \
	-d name=oidc \
	-d config.client_id=${CLIENT_ID} \
	-d config.client_secret=${CLIENT_SECRET} \
	-d config.bearer_only=yes \
	-d config.realm=${REALM} \
	-d config.introspection_endpoint=http://${HOST_IP}:8080/auth/realms/${REALM}/protocol/openid-connect/token/introspect \
	-d config.discovery=http://${HOST_IP}:8080/auth/realms/${REALM}/.well-known/openid-configuration

.PHONY: add-consumer-plugin
add-consumer-plugin:
	curl -s -X POST http://localhost:8001/services/${KONG_SERVICE_ID}/plugins \
	-d name=oidc-consumer \
	-d config.username_field=email \ 
	-d config.create_consumer=false