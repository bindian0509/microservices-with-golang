# microservices-with-golang

A simple microservice with postgres as database

## Pre-requisites (for mac OS ventura)
- Install httpie (https://httpie.org/) for testing the API
    - `brew install httpie`
- Install docker (https://docs.docker.com/docker-for-mac/install/)
    - `brew cask install docker`
- VScode with Go extension (https://code.visualstudio.com/docs/languages/go)
    - `brew cask install visual-studio-code`
- Install golang (https://golang.org/doc/install)
    - `brew install go`


## Use getting started for creating postgres container
- Create a dir in your home folder called `postgres-data` under `docker-vols`
    - `mkdir -p ~/docker-vols/postgres-data`
- Create a postgres container
    ```docker run -d --rm \
    --name local-pg \
    -e POSTGRES_PASSWORD=postgres \
    -p 5432:5432 \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /Users/<user-name>/docker-vols/data-postgres-go:/var/lib/postgresql/data \
    postgres```
- Login via psql
    - `docker exec -it local-pg psql -U postgres`
- Create database schema via schema.sql
    - `psql -U postgres -f schema.sql`
- Insert data to the database via data.sql
    - `psql -U postgres -f data.sql`

## Run the microservice
- To start the server
    - `go run main.go`
- To check everything is working fine
    - `http :8080/readiness`
    - `http :8080/liveness`
- Expected output
    ```
    HTTP/1.1 200 OK
    Content-Length: 16
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 22 Aug 2023 11:30:52 GMT

    {
        "status": "OK"
    }
    ```
