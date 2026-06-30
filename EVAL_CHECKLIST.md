


### `EVAL_CHECKLIST.md`

---
```markdown
# 42 Inception Correction Sheet Step-by-Step Blueprint

This checklist follows the exact sequence of the official 42 Inception evaluation sheet. Use these commands side-by-side with your evaluator to verify every requirement smoothly[cite: 19].
```
---

## Part 1: Preliminary Requirements & Hygiene

Before spinning up the infrastructure, the evaluator will check your repository structure and environment setup[cite: 20].

### A. Repository Structure Check
Ensure that all required configuration directories are in place and no loose files are left in the root[cite: 20]:
```bash
# List everything in the root directory to prove cleanliness
ls -la
```

Verify that only the `Makefile`, `srcs/`, and your documentation (`.md`) files exist at the root level.

### B. Environment Variables & Secrets Separation

Verify that your plain-text configuration options exist within `srcs/.env`, but highly sensitive root passwords remain safely isolated within your local, unpushed `secrets/` directory:

```bash
# Check the contents of the public environment file
cat srcs/.env

# Check that the secrets directory exists locally but is ignored by Git
ls -la secrets/
git status
```

Confirm that no raw root database passwords or admin account credentials are exposed inside `srcs/.env` or tracked in Git history.

### C. Initialization via Makefile

Prove that your environment builds from scratch and boots cleanly on demand:

```bash
# Run the default rule to build images, configure host volumes, and launch containers
make
```

*The command must execute without throwing script execution faults, build warnings, or configuration errors.*

---

## Part 2: General Architecture & Dockerfile Audits

The evaluator will inspect your custom build definitions to ensure you are not using unapproved shortcuts.

### A. Virtual Machine Enforcement

Show your evaluator that the entire stack runs within an isolated Linux VM environment rather than natively on your host machine:

```bash
# Display system distribution information
uname -a
cat /etc/os-release
```

### B. "From Scratch" Image Building Validation

Prove that you are utilizing raw, authorized base distributions (`Debian Bookworm` and `Alpine 3.23`) rather than pulling ready-made, pre-packaged stacks from Docker Hub:

```bash
# Check Nginx Dockerfile for base layer definition
grep -i "^FROM" srcs/requirements/nginx/Dockerfile

# Check WordPress Dockerfile for base layer definition
grep -i "^FROM" srcs/requirements/wordpress/Dockerfile

# Check MariaDB Dockerfile for base layer definition
grep -i "^FROM" srcs/requirements/mariadb/Dockerfile
```

Each statement must point to a clean base distribution image, not a pre-configured solution like `FROM wordpress:latest`.

### C. PID 1 Signal Handover Audit

Prove that your custom setup scripts use `exec "$@"` to pass control directly to the core binaries instead of running unnecessary tracking loops like `tail -f /dev/null`:

```bash
# Scan entrypoint scripts for clean process handovers
grep -n "exec" srcs/requirements/mariadb/tools/mariadb_setup.sh
grep -n "exec" srcs/requirements/nginx/tools/nginx_setup.sh
grep -n "exec" srcs/requirements/wordpress/tools/wp_setup.sh
```

---

## Part 3: Orchestration & Configuration (Docker Compose)

The orchestration file controls your network structures and container definitions.

### A. Configuration Integrity Check

Verify that your configurations are managed using the proper Compose file layout:

```bash
# Display the service composition setup file
cat srcs/docker-compose.yml
```

Verify that the file version parameter is set correctly, and that container name configurations align with the standard rules.

### B. Strict Network Isolation

Confirm that your custom network is a private bridge (`inception`) and that the insecure host mode (`network: host`) or deprecated link features are not used:

```bash
# Inspect the active network configurations
docker network ls
docker network inspect inception
```

Ensure all three containers (`nginx`, `wordpress`, `mariadb`) are mapped to the bridge network and can communicate with each other securely.

---

## Part 4: NGINX Web Service Gateway (Presentation Layer)

Nginx manages the outer boundary of your stack and handles secure TLS traffic.

### A. Port 443 Exclusive Ingress

Confirm that your entry point only processes encrypted traffic on port 443 and completely rejects standard, unencrypted HTTP traffic on port 80:

```bash
# 1. Attempt unencrypted connection on port 80 (Must throw connection failure)
curl -I http://aimokhta.42.fr 

# 2. Attempt encrypted connection on port 443 (Must connect successfully)
curl -kI https://aimokhta.42.fr
```

### B. TLS Version Compliance Verification

Prove that insecure cryptographic protocols (SSLv3, TLSv1.0, TLSv1.1) are explicitly blocked, and that only verified TLSv1.2 or TLSv1.3 connections are accepted:

