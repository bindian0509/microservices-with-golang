#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Load environment variables from db.env
if [ -f "db.env" ]; then
    export $(cat db.env | grep -v '^#' | xargs)
else
    print_error "db.env file not found!"
    exit 1
fi

# Configuration from db.env
DB_HOST=${host:-root}
DB_USER=${user:-secret}
DB_PASSWORD=${password:-postgres}
DB_NAME=${dbname:-wisdom}
DB_PORT=${port:-5432}
DB_SSLMODE=${sslmode:-disable}
APP_PORT=${app_port:-:8080}
CONTAINER_NAME="pg-local"
VOLUME_NAME="pg-local-data"

# Parse command line arguments
FRESH_START=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fresh) FRESH_START=true ;;
        -h|--help)
            echo "Usage: ./deploy-local.sh [options]"
            echo "Options:"
            echo "  --fresh    Remove existing container and volume, start fresh"
            echo "  -h, --help Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Microservices with Golang - Local Deployment Script    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check prerequisites
print_step "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker."
    exit 1
fi
print_success "Docker daemon is running"

if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go first."
    exit 1
fi
print_success "Go is installed ($(go version | awk '{print $3}'))"

# Check if golang-migrate is installed (optional)
MIGRATE_AVAILABLE=false
if command -v migrate &> /dev/null; then
    MIGRATE_AVAILABLE=true
    print_success "golang-migrate is installed"
else
    print_warning "golang-migrate not installed. Will create tables directly."
fi

# Step 2: Setup PostgreSQL container with persistent volume
print_step "Setting up PostgreSQL container..."

# Handle fresh start if requested
if [ "$FRESH_START" = true ]; then
    print_warning "Fresh start requested - removing existing container and volume..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    docker volume rm ${VOLUME_NAME} 2>/dev/null || true
fi

# Create volume if it doesn't exist
if ! docker volume ls --format '{{.Name}}' | grep -q "^${VOLUME_NAME}$"; then
    docker volume create ${VOLUME_NAME} > /dev/null
    print_success "Created persistent volume: ${VOLUME_NAME}"
else
    print_success "Using existing volume: ${VOLUME_NAME}"
fi

# Check if container exists and is running
CONTAINER_EXISTS=false
CONTAINER_RUNNING=false
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    CONTAINER_EXISTS=true
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        CONTAINER_RUNNING=true
    fi
fi

if [ "$CONTAINER_RUNNING" = true ]; then
    print_success "PostgreSQL container already running"
elif [ "$CONTAINER_EXISTS" = true ]; then
    print_warning "Starting existing container: ${CONTAINER_NAME}"
    docker start ${CONTAINER_NAME} > /dev/null
    print_success "PostgreSQL container started"
else
    # Start new postgres container with persistent volume
    docker run -d \
        --name ${CONTAINER_NAME} \
        -e POSTGRES_USER=${DB_USER} \
        -e POSTGRES_PASSWORD=${DB_PASSWORD} \
        -e POSTGRES_DB=${DB_NAME} \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v ${VOLUME_NAME}:/var/lib/postgresql/data \
        -p ${DB_PORT}:5432 \
        postgres:latest > /dev/null
    print_success "PostgreSQL container created with persistent volume"
fi

# Step 3: Wait for PostgreSQL to be ready
print_step "Waiting for PostgreSQL to be ready..."

MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if docker exec ${CONTAINER_NAME} pg_isready -U ${DB_USER} -d ${DB_NAME} > /dev/null 2>&1; then
        print_success "PostgreSQL is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo -n "."
    sleep 1
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    print_error "PostgreSQL failed to start within ${MAX_ATTEMPTS} seconds"
    exit 1
fi

# Step 4: Create wisdom schema
print_step "Creating 'wisdom' schema..."

docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c "CREATE SCHEMA IF NOT EXISTS wisdom;" > /dev/null 2>&1
print_success "Schema 'wisdom' ready"

# Step 5: Run database migrations (skip if already applied)
print_step "Checking database migrations..."

# Check if tables already exist
TABLES_EXIST=$(docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'wisdom' AND table_name = 'customers';" 2>/dev/null | tr -d ' ')

if [ "$TABLES_EXIST" = "1" ]; then
    print_success "Migrations already applied (tables exist)"
else
    print_step "Running database migrations..."

    if [ "$MIGRATE_AVAILABLE" = true ]; then
        DB_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=${DB_SSLMODE}&search_path=wisdom"
        migrate -path db/migration -database "${DB_URL}" -verbose up 2>&1 | while read line; do
            echo "    $line"
        done
        print_success "Migrations completed"
    else
        # Run migrations directly using psql in container with wisdom schema
        if [ -f "db/migration/000001_init_schema.up.sql" ]; then
            # Prepend SET search_path and run migrations
            echo "SET search_path TO wisdom;" | cat - db/migration/000001_init_schema.up.sql | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} > /dev/null 2>&1
            print_success "Schema created directly via psql"
        else
            print_warning "No migration files found"
        fi
    fi
fi

# Step 6: Install Go dependencies
print_step "Installing Go dependencies..."
go mod download
print_success "Dependencies installed"

# Step 7: Build the application
print_step "Building the application..."
go build -o ./bin/server .
print_success "Application built successfully"

# Step 8: Start the server
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Deployment Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Database:${NC}  PostgreSQL running on port ${DB_PORT}"
echo -e "  ${BLUE}Server:${NC}    Starting on port ${APP_PORT}"
echo ""
echo -e "  ${YELLOW}Endpoints:${NC}"
echo -e "    - Health:    http://localhost${APP_PORT}/readiness"
echo -e "    - Customers: http://localhost${APP_PORT}/customers"
echo -e "    - Products:  http://localhost${APP_PORT}/products"
echo -e "    - Services:  http://localhost${APP_PORT}/services"
echo -e "    - Vendors:   http://localhost${APP_PORT}/vendors"
echo ""
echo -e "  ${YELLOW}Data:${NC}      Persistent volume: ${VOLUME_NAME}"
echo ""
echo -e "  ${YELLOW}Commands:${NC}"
echo -e "    - Stop server:     Press Ctrl+C"
echo -e "    - Stop database:   docker stop ${CONTAINER_NAME}"
echo -e "    - Fresh restart:   ./deploy-local.sh --fresh"
echo ""

print_step "Starting server..."
./bin/server

