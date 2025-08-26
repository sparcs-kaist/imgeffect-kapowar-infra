STAGE_COMPOSE=docker compose -p kapowar-stage -f docker-compose.stage.yaml

stage-up:
	$(STAGE_COMPOSE) up -d

stage-down:
	$(STAGE_COMPOSE) down

stage-migrate:
	@if $(STAGE_COMPOSE) ps --services --filter "status=running" | grep -q "^next$$"; then \
		$(STAGE_COMPOSE) stop next; \
	fi && \
	$(STAGE_COMPOSE) up postgres --wait -d && \
	$(STAGE_COMPOSE) run --rm migrator ./migrate.sh
