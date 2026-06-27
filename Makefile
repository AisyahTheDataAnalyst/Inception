# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aimokhta <aimokhta@student.42kl.edu.my>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/16 09:31:30 by aimokhta          #+#    #+#              #
#    Updated: 2026/06/27 00:29:59 by aimokhta         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Program name
NAME = inception

# Colours
GREEN = \033[0;32m
BLUE = \033[0;34m
PURPLE = \033[1;35m
PURPLE_BG_WHITE_TEXT = \033[37;45m		# Standard white text on a purple background
BRIGHT_WHITE_PURPLE_BG = \033[1;37;45m	# Bright/Bold white text on a purple background (usually looks cleaner)
RESET = \033[0K\033[0m  				#\033[0K for reset background colour

all:
	@mkdir -p /home/aimokhta/data/wordpress_data
	@mkdir -p /home/aimokhta/data/mariadb_data
	@echo "${PURPLE}\n🛠️  Building and launching containers...\n ${RESET}"
	@docker compose -f ./srcs/docker-compose.yml up --build -d
	@echo "${PURPLE}\n⏳ Just finalizing WordPress database configurations in background... ${RESET}"
	@until docker logs wordpress 2>&1 | grep -q "Starting PHP-FPM"; do sleep 0.5; done
	@echo "${PURPLE}\n🎉 Inception is 💯% Ready! Visit my domain: https://aimokhta.42.fr\n ${RESET}"

down:
	@docker compose -f ./srcs/docker-compose.yml down

clean:
	@echo "${PURPLE}\n🗑️  Removing all containers, volumes and images including public base images in Docker...\n${RESET}"
	@docker compose -f ./srcs/docker-compose.yml down --volumes --rmi all
	@echo "${PURPLE}\n🗑️  Done removed every single containers, volumes and images in Docker! ${RESET}"
	
fclean: clean
	@sudo rm -rf ~/data
	@echo "${PURPLE}\n🗑️  Removed all volumes on host! ${RESET}\n"

re: fclean all

.PHONY: all down clean fclean re
