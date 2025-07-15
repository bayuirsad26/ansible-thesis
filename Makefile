# Nusatech Development DevOps Stack Makefile
# Automation untuk deployment infrastruktur dengan prinsip etis

.PHONY: help install setup deploy deploy-container deploy-security deploy-proxy deploy-cicd
.PHONY: encrypt decrypt edit-vault status clean lint check ping full-deploy

# Variables
INVENTORY := inventory/hosts.yml
VAULT_FILE := group_vars/vault.yml
PLAYBOOK_DIR := playbooks
REQUIREMENTS := requirements.yml

# Default target
.DEFAULT_GOAL := help

## Setup and Installation
install: ## Install Ansible collections and dependencies
	@echo "🔧 Installing Ansible collections..."
	ansible-galaxy collection install -r $(REQUIREMENTS)

setup: install ## Complete setup including SSH key verification
	@echo "🚀 Setting up SummitEthic DevOps environment..."
	@if [ ! -f ~/.ssh/summitethic-admin ]; then \
		echo "❌ SSH key ~/.ssh/summitethic-admin not found!"; \
		echo "Please ensure your SSH private key is in place."; \
		exit 1; \
	fi
	@chmod 600 ~/.ssh/summitethic-admin
	@echo "✅ Setup completed successfully!"

## Deployment Targets
deploy-container: ## Deploy Docker and container runtime
	@echo "🐳 Deploying container runtime..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/container.yml

deploy-security: ## Deploy security configurations (UFW, Fail2ban)
	@echo "🔒 Deploying security configurations..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/security.yml

deploy-proxy: ## Deploy Traefik reverse proxy
	@echo "🌐 Deploying Traefik reverse proxy..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/proxy.yml

deploy-cicd: ## Deploy CI/CD stack (Jenkins, Mattermost, PostgreSQL)
	@echo "⚡ Deploying CI/CD stack..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/cicd.yml

full-deploy: ## Complete deployment of entire stack
	@echo "🚀 Starting full SummitEthic DevOps stack deployment..."
	ansible-playbook -i $(INVENTORY) site.yml

deploy: full-deploy ## Alias for full-deploy

## Vault Management
encrypt: ## Encrypt vault file
	@echo "🔐 Encrypting vault file..."
	ansible-vault encrypt $(VAULT_FILE)

decrypt: ## Decrypt vault file
	@echo "🔓 Decrypting vault file..."
	ansible-vault decrypt $(VAULT_FILE)

edit-vault: ## Edit encrypted vault file
	@echo "✏️  Editing vault file..."
	ansible-vault edit $(VAULT_FILE)

## Utility Operations
ping: ## Test connectivity to all hosts
	@echo "🏓 Testing connectivity to DevOps servers..."
	ansible all -i $(INVENTORY) -m ping

status: ## Check status of deployed services
	@echo "📊 Checking service status..."
	ansible all -i $(INVENTORY) -m shell -a "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

check: lint ## Check playbook syntax and best practices
	@echo "🔍 Checking playbook syntax..."
	ansible-playbook -i $(INVENTORY) site.yml --syntax-check

lint: ## Lint Ansible playbooks
	@echo "🧹 Linting Ansible playbooks..."
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ansible-lint .; \
	else \
		echo "⚠️  ansible-lint not installed. Run: pip install ansible-lint"; \
	fi

clean: ## Clean up temporary files and caches
	@echo "🧽 Cleaning up temporary files..."
	@find . -name "*.retry" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@rm -rf .ansible_facts_cache/
	@rm -rf ansible.log
	@echo "✅ Cleanup completed!"

## Development and Debugging
debug-container: ## Debug container deployment with verbose output
	@echo "🐛 Debug container deployment..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/container.yml -vv

debug-proxy: ## Debug proxy deployment with verbose output
	@echo "🐛 Debug proxy deployment..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/proxy.yml -vv

debug-cicd: ## Debug CI/CD deployment with verbose output
	@echo "🐛 Debug CI/CD deployment..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/cicd.yml -vv

debug-full: ## Debug full deployment with verbose output
	@echo "🐛 Debug full deployment..."
	ansible-playbook -i $(INVENTORY) site.yml -vv

## Service Management
restart-services: ## Restart all Docker services
	@echo "♻️  Restarting all services..."
	ansible all -i $(INVENTORY) -m shell -a "cd /opt/nusatech-devops && docker compose -f traefik-compose.yml restart"
	ansible all -i $(INVENTORY) -m shell -a "cd /opt/nusatech-devops && docker compose -f cicd-compose.yml restart"

logs-traefik: ## Show Traefik logs
	@echo "📋 Showing Traefik logs..."
	ansible all -i $(INVENTORY) -m shell -a "docker logs traefik --tail 50"

logs-jenkins: ## Show Jenkins logs
	@echo "📋 Showing Jenkins logs..."
	ansible all -i $(INVENTORY) -m shell -a "docker logs jenkins --tail 50"

logs-mattermost: ## Show Mattermost logs
	@echo "📋 Showing Mattermost logs..."
	ansible all -i $(INVENTORY) -m shell -a "docker logs mattermost --tail 50"

## Security Operations
security-audit: ## Run security audit on deployed infrastructure
	@echo "🔍 Running security audit..."
	ansible all -i $(INVENTORY) -m shell -a "ufw status verbose"
	ansible all -i $(INVENTORY) -m shell -a "fail2ban-client status"
	ansible all -i $(INVENTORY) -m shell -a "docker system df"

update-system: ## Update system packages on all hosts
	@echo "⬆️  Updating system packages..."
	ansible all -i $(INVENTORY) -m apt -a "update_cache=yes upgrade=dist" --become

## Information Targets
info: ## Show deployment information
	@echo "ℹ️  SummitEthic DevOps Stack Information"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📋 Project: Nusatech DevOps Stack"
	@echo "🏢 Company: SummitEthic"
	@echo "🎯 Purpose: Ethical software development infrastructure"
	@echo ""
	@echo "🔧 Stack Components:"
	@echo "   • Docker & Docker Compose"
	@echo "   • Traefik (Reverse Proxy)"
	@echo "   • Jenkins (CI/CD)"
	@echo "   • Mattermost (Team Communication)"
	@echo "   • PostgreSQL (Database)"
	@echo "   • UFW Firewall"
	@echo "   • Fail2ban (Intrusion Prevention)"
	@echo ""
	@echo "🌐 Access URLs:"
	@echo "   • Traefik Dashboard: https://traefik.your-domain.com"
	@echo "   • Jenkins: https://cicd.your-domain.com"
	@echo "   • Mattermost: https://chat.your-domain.com"

help: ## Show this help message
	@echo "SummitEthic DevOps Stack - Makefile Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Built with ethical principles at the core 🌟"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "📋 Quick Start:"
	@echo "   1. make setup          # Setup environment"
	@echo "   2. make edit-vault     # Configure secrets"
	@echo "   3. make deploy         # Deploy full stack"
	@echo "   4. make status         # Check deployment"
	@echo ""
	@echo "🔒 Security First:"
	@echo "   • All secrets are encrypted with Ansible Vault"
	@echo "   • UFW firewall configured with minimal access"
	@echo "   • Fail2ban protection against intrusions"
	@echo "   • SSL certificates via Let's Encrypt"
	@echo ""
	@echo "💡 For more info: make info"