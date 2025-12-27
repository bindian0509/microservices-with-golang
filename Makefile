DB_URL=postgresql://root:secret@localhost:5432/wisdom?sslmode=disable

postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:latest

createdb:
	docker exec -it postgres createdb --username=root --owner=root wisdom

dropdb:
	docker exec -it postgres dropdb wisdom

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

deploy:
	./deploy-local.sh

server:
	go run main.go

.PHONY: postgres createdb dropdb migrateup migrateup1 migratedown deploy server
