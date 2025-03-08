docker run -d  \
    --name postgres \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=secret \
    -p 5432:5432 \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /Users/bharatverma/docker-vols/data-postgres-go:/var/lib/postgresql/data \
    postgres
    
# insert data to postgres
docker exec -i postgres psql -U postgres < schema.sql
docker exec -i postgres psql -U postgres < data.sql

docker exec -it local-pg /bin/bash

#inside container
psql -U postgres

#show  all tables for wisdom db
\dt wisdom.*
