CLIENT_SECRET=9e233434-94bd-4329-bd43-10bae4ef02c2
REALM=kitajaga-internal
CLIENT_ID=kong-internal
HOST_IP=keycloak-host

PHONY: kong
kong:
	docker build -t kong-oidc:local -f kong-Dockerfile .

PHONY: add-plugin
add-plugin:
	curl -s -X POST http://localhost:8001/plugins \
	-d name=oidc \
	-d config.client_id=${CLIENT_ID} \
	-d config.client_secret=${CLIENT_SECRET} \
	-d config.bearer_only=yes \
	-d config.realm=${REALM} \
	-d config.introspection_endpoint=http://${HOST_IP}:8080/auth/realms/${REALM}/protocol/openid-connect/token/introspect \
	-d config.discovery=http://${HOST_IP}:8080/auth/realms/${REALM}/.well-known/openid-configuration

PHONY: add-consumer-plugin
add-consumer-plugin:
	curl -s -X POST http://localhost:8001/plugins \
	-d name=oidc-consumer \
	-d config.username_field=email \ 
	-d config.create_consumer=false