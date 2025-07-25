#!/bin/sh

# Create necessary directories
mkdir -p /var/run/fcgiwrap
mkdir -p /tmp
mkdir -p /var/www/html

# Set permissions
chmod 777 /tmp
chmod 777 /var/www/html
chmod 755 /var/run/fcgiwrap

# Start fcgiwrap in background
/usr/bin/fcgiwrap -s unix:/var/run/fcgiwrap/socket &

# Wait a moment for fcgiwrap to start
sleep 2

# Fix socket permissions
chmod 777 /var/run/fcgiwrap/socket

# Test nginx configuration
nginx -t

# Start nginx in foreground
nginx -g "daemon off;"