NAME = inception

all: up

up:
	sudo docker compose -f src/docker-compose.yml up --build -d

down:
	sudo docker compose -f src/docker-compose.yml down

clean:
	sudo docker system prune -af --volumes

logs:
	sudo docker compose logs -f

ps:
	sudo docker compose ps