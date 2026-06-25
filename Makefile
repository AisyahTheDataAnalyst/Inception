# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/16 09:31:30 by aimokhta          #+#    #+#              #
#    Updated: 2026/06/25 18:40:51 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

all:
	@mkdir -p /home/aimokhta/data/wordpress
	@mkdir -p /home/aimokhta/data/mariadb
# its dangerous to write ~/data/mariadb coz 
# on some evaluation VMs or if run under specific root tasks, 
# ~/ can point to /root/data
	@docker compose -f ./srcs/docker-compose.yml up --build -d

down:
	@docker compose -f ./srcs/docker-compose.yml down

clean:
	@docker compose -f ./srcs/docker-compose.yml down --rmi all -v

fclean: clean
	@sudo rm -rf ~/data

re: fclean all

.PHONY: all down clean fclean re
