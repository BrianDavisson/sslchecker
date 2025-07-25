FROM alpine:latest

# Install dependencies (Alpine uses apk instead of apt)
RUN apk add --no-cache nginx openssl bash curl fcgiwrap

# Copy custom scripts and HTML assets
COPY ssl_checker.sh /usr/local/bin/ssl_checker.sh
COPY index.html /var/www/html/index.html
COPY submit_urls.sh /usr/local/bin/submit_urls.sh
COPY nginx.conf /etc/nginx/http.d/default.conf

# Give execution permissions to scripts
RUN chmod +x /usr/local/bin/ssl_checker.sh
RUN chmod +x /usr/local/bin/submit_urls.sh

# Create directory for fcgiwrap socket
RUN mkdir -p /var/run/fcgiwrap

# Create and set permissions for temp and web directories
RUN mkdir -p /var/www/html 
RUN mkdir -p /tmp
RUN chmod 777 /tmp /var/www/html

# Expose nginx port
EXPOSE 80

# Setup startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh 

CMD ["/start.sh"]