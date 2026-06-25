FROM debian:bookworm

# Install MariaDB and tools
# /var/lib/apt/lists/*  
# =>	Lists only from "apt update" are downloaded & saved as text files directly into this directory, 
# 		that take up spaces
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*			
	
# Copy configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Setup runtime directories with correct permissions
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Copy and prepare setup script with updated permission
COPY tools/mariadb_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_setup.sh

# To communicate with other containers that it intended to at runtime
EXPOSE 3306

# No, they cannot be split into two separate lines.
# In a Dockerfile, HEALTHCHECK and CMD are not two independent instructions; 
# rather, CMD is a required keyword parameter that belongs entirely to the HEALTHCHECK command. 
# Think of it like an if statement in programming: you can't put if on line 1 and condition on line 2 as a separate statement, because the condition is part of the if syntax.
HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
    CMD mysqladmin ping -h localhost \
    # -u root -p$(cat /run/secrets/mysql_root_password) => no need
    # industry standard, as per official & production-grade Docker images maintained by the MariaDB and MySQL teams on Docker Hub
    # An ideal health check should only ask fundamental question: "Is the database service alive and accepting connections?" 
    # It should not care who is asking or what the credentials are.

# Default execution for runtime
# no need to init with ./tools/mariadb_.. coz /usr/local/bin is already system's global env path
ENTRYPOINT ["mariadb_setup.sh"]