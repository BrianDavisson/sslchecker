#!/bin/bash

# Save posted URLs to a temp file, run ssl_checker, return results as JSON
TMP_FILE="/tmp/ssl_server_list.txt"

# Create /tmp directory if it doesn't exist and ensure it's writable
mkdir -p /tmp
chmod 777 /tmp

# Create /var/www/html directory if it doesn't exist and ensure it's writable
mkdir -p /var/www/html
chmod 777 /var/www/html

# Read POST data from stdin and save to temp file
cat | tr '\r' '\n' > "$TMP_FILE"

# Ensure temp file was created
if [ ! -f "$TMP_FILE" ]; then
    echo "Content-Type: application/json"
    echo ""
    echo '{"results": [], "timestamp": "'$(date -Iseconds)'", "error": "Failed to create temp file"}'
    exit 1
fi

# Run the checker
/usr/local/bin/ssl_checker.sh

# Return the JSON results
echo "Content-Type: application/json"
echo ""
if [ -f "/var/www/html/results.json" ]; then
    cat /var/www/html/results.json
else
    echo '{"results": [], "timestamp": "'$(date -Iseconds)'", "error": "No results file found"}'
fi