#!/bin/bash
# DevOps Skill - Service Start Script Template
# Modify to fit your project

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check port usage
check_port() {
    local port=$1
    if lsof -i :$port > /dev/null 2>&1; then
        log_warn "Port $port is already in use"
        return 1
    fi
    return 0
}

# Service health check
health_check() {
    local url=$1
    local max_attempts=${2:-30}
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            log_info "Health check passed: $url"
            return 0
        fi
        echo -n "."
        sleep 1
        ((attempt++))
    done

    log_error "Health check failed: $url"
    return 1
}

# Check Docker status
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker Desktop."
        return 1
    fi
    log_info "Docker is running"
    return 0
}

# Activate Python venv
activate_python_venv() {
    local venv_path=$1
    if [ -d "$venv_path" ]; then
        source "$venv_path/bin/activate"
        log_info "Python venv activated: $venv_path"
    else
        log_warn "Python venv not found: $venv_path"
        log_info "Creating venv..."
        python3 -m venv "$venv_path"
        source "$venv_path/bin/activate"
    fi
}

# Install Node.js dependencies
install_node_deps() {
    local project_dir=$1
    if [ -f "$project_dir/package.json" ]; then
        if [ ! -d "$project_dir/node_modules" ]; then
            log_info "Installing Node.js dependencies..."
            (cd "$project_dir" && npm install)
        else
            log_info "Node.js dependencies already installed"
        fi
    fi
}

# Install Python dependencies
install_python_deps() {
    local project_dir=$1
    if [ -f "$project_dir/requirements.txt" ]; then
        log_info "Installing Python dependencies..."
        pip install -r "$project_dir/requirements.txt"
    fi
}

# Main function (modify to fit your project)
main() {
    log_info "Starting services..."

    # Example: Using Docker Compose
    # if check_docker; then
    #     docker-compose up -d
    #     health_check "http://localhost:3000/health"
    # fi

    # Example: Running individual services
    # check_port 3000 && (cd backend && npm run start &)
    # check_port 8001 && (cd python-service && source venv/bin/activate && uvicorn app.main:app --port 8001 &)

    log_info "All services started!"
}

# Run script
main "$@"
