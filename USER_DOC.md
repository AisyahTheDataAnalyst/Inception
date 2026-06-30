

### 2. `USER_DOC.md`
---


*This project has been created as part of the 42 curriculum by aimokhta.*




# User & Administrator Documentation

This document explains how to safely manage, verify, and interact with the active services running within the Inception stack[cite: 20].

## Infrastructure Services Overview
The deployment stack runs three isolated containers, each performing a distinct operational role[cite: 3]:
1.  **`nginx` (Web Gateway)**: Intercepts all inbound web requests over an encrypted TLS connection, handling incoming connections before routing tasks to the app layer[cite: 3, 7, 11].
2.  **`wordpress` (Application Processing)**: Houses your core application engine, processing dynamic requests through PHP-FPM execution hooks[cite: 3, 13].
3.  **`mariadb` (Storage Engine)**: Protects all dynamic site configurations, user indexes, comments, and post metadata[cite: 3, 4].

---

## Stack Lifecycle Commands
All lifecycle workflows are handled via the root `Makefile` to keep container management straightforward[cite: 1, 20]:

*   **Launch Services**: `make` or `make up` (boots services detached in the background)[cite: 1, 3].
*   **Halt Services**: `make down` (gracefully stops containers without removing your site data)[cite: 1, 3].
*   **System Refresh**: `make refresh` (forces containers to rebuild and pick up configuration changes on the fly)[cite: 1].
*   **Complete Purge**: `make fclean` (wipes out your entire environment, including local host files and volumes)[cite: 1].

---

## Accessing the Platform

### Public Web Address
To view the front-end user portal, open your browser and navigate to:
*   **URL**: `https://aimokhta.42.fr`[cite: 1, 14]
*   *Note*: Standard HTTP requests (`http://aimokhta.42.fr`) will be rejected, as the gateway exclusively listens on port 443[cite: 3, 7, 19].

### WordPress Admin Dashboard
To access the backend administrative tools, append `/wp-admin` to your domain URL:
*   **URL**: `https://aimokhta.42.fr/wp-admin`
*   **Admin Username**: `wproot`[cite: 14]
*   **Author Username**: `wpuser`[cite: 14]

---

## Managing Secrets & Credentials
For security reasons, your plain-text passwords are excluded from the repository config files and are managed via local runtime mounts[cite: 3, 20]:

*   **Host Directory Location**: `../secrets/`[cite: 3]
*   **Credential Inventory**:
    *   `mysql_root_password.txt` (Root administrator database access)[cite: 3, 15]
    *   `mysql_user_password.txt` (Application user database access)[cite: 3, 16]
    *   `wp_admin_password.txt` (WordPress administrative account password)[cite: 3, 17]
    *   `wp_user_password.txt` (WordPress regular author account password)[cite: 3, 18]

> ⚠️ **CRITICAL SECURITY NOTE**: Never modify these secret files while the stack is online. If you need to rotate passwords, bring the containers down, update the files, and run `make re` to securely apply the changes[cite: 1].

---

## Service Operational Health Checks

### Container Status Evaluation
To check if your containers are up and verify their operational health status[cite: 19]:
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

