include .env
THIS_FILE := $(lastword $(MAKEFILE_LIST))
.PHONY: install up down cli node-cli build hello test start stop reup del delv fullreup zero one pull
default: up

install: up
	sleep 15
	docker-compose exec -T php composer install --no-interaction
#	docker-compose exec -T php bash -c 'drush updb -y'
#	docker-compose exec -T php bash -c 'drush cim -y'
#	docker-compose exec -T php bash -c 'drush deploy'
#   docker-compose exec -T php bash -c "drush site:install --existing-config --db-url=mysql://$(MYSQL_USER):$(MYSQL_PASS)@$(MYSQL_HOST):$(MYSQL_PORT)/$(MYSQL_DB_NAME) -y"
	docker-compose exec -T php bash -c "drush site:install --db-url=mysql://$(MYSQL_USER):$(MYSQL_PASS)@$(MYSQL_HOST):$(MYSQL_PORT)/$(MYSQL_DB_NAME) -y"
	docker-compose exec -T php bash -c 'mkdir -p "drush" && echo -e "options:\n  uri: http://$(PROJECT_BASE_URL)" > drush/drush.yml'
#	docker-compose exec -T php bash -c 'drush en beetroot_content -y'
#	docker-compose exec -T php bash -c 'drush pmu beetroot_content default_content hal -y'
#	docker-compose exec -T php bash -c 'drush en devel'
#	docker-compose exec -T php bash -c 'drush en devel_generate'
#	docker-compose exec -T php bash -c 'drush en realistic_dummy_content -y'
#	docker-compose exec -T php bash -c 'drush en better_exposed_filters -y'
	docker-compose exec -T php bash -c 'drush sql:query --file=../db.sql'
	docker-compose exec -T php bash -c 'drush cim -y'
#	docker-compose exec -T php bash -c 'drush uli'

up:
	@echo "Up $(PROJECT_NAME)!"
	docker-compose pull
	cp .env.dist .env
	docker-compose up -d --build --remove-orphans

down:
	@echo "Down $(PROJECT_NAME)."
	docker-compose exec -T php bash -c 'drush updb -y'
	docker-compose exec -T php bash -c 'drush cex -y'
	docker-compose exec -T php bash -c 'drush sql:dump --result-file=../db.sql'
	docker-compose down

cli:
	docker-compose exec php bash

node-cli:
	docker-compose exec node bash

build:
	docker-compose up -d --build php

hello:
	@echo "Testing"
	@echo "Project $(PROJECT_NAME)!"
	echo "hello world"

test:
#	docker-compose exec -T php bash -c 'composer phpcbf'
#	docker-compose exec -T php bash -c 'composer phpcs'
	docker-compose exec -T php curl 0.0.0.0:80 -H "Host: $(PROJECT_BASE_URL)"

start:
	@echo "Starting $(PROJECT_NAME)!"
	docker-compose start

stop:
	@echo "Stopping $(PROJECT_NAME)."
	docker-compose stop

reup:
	docker-compose down
	docker-compose up -d --build --remove-orphans

del:
	@echo "Deleting all containers $(PROJECT_NAME)!"
	docker system prune -a

delv:
	@echo "Deleting volumes $(PROJECT_NAME)!"
	docker system prune --volumes

fullreup:
	docker-compose down
	docker system prune -a
	docker system prune --volumes
	docker-compose pull
	docker-compose up -d --build --remove-orphans

zero:
	export DOCKER_BUILDKIT=0
	export COMPOSE_DOCKER_CLI_BUILD=0

one:
	export DOCKER_BUILDKIT=1
	export COMPOSE_DOCKER_CLI_BUILD=1

pull:
	docker pull php:8.1-apache
	docker pull mariadb:10
	docker pull phpmyadmin:5.2-apache
	docker pull traefik:2.9
	docker pull node:slim