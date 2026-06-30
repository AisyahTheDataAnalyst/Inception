

### 1. `README.md`
---


*This project has been created as part of the 42 curriculum by aimokhta.*

## Description
**Inception** is a System Administration project designed to build a multi-container, fully virtualized infrastructure using Docker Compose[cite: 20]. The system runs entirely within a dedicated Virtual Machine (VM) and uses multi-layered microservices to orchestrate a secure, containerized web environment[cite: 3, 20].

The architecture comprises three foundational infrastructure services built entirely from scratch via custom Dockerfiles, utilizing explicitly permitted base images (Debian Bookworm and Alpine 3.23)[cite: 9, 11, 13, 20]:
*   **Database Layer (`mariadb`)**: Built on `debian:bookworm`, managing transactional persistence for the web app[cite: 3, 9].
*   **Application Layer (`wordpress`)**: Built on `debian:bookworm`, executing core dynamic PHP processing through `php-fpm8.2`[cite: 3, 13].
*   **Presentation & Security Layer (`nginx`)**: Built on `alpine:3.23`, serving as a secure reverse proxy and the infrastructure's lone ingress gateway over port 443 via verified TLSv1.2/v1.3 protocols[cite: 3, 7, 11].

### Infrastructure Dependency & Layer Topology
The containers operate within an isolated Docker network configuration to avoid exposed structural weaknesses[cite: 3, 20]. The architecture follows a strict structural dependency pipeline:

```
┌──────────────────────────────────────────────────┐
│                  Computer HOST                   │ 💻   
└────────────────────────┬─────────────────────────┘
                         │
                     (Port 443)
                         ▼
┌──────────────────────────────────────────────────┐
│                 NGINX Container                  │ 🔒   ──►  (Gateway / TLS v1.2/v1.3)
│           (Gateway / TLS v1.2 / v1.3)            │
└────────────────────────┬─────────────────────────┘
                         │
               (FastCGI: Port 9000)
                         ▼
┌──────────────────────────────────────────────────┐
│               WordPress Container                │ ⚡   ──►  (Application Layer)
│               (Application Layer)                │
└────────────────────────┬─────────────────────────┘
                         │
                 (MySQL: Port 3306)
                         ▼
┌──────────────────────────────────────────────────┐
│                MariaDB Container                 │ 🗄️   ──►  (Data Layer)
│                   (Data Layer)                   │
└──────────────────────────────────────────────────┘
```
---

## Technical Architectural Comparisons

### 1. Virtual Machines vs. Docker Containers
*   **Virtual Machines (VMs)**: Virtualize physical hardware through a Hypervisor layer. Every individual VM runs a complete guest operating system instance, resulting in high storage consumption, slower boot schedules, and considerable CPU/RAM overhead.
*   **Docker Containers**: Virtualize at the OS kernel level. Containers run as isolated user-space processes that directly share the Host machine's kernel. This achieves minimal storage overhead, instantaneous execution boundaries, and near-bare-metal compute performance.

### 2. Docker Secrets vs. Environment Variables
*   **Environment Variables (`.env`)**: Handled in plain text via the configuration layer[cite: 14]. They are ideal for non-sensitive operational values (domain URLs, database names)[cite: 14], but are highly vulnerable to exposure through image inspection commands (`docker inspect`) or process monitoring.
*   **Docker Secrets**: Securely mount runtime files into memory inside specific containers (`/run/secrets/`)[cite: 3, 4, 6]. Passwords never persist inside the static image file metadata, protecting sensitive credentials from leaking into your Git repository[cite: 20].

### 3. Docker Bridge Network vs. Host Network
*   **Docker Bridge Network**: Isolates all container networks into a private internal bridge (`inception`)[cite: 3]. Containers interact safely using secure internal DNS service discovery names[cite: 3, 6], exposing explicit communication lines while preventing external host intervention[cite: 20].
*   **Host Network (`network: host`)**: Completely strips container network isolation layers, causing the container to bind directly to the host machine's interface. This introduces significant security risks and port binding conflicts, and is strictly prohibited in this project architecture[cite: 20].

### 4. Docker Named Volumes vs. Bind Mounts
*   **Docker Named Volumes**: High-performance storage spaces managed entirely through Docker's internal file structures[cite: 3]. They abstract host pathways and isolate structural web and database assets from human error on the host machine[cite: 3, 20].
*   **Bind Mounts**: Explicitly map a user-defined directory pathway on the host to an absolute destination inside the container. Bind mounts depend heavily on the host machine's directory tree, filesystem formatting, and user permissions.

---

## Instructions

### Compilation and Initialization
Ensure your host machine maps your designated local loopback address within the `/etc/hosts` file:
```bash
127.0.0.1 aimokhta.42.fr
```

To compile components, establish storage targets, configure run permissions, and launch the multi-container environment, execute the root Makefile rule:

```bash
make
```

### Deconstruct and Clean Stack

To gracefully stop all active containers and disconnect runtime bridge configurations:

```bash
make down
```

To clear containers, networks, volumes, and drop host storage targets (`/home/aimokhta/data`) completely:

```bash
make fclean
```

---

## Resources & AI Usage

### References

* *Docker Documentation:* https://docs.docker.com/
* *WordPress CLI Integration:* https://make.wordpress.org/cli/
* *Alpine Package Repository:* https://pkgs.alpinelinux.org/packages
* *MariaDB Administration Guides:* https://mariadb.com/kb/en/documentation/

### AI Tools Implementation Disclosure

AI was leveraged as a pair-programmer to ensure clean, standard-compliant implementations across the following lifecycle items:

1. **POSIX Shell Handover Logic**: Assisted in organizing the safe initialization flow within `mariadb_setup.sh`, ensuring the daemon boots cleanly under temporary flags before executing the primary `mysqld_safe` command.


2. **PID 1 Process Principles**: Optimized the use of `exec "$@"` inside execution routines to guarantee that background applications receive operational kernel signals directly from Docker without creating dead zombie processes.


3. **Template Engine Substitution**: Fixed `envsubst` execution issues inside `nginx_setup.sh`, protecting internal configuration tokens while correctly applying the dynamic `$WP_DOMAIN_URL` parameter.




