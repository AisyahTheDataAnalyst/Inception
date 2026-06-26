# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/16 09:31:30 by aimokhta          #+#    #+#              #
#    Updated: 2026/06/26 23:23:49 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

all:
	@mkdir -p /home/aimokhta/data/wordpress_data
	@mkdir -p /home/aimokhta/data/mariadb_data
	@docker compose -f ./srcs/docker-compose.yml up --build -d

down:
	@docker compose -f ./srcs/docker-compose.yml down

clean:
	@docker compose -f ./srcs/docker-compose.yml down --volumes --rmi all

fclean: clean
	@sudo rm -rf ~/data
	@echo "----ALL CLEAN----"

re: fclean all

.PHONY: all down clean fclean re
