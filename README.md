# microservices-with-golang

A simple microservice in go with postgres as database

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

## Tesing Microservices
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
