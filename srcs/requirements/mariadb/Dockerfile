FROM debian:bookworm

# this is highly recommended for your Debian containers
# Stop interactive prompts during installation
# If you want it to only apply while the image is building and disappear afterward, use ARG
# using ENV, that variable stays alive inside the container forever, even after it finishes building.
ARG DEBIAN_FRONTEND=noninteractive

# Install MariaDB and tools
# /var/lib/apt/lists/*  
# =>	Lists only from "apt update" are downloaded & saved as text files directly into this directory, 
# 		that take up spaces
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*			

# ip from 127.0.0.1 => 0.0.0.0
# method 1 = Copy configuration (50-server.cnf)
# COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf => use sed instead coz just want to replace ip address only
# method 2  = sed command (in Dockerfile here, what im using now)
# Replace 127.0.0.1 with 0.0.0.0 in the default MariaDB config file 
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
# method 3 => command (docker-compose.yml) => DONT USE => newer MariaDB installation dont accept database runtime config flags directly on CLI => crashes => "unhealthy" => + many more other issues => not suitable for manual installation

# Setup runtime directories with correct permissions
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Copy and prepare setup script with updated permission
COPY tools/mariadb_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_setup.sh

# EXPOSE in Dockerfile does nothing - Just documentation purposes only
EXPOSE 3306

# No, they cannot be split into two separate lines.
# In a Dockerfile, HEALTHCHECK and CMD are not two independent instructions; 
# rather, CMD is a required keyword parameter that belongs entirely to the HEALTHCHECK command. 
# Think of it like an if statement in programming: you can't put if on line 1 and condition on line 2 as a separate statement, because the condition is part of the if syntax.
HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
    CMD mysqladmin ping -h localhost --protocol=tcp
    # -u root -p$(cat /run/secrets/mysql_root_password) => no need
    # industry standard, as per official & production-grade Docker images maintained by the MariaDB and MySQL teams on Docker Hub
    # An ideal health check should only ask fundamental question: "Is the database service alive and accepting connections?" 
    # It should not care who is asking or what the credentials are.

# Default execution for runtime
# no need to init with ./tools/mariadb_.. coz /usr/local/bin is already system's global env path
ENTRYPOINT ["mariadb_setup.sh"]
CMD ["mysqld_safe"]
