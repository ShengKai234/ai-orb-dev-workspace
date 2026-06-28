#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${GREEN}[setup]${NC} $1"; }
warn()    { echo -e "${YELLOW}[warn]${NC} $1"; }
section() { echo -e "\n${BLUE}===== $1 =====${NC}"; }

# 取得 script 所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$SCRIPT_DIR/infra_script"

# =============================================================================
section "System update"
# =============================================================================
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl ca-certificates gnupg

# =============================================================================
section "Docker"
# =============================================================================
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi
if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
fi
if ! docker compose version &>/dev/null; then
  sudo apt-get install -y docker-compose-plugin
fi

# =============================================================================
section "PostgreSQL (Docker)"
# =============================================================================
if [[ ! -f "$INFRA_DIR/docker-compose.yml" ]]; then
  echo -e "${RED}[error]${NC} $INFRA_DIR/docker-compose.yml not found."
  exit 1
fi

cd "$INFRA_DIR"
docker compose up -d

log "Waiting for PostgreSQL to be ready..."
sleep 5

# =============================================================================
section "Done"
# =============================================================================
echo ""
echo -e "${GREEN}✓ Infra VM ready!${NC}"
echo ""
echo "  Connection string:"
echo "    postgresql://postgres:password@shared-infra.orb.local:5432/<db_name>"
echo ""
warn "Run the following to apply docker group:"
echo "  newgrp docker"
