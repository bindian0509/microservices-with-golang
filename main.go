package main

import (
	"log"

	"github.com/bindian0509/microservices-with-golang/internal/database"
	"github.com/bindian0509/microservices-with-golang/internal/server"
)


func main() {
	db, err := database.NewDatabaseClient()
	if err != nil {
		log.Fatalf("failed to initialize Database Client: %s", err)
	}
	srv := server.NewEchoServer(db)
	if err := srv.Start(); err != nil {
		log.Fatal(err.Error())
	}
}

