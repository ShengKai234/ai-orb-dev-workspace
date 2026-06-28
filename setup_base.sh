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

MAC_USER=""
SKIP_CLAUDE=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --mac-user) MAC_USER="$2"; shift ;;
    --skip-claude) SKIP_CLAUDE=true ;;
  esac
  shift
done

if [[ -z "$MAC_USER" ]]; then
  MAC_USER=$(ls /mnt/mac/Users/ | grep -v Shared | head -1)
  [[ -z "$MAC_USER" ]] && SKIP_CLAUDE=true
fi

# =============================================================================
section "System update"
# =============================================================================
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y \
  build-essential curl git vim wget unzip jq \
  ca-certificates gnupg lsb-release \
  libssl-dev libreadline-dev zlib1g-dev libffi-dev libyaml-dev

# =============================================================================
section "Docker"
# =============================================================================
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi
if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
fi

# =============================================================================
section "Node.js 24 (LTS)"
# =============================================================================
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_24.x | sudo bash -
  sudo apt-get install -y nodejs
fi

# =============================================================================
section "Claude Code"
# =============================================================================
if ! command -v claude &>/dev/null; then
  sudo npm install -g @anthropic-ai/claude-code
fi

if [[ "$SKIP_CLAUDE" == false ]]; then
  CLAUDE_DIR="/mnt/mac/Users/$MAC_USER/.claude"
  CLAUDE_JSON="/mnt/mac/Users/$MAC_USER/.claude.json"
  [[ -d "$CLAUDE_DIR" && ! -L "$HOME/.claude" ]]      && ln -s "$CLAUDE_DIR"  "$HOME/.claude"
  [[ -f "$CLAUDE_JSON" && ! -L "$HOME/.claude.json" ]] && ln -s "$CLAUDE_JSON" "$HOME/.claude.json"
fi

# =============================================================================
section "Shell enhancements"
# =============================================================================
# prefix search history command
if ! grep -q 'history-search-backward' "$HOME/.bashrc"; then
  echo 'bind "\"\e[A\": history-search-backward"' >> "$HOME/.bashrc"
  echo 'bind "\"\e[B\": history-search-forward"'  >> "$HOME/.bashrc"
fi


# =============================================================================
section "Done"
# =============================================================================
echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo "  MAC_USER:    $MAC_USER"
echo "  Docker:      $(docker --version | cut -d' ' -f3 | tr -d ',')"
echo "  Node.js:     $(node --version)"
echo "  npm:         $(npm --version)"
echo "  Claude Code: $(claude -v 2>/dev/null || echo 'installed')"
echo ""
[[ "$SKIP_CLAUDE" == true ]] && warn "Claude auth not set. Run: claude login"
echo ""
warn "Run the following to apply changes:"
echo "  newgrp docker     # apply docker group"
echo "  source ~/.bashrc  # apply shell enhancements"
