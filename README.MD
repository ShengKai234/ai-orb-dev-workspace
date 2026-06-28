# Orbstack AI-env tool

## Architecture
```txt
macOS (OrbStack)
├── ai-base VM（Claude Code，build ince）
├── Shared infra（PostgreSQL）
├── Workspace "feature-a"
│   ├── OrbStack VM（clone from base）
│   ├── git worktree → feature-a branch
│   └── Rails services → api.feature-a.orb.local
└── Workspace "feature-b"
    ├── OrbStack VM（clone from base）
    ├── git worktree → feature-b branch
    └── Rails services → api.feature-b.orb.local
```

## Orbstack install & remote
```shell
brew install obstack
```

Install specific vm os
```shell
orb create ubuntu:24.04 ai-dev-base
```

Remote to vm
```shell
orb shell -m ai-dev-base
```

Copy vm
```shell
orb clone ai-dev-base feature-a
```

## Main Plugins and tools details (in setup.sh)
Install plugins/tools
Docker & Docker-compose
```shell
# docker
curl -fsSL https://get.docker.com | bash

# docker-compose
sudo apt-get install -y docker-compose-plugin

# permission setting
sudo usermod -aG docker $USER
newgrp docker
```

npm & Claude Code
```shell
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo bash -
sudo apt-get install -y nodejs
node --version   # v24.x.x
npm --version    # 11.16.0

sudo npm install -g @anthropic-ai/claude-code
claude -v        # 2.x.xxx (Claude Code)

# Claude Code login
claude code
# Claude Code sharing to all
ln -s /mnt/mac/Users/kaikai/.claude ~/.claude
ln -s /mnt/mac/Users/kaikai/.claude.json ~/.claude.json
```

Other tool
```shell
echo 'bind "\"\e[A\": history-search-backward"' >> ~/.bashrc
echo 'bind "\"\e[B\": history-search-forward"'  >> ~/.bashrc
source ~/.bashrc
```

## Infra vm Plugin and tools
```shell
# TODO
```

## How to use it
git worktree
```shell
git worktree add feature-a/repo-x feature-a-branch
```
