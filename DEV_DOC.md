
### 3. `DEV_DOC.md`
---
*This project has been created as part of the 42 curriculum by aimokhta.*




# Developer & System Administrator Documentation

This document outlines the step-by-step setup, configuration pathways, and core development tools used to maintain the Inception project stack.

## Development Prerequisites

### OS Base Requirements
*   **Host Environment**: Linux / Ubuntu Virtual Machine running within an isolated VirtualBox environment.
*   **Required Packages**: `make`, `curl`, `git`, `openssl`, and `docker-env` dependencies.

### Core Architecture Components
*   **Docker Engine**: `v20.10+`
*   **Docker Compose Plugin**: `v2.0+`

---

## Directory Schema Topology
The repository is structured to separate your service configurations from runtime application data:


```

├── Makefile                           # Root build automation controller
├── .gitignore                         # Prevents tracking local environment parameters
├── secrets/                           # Untracked host directory for sensitive credentials
│   ├── mysql_root_password.txt       
│   ├── mysql_user_password.txt        
│   ├── wp_admin_password.txt         
│   └── wp_user_password.txt           
└── srcs/                              # Core project configuration directory
├── .env                           # Dynamic architecture environment parameters
├── docker-compose.yml             # Service orchestration definition file
└── requirements/                  # Container requirement specifications
├── mariadb/
│   ├── Dockerfile             # MariaDB build routine (Debian Bookworm)
│   ├── .dockerignore          # Context build optimizations
│   └── tools/mariadb_setup.sh # Database configuration entrypoint script
├── nginx/
│   ├── Dockerfile             # Nginx build routine (Alpine 3.23)
│   ├── .dockerignore          # Context build optimizations
│   ├── conf/default.template  # Dynamic proxy template configuration
│   └── tools/nginx_setup.sh   # SSL and proxy configuration generation script
└── wordpress/
├── Dockerfile             # WordPress build routine (Debian Bookworm)
├── .dockerignore          # Context build optimizations
└── tools/wp_setup.sh      # WP-CLI application provision script

```

---

## Environmental Setup & Configuration

### 1. Secrets Initialization
Before launching the stack, provision the target `secrets/` directory at the root of your repository to securely manage runtime database and application credentials:
```bash
mkdir -p secrets
echo "your_secure_root_pass" > secrets/mysql_root_password.txt
echo "your_secure_user_pass" > secrets/mysql_user_password.txt
echo "your_secure_wp_admin" > secrets/wp_admin_password.txt
echo "your_secure_wp_user" > secrets/wp_user_password.txt

```

### 2. Environment Configurations (`srcs/.env`)

Create the global infrastructure variable context inside your configuration directory:

```ini
MYSQL_DATABASE=your_mysql_database_name
MYSQL_USER_USERNAME=your_mysql_regularUser_username

WP_ADMIN_USERNAME=your_wordpress_admin_username
WP_ADMIN_EMAIL=your_wordpress_admin_email
WP_USER_USERNAME=your_wordpress_regularUser_username
WP_USER_EMAIL=your_wordpress_regularUser_email
WP_DOMAIN_URL=your_wordpress_domain (<login>.42.fr)
WP_WEBSITE_TITLE=your_wordpress_website_title

```

---

## Process Architecture & PID 1 Implementation

To satisfy standard enterprise patterns and avoid fragile shell patches (like `tail -f`), each service relies on clean script-to-binary handovers:

* **MariaDB Execution Lifecycle**: `mariadb_setup.sh` boots the database engine temporarily with network controls disabled (`--skip-networking`) to safely configure your custom tables and users. Once configured, it uses `exec "$@"` to hand over control to `mysqld_safe`, which becomes the main foreground process (PID 1).


* **Nginx Processing Lifecycle**: `nginx_setup.sh` generates your self-signed SSL certificate on the fly and clears old configuration defaults. It then uses `exec "$@"` to launch `nginx -g 'daemon off;'` as the primary process, ensuring the container remains active in the foreground.


* **WordPress Initialization Lifecycle**: `wp_setup.sh` uses a connection loop to wait for the database to come online. Once ready, it automatically builds your `wp-config.php`, downloads files, and sets up your application accounts via WP-CLI. Finally, it uses `exec "$@"` to pass control to `php-fpm8.2 -F` on port 9000.



---

## Data Persistence & Storage Mapping

Persistent application data is secured using Docker Named Volumes backed by local host paths. This ensures structural modifications, database updates, and user content remain intact even after full system reboots:

| Logical Docker Volume | Targeted Mount Destination | Absolute Physical Path on Host |
| --- | --- | --- |
| `mariadb_data`<br> | `/var/lib/mysql`<br> | `/home/aimokhta/data/mariadb_data`<br> |
| `wordpress_data`<br> | `/var/www/html`<br> | `/home/aimokhta/data/wordpress_data`<br> |

### Inspecting Storage Volumetrics

To verify that your data directories are correctly mapped to the host filesystem during evaluation:

```bash
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```

---

## Troubleshooting & Debugging Guide

### Entering Live Container Environments

To run interactive terminal sessions inside active containers for debugging:

```bash
# Accessing Database Management Console
docker exec -it mariadb mysql -u sqluser -p

# Intercepting Application Filesystem
docker exec -it wordpress sh

# Inspecting Web Server Configuration
docker exec -it nginx ash
```

### Evaluating Network Configurations

To review the structural topology of your private communication bridge:

```bash
docker network inspect inception
```

This display details every assigned container IP address and cross-linked gateway route.
