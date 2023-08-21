docker run -d --rm \
    --name local-pg \
    -e POSTGRES_PASSWORD=postgres \
    -p 5432:5432 \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /Users/bharatverma/docker-vols/data-postgres-go:/var/lib/postgresql/data \
    postgres

docker exec -it local-pg /bin/bash

#inside container
psql -U postgres

#show  all tables for wisdom db 
\dt wisdom.*
