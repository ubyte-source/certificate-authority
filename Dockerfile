# Use an Alpine base image
FROM docker.io/amd64/alpine:3.19.1

# Define environment variables for the image
ENV ARCHIVE=/app/configuration/archive \
    ARCHIVE_INDEX=/app/configuration/ca/db/certificate.db \
    STARTUP_COMMAND_RUN_FASTCGIWRAP="fcgiwrap -c 8 -f -s unix:/home/www/fcgiwrap.socket | fcgiwrap" \
    STARTUP_COMMAND_RUN_NGINX="nginx"

# Install necessary packages
RUN apk update && \
    apk add --no-cache nginx fcgiwrap bash curl openssl && \
    rm -rf /var/cache/apk/*

# Copy necessary files from the host machine to the image
COPY source /app
COPY wrapper /
COPY nginx.conf /etc/nginx/nginx.conf

# Setup user and permissions for security and proper file access
RUN adduser -D -g www www && \
    mkdir -p /app/configuration && \
    touch /var/log/generation.log && \
    chown -R www:www /var/lib/nginx /var/log/nginx /app /etc/ssl /etc/nginx /var/log/generation.log && \
    chmod +x -R /app && \
    chmod +x wrapper

# Cleanup unnecessary files
RUN rm -Rf /etc/nginx/sites-enabled && \
    rm -Rf /etc/nginx/sites-available

# Define exposed ports
EXPOSE 8080 8443

# Switch to user www to avoid running the app as root
USER www

# Define mountable volume
VOLUME /app/configuration

# Health check to ensure the service is running
HEALTHCHECK CMD curl --connect-timeout 4 --fail http://localhost:8080/healthz || exit 1

# Set the wrapper as the entrypoint in JSON format
ENTRYPOINT [ "/wrapper" ]