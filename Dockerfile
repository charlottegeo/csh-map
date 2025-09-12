FROM docker.io/python:3.13-slim-trixie
MAINTAINER Ram Zallan (ram@csh.rit.edu)

# Install Debian packages required for dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libffi-dev \
    libldap2-dev \
    libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure OpenLDAP to use the system trusted CA Store
RUN mkdir -p /etc/ldap && echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" >> /etc/ldap/ldap.conf

# Add application user
RUN groupadd -r map && useradd --no-log-init -r -g map map

# Add files and set permissions
ADD . /opt/map
RUN chown -R map:map /opt/map
WORKDIR /opt/map

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Drop privileges
USER map

# Expose default port
EXPOSE 8080

# Run application with Gunicorn
CMD gunicorn --workers=2 --bind ${MAP_SERVER_IP:-0.0.0.0}:${MAP_SERVER_PORT:-8080} app