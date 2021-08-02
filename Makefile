default: build
	@echo Build....

build: # DOCKER_SCAN_SUGGEST=false
	docker build -t playground_laravel .

run:
	docker run --rm -it -h 0.0.0.0 -p 8000:8000 -v ./workspace:/workspace playground_laravel /bin/bash

up:
	docker-compose up  -d

down:
	docker-compose down

bash:
	docker-compose exec laravel /bin/bash
