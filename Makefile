PROD_COMPOSE=docker compose -p kapowar -f docker-compose.prod.yaml
STAGE_COMPOSE=docker compose -p kapowar-stage -f docker-compose.stage.yaml

help:
	@echo "Available commands:"
	@echo "  prod-up        Start the production environment"
	@echo "  prod-down      Stop the production environment"
	@echo "  prod-migrate   Run database migrations in the production environment"
	@echo "  prod-standby   Start the standby PostgreSQL instance"
	@echo "  prod-failover  Promote the standby PostgreSQL instance"
	@echo "  stage-up       Start the staging environment"
	@echo "  stage-down     Stop the staging environment"
	@echo "  stage-migrate  Run database migrations in the staging environment"

prod-up:
	$(PROD_COMPOSE) up -d

prod-down:
	$(PROD_COMPOSE) down

prod-migrate:
	$(PROD_COMPOSE) pull migrator
	$(PROD_COMPOSE) stop next || true
	$(PROD_COMPOSE) up postgres --wait -d
	$(PROD_COMPOSE) run --rm migrator ./migrate.sh

prod-standby:
	$(PROD_COMPOSE) up postgres -d

prod-failover:
	$(PROD_COMPOSE) exec -T postgres pg_ctl -D /bitnami/postgresql/data promote

stage-up:
	$(STAGE_COMPOSE) up -d

stage-down:
	$(STAGE_COMPOSE) down

stage-migrate:
	$(STAGE_COMPOSE) pull migrator
	$(STAGE_COMPOSE) stop next || true
	$(STAGE_COMPOSE) up postgres --wait -d
	$(STAGE_COMPOSE) run --rm migrator ./migrate.sh
