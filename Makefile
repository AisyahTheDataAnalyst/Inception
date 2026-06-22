# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/16 09:31:30 by aimokhta          #+#    #+#              #
#    Updated: 2026/06/16 09:31:31 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

all:
	@mkdir -p ~/data/wordpress
	@mkdir -p ~/data/mariadb
	@docker compose -f ./srcs/docker-compose.yml up --build -d

down:
	@docker compose -f ./srcs/docker-compose.yml down

clean:
	@docker compose -f ./srcs/docker-compose.yml down --rmi all -v

fclean: clean
	@sudo rm -rf ~/data

re: fclean all

.PHONY: all down clean fclean re
