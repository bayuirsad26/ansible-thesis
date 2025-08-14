# Nusatech Development DevOps Stack

## 📋 Overview

The Nusatech Development DevOps Stack is a comprehensive, secure, and automated infrastructure solution designed for ethical software development teams. Built with Ansible automation and Docker containerization, it provides a complete CI/CD pipeline with team collaboration tools.

### 🎯 Key Components

- **🐳 Docker** - Container runtime and orchestration
- **🌐 Traefik** - Reverse proxy with automatic SSL certificates
- **⚡ Jenkins** - CI/CD automation platform
- **💬 Mattermost** - Team communication and collaboration
- **🗄️ PostgreSQL** - Database backend for Mattermost
- **🔒 Security Stack** - UFW firewall, Fail2ban, automatic updates

### 🏗️ Architecture

```
Internet
    ↓
[Traefik Reverse Proxy] (Port 80/443)
    ├── SSL Termination (Let's Encrypt)
    ├── jenkins.domain.com → Jenkins (Port 8080)
    ├── chat.domain.com → Mattermost (Port 8065)
    └── traefik.domain.com → Dashboard
                ↓
    [Docker Network: nusatech_devops_network]
        ├── Jenkins Container
        ├── Mattermost Container
        └── PostgreSQL Container
```

## 🚀 Quick Start

### Prerequisites

1. **Target Server Requirements:**
   - Ubuntu 20.04+ or Debian 11+
   - 6GB+ RAM (optimized for this configuration)
   - 50GB+ disk space
   - Public IP address
   - Domain name with DNS access

2. **Control Machine Requirements:**
   - Ansible 2.9+
   - Python 3.8+
   - SSH access to target server

3. **DNS Configuration:**
   Point these subdomains to your server IP:
   ```
   traefik.yourdomain.com
   cicd.yourdomain.com  
   chat.yourdomain.com
   ```

### Installation

1. **Clone and Setup:**
   ```bash
   git clone <repository-url>
   cd nusatech-devops-stack
   make setup
   ```

2. **Configure Secrets:**
   ```bash
   make edit-vault
   ```
   Update the vault with your configuration:
   - Domain name
   - SSL email
   - Admin passwords
   - Database credentials

3. **Deploy Stack:**
   ```bash
   make deploy
   ```

4. **Check Status:**
   ```bash
   make status
   ```

## 📖 Detailed Setup Guide

### 1. Server Preparation

**Create SSH Key:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/summitethic-admin
```

**Copy public key to server:**
```bash
ssh-copy-id -i ~/.ssh/summitethic-admin.pub admin@YOUR_SERVER_IP
```

### 2. Configuration

**Update Inventory:**
Edit `inventory/hosts.yml`:
```yaml
all:
  children:
    devops_servers:
      hosts:
        nusatech-devops:
          ansible_host: YOUR_SERVER_IP
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/summitethic-admin
```

**Configure Vault:**
```bash
ansible-vault edit group_vars/vault.yml
```

Required vault variables:
```yaml
vault_domain: "yourdomain.com"
vault_ssl_email: "admin@yourdomain.com"
vault_traefik_admin_password: "secure_password_here"
vault_jenkins_admin_password: "secure_password_here"
vault_db_password: "secure_database_password"
```

### 3. Deployment Options

**Full Stack Deployment:**
```bash
make deploy              # Complete deployment
```

**Component-wise Deployment:**
```bash
make deploy-container    # Docker only
make deploy-security     # Security configuration only
make deploy-proxy        # Traefik only
make deploy-cicd         # Jenkins + Mattermost only
```

## 🔧 Configuration Details

### Ansible Configuration

**Main Config (`ansible.cfg`):**
- Uses YAML callback for readable output
- Caches facts for better performance
- Optimized SSH connections
- Automated privilege escalation

**Key Settings:**
- Remote user: `admin`
- Vault password file: `.vault_pass`
- Host key checking: Enabled for security
- Forks: 15 (parallel execution)

### Service Configuration

**Traefik Configuration:**
- Automatic SSL via Let's Encrypt
- HTTP to HTTPS redirection
- Security headers middleware
- Docker service discovery
- Dashboard with basic auth

**Jenkins Configuration:**
- Runs as root for Docker access
- Docker socket mounted
- Git and Docker tools available
- Persistent data volume
- Jenkins plugins ready for installation

**Mattermost Configuration:**
- PostgreSQL backend
- File storage in local volume
- Team size limit: 50 users
- SSL termination via Traefik
- Ready for webhook integrations

**Security Configuration:**
- UFW firewall with minimal ports
- Fail2ban SSH protection
- Automatic security updates
- Docker daemon logging limits

## 🎛️ Operations Guide

### Daily Operations

**Check Service Status:**
```bash
make status
```

**View Service Logs:**
```bash
make logs-traefik
make logs-jenkins  
make logs-mattermost
```

**Restart Services:**
```bash
make restart-services
```

### Maintenance Tasks

**Update System Packages:**
```bash
make update-system
```

**Security Audit:**
```bash
make security-audit
```

**Clean Temporary Files:**
```bash
make clean
```

### Vault Management

**Edit Encrypted Secrets:**
```bash
make edit-vault
```

**Encrypt Vault File:**
```bash
make encrypt
```

**Decrypt Vault File:**
```bash
make decrypt
```

## 🔒 Security Features

### Network Security
- **UFW Firewall:** Only ports 22, 80, 443 open
- **Fail2ban:** SSH brute force protection
- **Docker Network:** Isolated container communication

### SSL/TLS Security
- **Let's Encrypt:** Automatic certificate management
- **HSTS:** Strict transport security headers
- **Security Headers:** XSS protection, content type sniffing prevention

### Access Control
- **Ansible Vault:** Encrypted secrets management
- **Basic Auth:** Traefik dashboard protection
- **SSH Keys:** Key-based authentication only

### Container Security
- **Non-root Users:** Where possible
- **Read-only Mounts:** Docker socket mounted read-only
- **No New Privileges:** Security context enforcement

## 🚨 Troubleshooting

### Common Issues

**SSH Connection Failed:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/summitethic-admin

# Test SSH connection
ssh -i ~/.ssh/summitethic-admin admin@YOUR_SERVER_IP
```

