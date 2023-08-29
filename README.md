# microservices-with-golang

This project will summarize the steps to create a microservice using Golang and Postgresql.
We will be using 4 different data models each implementing CRUD operations.
The structure of the project will be like -

- `internal/database` - This will contain the database connection and the schema and data files.
- `internal/models` - This will contain the data models.
- `internal/db_errors` - This will contain the error handling for the database.
- `internal/server` - This will contain the server and the main function.

Elaborated schema for the project using E-R diagram 

<img width="1353" alt="E-R Diagram" src="https://github.com/bindian0509/microservices-with-golang/assets/346620/906249d8-7b74-4183-aa9d-8e53e94111fe">

The following are dependencies we will be using, along with the steps to run your project locally.

Link to my github repo for the code - https://github.com/bindian0509/microservices-with-golang
## Pre-requisites (for mac OS ventura)
- Install httpie (https://httpie.org/) for testing the API
    - `brew install httpie`
- Install docker (https://docs.docker.com/docker-for-mac/install/)
    - `brew cask install docker`
- VScode with Go extension (https://code.visualstudio.com/docs/languages/go)
    - `brew cask install visual-studio-code`
- Install golang (https://golang.org/doc/install)
    - `brew install go`


## Use getting started for creating Postgres container
- Create a dir in your home folder called `data-postgres-go` under `docker-vols`
    - `mkdir -p ~/docker-vols/data-postgres-go`
- Create a postgres container
    ```shell
    docker run -d --rm \
        --name local-pg \
        -e POSTGRES_PASSWORD=postgres \
        -p 5432:5432 \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v /Users/<user-name>/docker-vols/data-postgres-go:/var/lib/postgresql/data \
    postgres
    ```
- Login via psql
    - `docker exec -it local-pg psql -U postgres`
- Create database schema via schema.sql
    - `psql -U postgres -f schema.sql`
- Insert data to the database via data.sql
    - `psql -U postgres -f data.sql`

## Setting up the go project
- Create a directory called `microservices-with-golang` in your home folder
    - `mkdir -p ~/microservices-with-golang`
    - `cd ~/microservices-with-golang`
- Use go mod init to create a go module
    - `go mod init github.com/<github-username>/microservices-with-golang`
- Use go mod tidy to download the dependencies
    - `go mod tidy`
- To start the project run
    - `go run main.go`
voila you have your project up and running
```shell
   ____    __
  / __/___/ /  ___
 / _// __/ _ \/ _ \
/___/\__/_//_/\___/ v4.11.1
High performance, minimalist Go web framework
https://echo.labstack.com
____________________________________O/_______
                                    O\
⇨ http server started on [::]:8080
```
## Testing Microservices
### Checking the database connection and liveness probe
- To start the server
    - `go run main.go`
- To check everything is working fine
    - `http :8080/readiness`
    - `http :8080/liveness`
- Expected output
```shell
    HTTP/1.1 200 OK
    Content-Length: 16
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 22 Aug 2023 11:30:52 GMT

    {
        "status": "OK"
    }
```
### Testing Get All customer API endpoint (GET)
- To get all customers
    - `http :8080/customers`
```shell
[
    {
        "address": "556 Lakewood Park, Bismarck, ND 58505",
        "customerId": "e2579031-41f8-4c1b-851d-d05dd0327230",
        "emailAddress": "penatibus.et@lectusa.com",
        "firstName": "Cally",
        "lastName": "Reynolds",
        "phoneNumber": "(901) 166-8355"
    },
    {
        "address": "4829 Badeau Parkway, Chattanooga, TN 37405",
        "customerId": "8db81915-7955-47ac-abf1-fa3a3f27e0a3",
        "emailAddress": "nibh@ultricesposuere.edu",
        "firstName": "Sydney",
        "lastName": "Bartlett",
        "phoneNumber": "(982) 231-7357"
    },
    ...
]
```
- To get customer from emailAddress (search API) (GET)
    - `http :8080/customers emailAddress=="magna.Phasellus@Phasellus.net"`
```shell
HTTP/1.1 200 OK
Content-Length: 223
Content-Type: application/json; charset=UTF-8
Date: Tue, 22 Aug 2023 13:26:37 GMT

[
    {
        "address": "602 Sommers Parkway, Norfolk, VA 23520",
        "customerId": "44f82d9d-b0a6-49b2-ac04-cb05b4cbf189",
        "emailAddress": "magna.Phasellus@Phasellus.net",
        "firstName": "Brock",
        "lastName": "Case",
        "phoneNumber": "(544) 534-1984"
    }
]
```
### Testing create customer API endpoint (POST)

- To create a new customer
    - `http POST :8080/customers firstName=John lastName=Reese emailAddress="john@root.com" phoneNumber="515-555-1235" address="36 ChinaTown, Borivali East, Mumbi, MH, INDIA"`
```shell
    HTTP/1.1 201 Created
    Content-Length: 210
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 22 Aug 2023 18:28:38 GMT

    {
        "address": "36 ChinaTown, Borivali East, Mumbi, MH, INDIA",
        "customerId": "68fb0b27-1e9a-4ce8-81ac-f41cc1e3f5d6",
        "emailAddress": "john@root.com",
        "firstName": "John",
        "lastName": "Reese",
        "phoneNumber": "515-555-1235"
    }
```
### Testing Get customer from Id API endpoint (GET)
- To get customer with `customerId`
    - `http :8080/customers/8db81915-7955-47ac-abf1-fa3a3f27e0a3`
```shell
    HTTP/1.1 200 OK
    Content-Length: 225
    Content-Type: application/json; charset=UTF-8
    Date: Wed, 23 Aug 2023 11:10:49 GMT

    {
        "address": "4829 Badeau Parkway, Chattanooga, TN 37405",
        "customerId": "8db81915-7955-47ac-abf1-fa3a3f27e0a3",
        "emailAddress": "nibh@ultricesposuere.edu",
        "firstName": "Sydney",
        "lastName": "Bartlett",
        "phoneNumber": "(982) 231-7357"
    }
```

### Testing Update customer API endpoint (PUT)
- To update customer with `customerId`
    - `http PUT :8080/customers/e2579031-41f8-4c1b-851d-d05dd0327230 address="556 Lakewood Park, Bismarck, ND 58505" customerId="e2579031-41f8-4c1b-851d-d05dd0327230" emailAddress="penatibus.et@lectusa.com" firstName="Ryan" lastName="Reynolds" phoneNumber="(901) 166-8355"`
```shell
    HTTP/1.1 200 OK
    Content-Length: 218
    Content-Type: application/json; charset=UTF-8
    Date: Fri, 25 Aug 2023 19:04:49 GMT

    {
        "address": "556 Lakewood Park, Bismarck, ND 58505",
        "customerId": "e2579031-41f8-4c1b-851d-d05dd0327230",
        "emailAddress": "penatibus.et@lectusa.com",
        "firstName": "Ryan",
        "lastName": "Reynolds",
        "phoneNumber": "(901) 166-8355"
    }
```

### Testing Delete customer API endpoint (DELETE)
- To update customer with `customerId`
    - `http DELETE :8080/customers/8db81915-7955-47ac-abf1-fa3a3f27e0a3`
```shell
    HTTP/1.1 205 Reset Content
    Content-Length: 0
    Date: Fri, 25 Aug 2023 19:31:23 GMT
```

## Running the same project with docker image (using Dockerfile)

- Step 1: Build the docker image for the application
    - `docker build -t microservices-with-golang .`
- Step 2: Run the docker image
    - `docker run -e env=docker --env-file db.docker.env --network host --name microservices-with-golang-app microservices-with-golang`
- Step 3: Since this container is not exposed to outside world we can login inside it and test the API
    - `docker exec -it microservices-with-golang-app sh`
    - `http :8080/liveness` (this will work fine since the docker file already has apk add httpie)

## Production release of the application using [Render]((https://render.com/)) free tiers

- Sign up for render.com using github or other options
- At first we need to spinup a database service (PostgreSQL)
    - Click on create a new database
    - Select the free tier
    - Select the region
    - Select the database name
    - Select the database password
    - Click on create database
- Use psql command option to be copied and dump the files to prod db via following commands
    - `PGPASSWORD=<your-db-password> psql -h xxx-a.singapore-postgres.render.com -U <user_name> <db_name> < schema.sql`
    - `PGPASSWORD=<your-db-password> psql -h xxx-a.singapore-postgres.render.com -U <user_name> <db_name> < data.sql`
- Create a new web service
    - Select the github repo
    - Select the branch
    - Select the docker file path
    - Select the port
    - Select the environment variables
        - Refer to `db.env` file for list of args
        - `sslmode=require` is for production db cluster
    - Select the free tier
    - Click on create web service
- Once the web service is created you can see the logs and the application running on the url provided by render.com
    - My cluster https://microservices-with-golang.onrender.com/liveness (liveness probe)

