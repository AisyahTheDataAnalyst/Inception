# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/25 09:35:24 by aimokhta          #+#    #+#              #
#    Updated: 2025/10/25 10:43:39 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

MARIADB_MOUNT=/home/aimokhta/data/mariadb
WORDPRESS_MOUNT=/home/aimokhta/data/wordpress
NGINX_MOUNT=/home/aimokhta/data/nginx

all: dir stack

re: fclean all

dir:
	@echo "Setting up bind mount directories..."
	@sudo mkdir -p $(MARIADB_MOUNT)
	@sudo mkdir -p $(WORDPRESS_MOUNT)
	@sudo mkdir -p $(NGINX_MOUNT)
	@sudo chmod 755 $(MARIADB_MOUNT) $(WORDPRESS_MOUNT) $(NGINX_MOUNT)

stack:
	@echo "Cleaning any existing containers..."
	@docker compose -f srcs/docker-compose.yml down 2>/dev/null || true
	@docker rm -f nginx mariadb wordpress 2>/dev/null || true
	@echo "Running containers..."
	@docker compose -f srcs/docker-compose.yml up -d --build

stop:
	@echo "Stopping all services..."
	@docker compose -f srcs/docker-compose.yml stop

clean:
	@echo "Cleaning containers and networks..."
	@docker compose -f srcs/docker-compose.yml down
	@docker rm -f nginx mariadb wordpress 2>/dev/null || true

build:
	@echo "Building Images from Dockerfiles..."
	@docker compose -f srcs/docker-compose.yml build --no-cache

fclean: clean
	@echo "Removing everything..."
	@docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans 2>/dev/null || true
	@docker system prune -af 2>/dev/null || true
	@sudo rm -rf $(MARIADB_MOUNT) 2>/dev/null || true
	@sudo rm -rf $(WORDPRESS_MOUNT) 2>/dev/null || true
	@sudo rm -rf $(NGINX_MOUNT) 2>/dev/null || true
	@echo "Cleanup completed!"

logs:
	@docker compose -f srcs/docker-compose.yml logs -f

ps:
	@docker compose -f srcs/docker-compose.yml ps

.PHONY: all re dir stack stop clean build fclean logs ps