**Docker Services Not Starting:**
```bash
# Check Docker status
make ping
ansible all -i inventory/hosts.yml -m shell -a "systemctl status docker"

# Check container logs
make logs-<service>
```

**SSL Certificate Issues:**
```bash
# Check Traefik logs for Let's Encrypt errors
make logs-traefik

# Verify DNS configuration
dig traefik.yourdomain.com
```

**Jenkins Initial Setup:**
```bash
# Get initial admin password
ansible all -i inventory/hosts.yml -m shell -a "docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
```

### Debug Mode

For verbose output during deployment:
```bash
make debug-full     # Full stack debug
make debug-proxy    # Traefik debug only
make debug-cicd     # Jenkins/Mattermost debug
```

### Service Access Issues

**Check Service Connectivity:**
```bash
# Test internal connectivity
ansible all -i inventory/hosts.yml -m shell -a "docker exec traefik nslookup jenkins"

# Check service ports
ansible all -i inventory/hosts.yml -m shell -a "netstat -tulpn | grep :80"
```

## 📁 Project Structure

```
nusatech-devops-stack/
├── ansible.cfg                 # Ansible configuration
├── Makefile                   # Automation commands
├── requirements.yml           # Ansible collections
├── site.yml                  # Main playbook
├── .gitignore                # Git ignore rules
├── inventory/
│   └── hosts.yml             # Server inventory
├── group_vars/
│   ├── all.yml              # Global variables
│   └── vault.yml            # Encrypted secrets
├── playbooks/
│   ├── container.yml        # Docker installation
│   ├── security.yml         # Security configuration
│   ├── proxy.yml           # Traefik deployment
│   └── cicd.yml            # Jenkins/Mattermost
└── roles/
    ├── container/           # Docker role
    ├── security/           # Security role
    ├── proxy/             # Traefik role
    └── cicd/             # CI/CD role
```

## 🔄 Post-Deployment Setup

### Jenkins Setup
1. Navigate to `https://cicd.yourdomain.com`
2. Use initial admin password from deployment output
3. Install suggested plugins
4. Create admin user
5. Configure Jenkins for your projects

### Mattermost Setup  
1. Navigate to `https://chat.yourdomain.com`
2. Create system admin account
3. Set up team and channels
4. Configure integrations with Jenkins

### Recommended Jenkins Plugins
- Docker Pipeline
- GitLab Integration
- Blue Ocean
- Build Timeout
- Timestamper
- Workspace Cleanup

## 🤝 Contributing

### Development Workflow
1. Test changes in development environment
2. Update documentation for any configuration changes
3. Test full deployment cycle
4. Validate security configurations

### Code Standards
- Follow Ansible best practices
- Use meaningful variable names
- Comment complex tasks
- Maintain idempotency
- Test on clean systems

## 📞 Support

### Documentation
- **Ansible Docs:** https://docs.ansible.com
- **Docker Docs:** https://docs.docker.com  
- **Traefik Docs:** https://doc.traefik.io
- **Jenkins Docs:** https://www.jenkins.io/doc
- **Mattermost Docs:** https://docs.mattermost.com

### Community
- Submit issues via project repository
- Contribute improvements via pull requests
- Follow ethical development principles

---

**Built with ❤️ for ethical software development by Nusatech Development**

*This stack prioritizes security, automation, and developer experience while maintaining ethical development practices.*