```bash
# Test legacy TLSv1.1 parameters (Must fail handshake)
openssl s_client -connect aimokhta.42.fr:443 -tls1_1

# Test verified TLSv1.2 compliance (Must connect successfully)
openssl s_client -connect aimokhta.42.fr:443 -tls1_2

# Test verified TLSv1.3 compliance (Must connect successfully)
openssl s_client -connect aimokhta.42.fr:443 -tls1_3
```

*Look for the line containing `Protocol : TLSv1.2` or `Protocol : TLSv1.3` inside the connection feedback blocks.*

### C. Loopback Domain Mapping Check

Verify that your custom domain route points to your local system address:

```bash
# Inspect the loopback mapping configuration
cat /etc/hosts | grep aimokhta.42.fr
```

---

## Part 5: WordPress Application Service (Application Layer)

The application container executes your core dynamic layouts using PHP-FPM.

### A. Container Component Isolation

Verify that Nginx is not running inside your WordPress container, confirming that your application and web services are kept strictly separate:

```bash
# Scan the active internal process environment of WordPress
docker exec -it wordpress ps aux
```

The output should only show your PHP-FPM runtime processes and your setup script—no Nginx processes allowed.

### B. Network Socket Configuration Check

Verify that your WordPress environment uses a network socket on port 9000 rather than a local unix socket file, allowing Nginx to route data across the bridge network:

```bash
# Verify active listening boundaries inside the container
docker exec -it wordpress netstat -lntp | grep 9000
```

### C. WP-CLI Configuration & User Identity Audit

The evaluation rules state that your administrative username cannot contain terms like `admin` or `administrator`. Use WP-CLI to audit your current configuration:

```bash
# List all registered users, display names, and roles
docker exec -it wordpress wp user list --allow-root
```

Confirm that `wproot` holds the administrator privileges and `wpuser` maps to an author status.

---

## Part 6: MariaDB Database Service (Data Layer)

The database engine acts as your persistent data store and must remain shielded from external network access.

### A. Database Service Isolation

Verify that neither Nginx nor WordPress are running inside your database container:

```bash
# Scan internal process list inside MariaDB
docker exec -it mariadb ps aux
```

The output should only show your core database engine processes (`mysqld` or `mysqld_safe`).

### B. Network Boundary Isolation Audit

Prove that the database service cannot be reached from your host machine, ensuring it is only accessible internally within the bridge network:

```bash
# Attempt direct host-to-database connection (Must fail to connect)
mysql -u sqluser -h 127.0.0.1 -P 3306 -p
```

### C. Live Table Population Check

Log into your database using your application user credentials to prove that your data tables are properly structured and mapped:

```bash
# Access the MariaDB management CLI shell
docker exec -it mariadb mysql -u sqluser -p
```

*Enter your application user password when prompted. Then, run the following SQL queries to inspect your tables:*

```sql
-- access the databases
SHOW DATABASES;

-- Select your wordpress target context
USE wordpress_db;

-- Display all tables populated by the WordPress installer loop
SHOW TABLES;
```

*Ensure you see a clean output listing your core WordPress tables (e.g., `wp_users`, `wp_posts`, `wp_comments`). Type `exit` to close the interface.*

---

## Part 7: Volumes & Persistent Storage Validation

Data persistence across system restarts is one of the core technical requirements of the project.

### A. Volume Mapping Verification

Ensure that both named volumes point directly to your dedicated host paths under `/home/aimokhta/data/`:

```bash
# Verify the physical location of your database storage volume
docker volume inspect mariadb_data | grep Mountpoint

# Verify the physical location of your website content storage volume
docker volume inspect wordpress_data | grep Mountpoint
```

### B. Persistence Stress Test

Prove that your data is safe even if the container infrastructure is completely torn down and removed:

```bash
# 1. Log into [https://aimokhta.42.fr/wp-admin](https://aimokhta.42.fr/wp-admin) and post a new comment or page

# 2. Stop and remove all active containers and network elements
make down

# 3. Check the host data path to ensure your raw files remain intact on the host
ls -la /home/aimokhta/data/mariadb_data
ls -la /home/aimokhta/data/wordpress_data

# 4. Spin up the entire infrastructure from scratch
make

# 5. Refresh your browser and confirm your custom posts and comments are still there!
```

---

## Part 8: Live Evaluation Stress Test ("The Curveball")

During evaluation, you may be asked to change an environment variable or network port configuration on the fly to prove you understand how the components interact.

### Scenario: Changing the Gateway Ingress from Port 443 to Port 8443

1. Bring down the active stack:


```bash
make down
```


2. Open your orchestration setup file: `nano srcs/docker-compose.yml`.
3. Locate the `nginx` container block and update the `ports` mapping rule:


```yaml
ports:
  - "8443:443"
```


4. Rebuild and launch the updated stack:


```bash
make
```


5. Demonstrate to the evaluator that the site now loads successfully at the new address: `https://aimokhta.42.fr:8443`.
