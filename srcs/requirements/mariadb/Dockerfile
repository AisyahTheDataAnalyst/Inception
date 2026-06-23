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

# Default execution for runtime
ENTRYPOINT ["./tools/mariadb_setup.sh"]