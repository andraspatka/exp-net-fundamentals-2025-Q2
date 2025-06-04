.PHONY: build shell

build:
	docker-compose build

shell:
	docker-compose up -d && docker exec -it aws /bin/bash
