#!/bin/bash
# DevOps Skill - Environment Check Script
# Checks the project environment status

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

check_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Check system environment
print_header "System Environment"

# Node.js
if command -v node &> /dev/null; then
    check_ok "Node.js: $(node --version)"
else
    check_fail "Node.js: Not installed"
fi

# npm
if command -v npm &> /dev/null; then
    check_ok "npm: $(npm --version)"
else
    check_fail "npm: Not installed"
fi

# Python
if command -v python3 &> /dev/null; then
    check_ok "Python: $(python3 --version)"
else
    check_fail "Python: Not installed"
fi

# pip
if command -v pip3 &> /dev/null; then
    check_ok "pip: $(pip3 --version | awk '{print $2}')"
else
    check_fail "pip: Not installed"
fi

# Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        check_ok "Docker: Running ($(docker --version | awk '{print $3}' | tr -d ','))"
    else
        check_warn "Docker: Installed but not running"
    fi
else
    check_fail "Docker: Not installed"
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    check_ok "Docker Compose: $(docker-compose --version | awk '{print $4}' | tr -d ',')"
elif docker compose version &> /dev/null; then
    check_ok "Docker Compose: $(docker compose version | awk '{print $4}')"
else
    check_fail "Docker Compose: Not installed"
fi

# Check project files
print_header "Project Files"

# package.json
if [ -f "package.json" ]; then
    check_ok "package.json found"
    if [ -d "node_modules" ]; then
        check_ok "node_modules installed"
    else
        check_warn "node_modules not installed (run: npm install)"
    fi
else
    check_warn "package.json not found"
fi

# requirements.txt
if [ -f "requirements.txt" ]; then
    check_ok "requirements.txt found"
    if [ -d "venv" ]; then
        check_ok "Python venv exists"
    else
        check_warn "Python venv not found (run: python3 -m venv venv)"
    fi
else
    check_warn "requirements.txt not found"
fi

# Docker files
if [ -f "Dockerfile" ]; then
    check_ok "Dockerfile found"
else
    check_warn "Dockerfile not found"
fi

if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    check_ok "docker-compose.yml found"
else
    check_warn "docker-compose.yml not found"
fi

# Check environment variables
print_header "Environment Variables"

if [ -f ".env" ]; then
    check_ok ".env file exists"

    # Check key environment variables (example)
    if [ -n "$OPENAI_API_KEY" ] || grep -q "OPENAI_API_KEY" .env 2>/dev/null; then
        check_ok "OPENAI_API_KEY: configured"
    fi

    if [ -n "$DATABASE_URL" ] || grep -q "DATABASE_URL" .env 2>/dev/null; then
        check_ok "DATABASE_URL: configured"
    fi
else
    check_warn ".env file not found"
    if [ -f ".env.example" ]; then
        check_warn "Copy .env.example to .env and configure"
    fi
fi

# Check port usage
print_header "Port Status"

check_port() {
    local port=$1
    local service=$2
    if lsof -i :$port > /dev/null 2>&1; then
        local pid=$(lsof -t -i :$port | head -1)
        local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
        check_ok "Port $port ($service): In use by $process (PID: $pid)"
    else
        check_warn "Port $port ($service): Available"
    fi
}

check_port 3000 "NestJS/Next.js"
check_port 8000 "Python/FastAPI"
check_port 8001 "Python Service"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"
check_port 27017 "MongoDB"

echo -e "\n${GREEN}Environment check complete!${NC}\n"
