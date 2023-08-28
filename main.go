package main

import (
	"strconv"
	"log"
	"os"
	"github.com/joho/godotenv"

	"github.com/bindian0509/microservices-with-golang/internal/database"
	"github.com/bindian0509/microservices-with-golang/internal/server"
)


func main() {
	err := godotenv.Load("db.env")
	if err != nil {
		log.Fatalf("Some error occured. Err: %s", err)
	}
	host := os.Getenv("host")
	user := os.Getenv("user")
	password := os.Getenv("password")
	dbname := os.Getenv("dbname")
	sslMode := os.Getenv("sslmode")
    port, err := strconv.Atoi(os.Getenv("port"))
	if err != nil {
		log.Fatalf("failed to convert port to int: %s", err)
	}
	db, err := database.NewDatabaseClient(host, user, password, dbname, int32(port),sslMode)
	if err != nil {
		log.Fatalf("failed to initialize Database Client: %s", err)
	}
	srv := server.NewEchoServer(db)
	if err := srv.Start(); err != nil {
		log.Fatal(err.Error())
	}
}

