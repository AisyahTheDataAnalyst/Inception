

### 2. `USER_DOC.md`
---


*This project has been created as part of the 42 curriculum by aimokhta.*




# User & Administrator Documentation

This document explains how to safely manage, verify, and interact with the active services running within the Inception stack.

## Infrastructure Services Overview
The deployment stack runs three isolated containers, each performing a distinct operational role:
1.  **`nginx` (Web Gateway)**: Intercepts all inbound web requests over an encrypted TLS connection, handling incoming connections before routing tasks to the app layer.
2.  **`wordpress` (Application Processing)**: Houses your core application engine, processing dynamic requests through PHP-FPM execution hooks.
3.  **`mariadb` (Storage Engine)**: Protects all dynamic site configurations, user indexes, comments, and post metadata.

---

## Stack Lifecycle Commands
All lifecycle workflows are handled via the root `Makefile` to keep container management straightforward:

*   **Launch Services**: `make` or `make up` (boots services detached in the background).
*   **Halt Services**: `make down` (gracefully stops containers without removing your site data).
*   **System Refresh**: `make refresh` (forces containers to rebuild and pick up configuration changes on the fly).
*   **Complete Purge**: `make fclean` (wipes out your entire environment, including local host files and volumes).

---

## Accessing the Platform

### Public Web Address
To view the front-end user portal, open your browser and navigate to:
*   **URL**: `https://aimokhta.42.fr`
*   *Note*: Standard HTTP requests (`http://aimokhta.42.fr`) will be rejected, as the gateway exclusively listens on port 443.

### WordPress Admin Dashboard
To access the backend administrative tools, append `/wp-admin` to your domain URL:
*   **URL**: `https://aimokhta.42.fr/wp-admin`
*   **Admin Username**: `wproot`
*   **Author Username**: `wpuser`

---

## Managing Secrets & Credentials
For security reasons, your plain-text passwords are excluded from the repository config files and are managed via local runtime mounts:

*   **Host Directory Location**: `../secrets/`
*   **Credential Inventory**:
    *   `mysql_root_password.txt` (Root administrator database access)
    *   `mysql_user_password.txt` (Application user database access)
    *   `wp_admin_password.txt` (WordPress administrative account password)
    *   `wp_user_password.txt` (WordPress regular author account password)

> ⚠️ **CRITICAL SECURITY NOTE**: Never modify these secret files while the stack is online. If you need to rotate passwords, bring the containers down, update the files, and run `make re` to securely apply the changes.

---

## Service Operational Health Checks

### Container Status Evaluation
To check if your containers are up and verify their operational health status:
```bash
docker compose -f srcs/docker-compose.yml ps
```

All containers should display an status of `Up` along with a `(healthy)` indicator.

### Checking Runtime Container Logs

If you encounter runtime issues or need to inspect service behavior, view the live log feeds:

```bash
# General infrastructure dashboard view
docker compose -f srcs/docker-compose.yml logs -f

# Isolated target service views
docker logs nginx
docker logs wordpress
docker logs mariadb
```

