# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/25 09:35:24 by aimokhta          #+#    #+#              #
#    Updated: 2025/10/25 09:43:20 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# NAME = inception

# all: up

# up:
# 	sudo docker compose -f srcs/docker-compose.yml up --build -d

# down:
# 	sudo docker compose -f srcs/docker-compose.yml down

# clean:
# 	sudo docker system prune -af --volumes

# logs:
# 	sudo docker compose logs -f

# ps:
# 	sudo docker compose ps

MARIADB_MOUNT=/home/aimokhta/data/mariadb
NGINX_MOUNT=/home/aimokhta/data/wordpress

all: dir stack

re:	fclean all

dir:
	@echo "Setting up bind mount directories..."
	@sudo mkdir -p $(MARIADB_MOUNT)
	@sudo mkdir -p $(NGINX_MOUNT)

stack:
	@echo "Running containers..."
	@docker compose up -d

stop:
	@echo "Stopping all services..."
	@docker compose stop

build:
	@echo "Building Images from Dockerfiles..."
	@docker compose build --no-cache

fclean:
	@echo "Removing everything..."
	@docker compose down --rmi local --remove-orphans -v
	@sudo rm -rf $(MARIADB_MOUNT)
	@sudo rm -rf $(NGINX_MOUNT)

.PHONY:
	all re dir stack stop build fclean