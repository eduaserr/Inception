NAME		= inception
COMPOSE_YML	= srcs/docker-compose.yml

all : up

up :
	@echo "Running multi-container setup"
	@mkdir -p $(HOME)/data
	@mkdir -p $(HOME)/data/mariadb
	@mkdir -p $(HOME)/data/wordpress
	@docker compose -f ${COMPOSE_YML} up -d --build

down :
	@echo "Stopping $(NAME)...$(END)"
	@docker compose -f ${COMPOSE_YML} down

clean : down
	@echo "Removing containers...$(END)"
	@docker system prune -a

fclean :
	@echo "Removing containers and volumes...$(END)"
	@if [ -n "$$(docker ps -aq)" ]; then docker stop $$(docker ps -aq); fi
	@docker system prune --all --volumes --force
	@docker network prune --force
	@docker volume prune --force
	@docker image prune --force --all
	@docker builder prune --force --all
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q); fi
	@if [ -d "$(HOME)/data" ]; then sudo rm -rf $(HOME)/data; fi

re : clean all
	@echo "Rebuilding containers...$(END)"

.PHONY: all up down clean fclean re