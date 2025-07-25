#!/bin/bash

LOG_FILE="/var/www/html/results.json"
SERVER_LIST_FILE="/tmp/ssl_server_list.txt"

# Clear results file at the start and initialize JSON array
echo '{"results": [], "timestamp": "'$(date -Iseconds)'"}' > "$LOG_FILE"

check_ssl_dates() {
  local target_url="$1"
  
  # Check if URL is empty
  if [ -z "$target_url" ]; then
    return 1
  fi
  
  # If no port is specified, assume 443 (HTTPS)
  if [[ "$target_url" != *:* ]]; then
    target_url="${target_url}:443"
  fi
  
  local hostname="${target_url%:*}"
  local port="${target_url##*:}"
  local timestamp=$(date -Iseconds)
  local status="success"
  local error_message=""
  local cert_info=""
  
  # Check certificate
  CERT_INFO=$(timeout 10 openssl s_client -connect "$target_url" -servername "$hostname" < /dev/null 2>/dev/null | openssl x509 -noout -dates -issuer -subject 2>/dev/null)
  
  if [ -z "$CERT_INFO" ]; then
    status="error"
    error_message="Failed to retrieve certificate information"
  else
    # Escape JSON special characters in cert_info more thoroughly
    cert_info=$(echo "$CERT_INFO" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/\r//g' | tr '\n' ' ' | sed 's/  */ /g; s/^ *//; s/ *$//')
  fi
  
  # Escape error_message for JSON
  error_message=$(echo "$error_message" | sed 's/\\/\\\\/g; s/"/\\"/g')
  
  # Create JSON object for this result using a more controlled approach
  {
    echo "{"
    echo "  \"url\": \"$target_url\","
    echo "  \"hostname\": \"$hostname\","
    echo "  \"port\": \"$port\","
    echo "  \"timestamp\": \"$timestamp\","
    echo "  \"status\": \"$status\","
    echo "  \"error_message\": \"$error_message\","
    echo "  \"cert_info\": \"$cert_info\""
    echo "}"
    echo ""  # Add blank line to separate JSON objects
  } >> "/tmp/ssl_results.tmp"
}

if [ -f "$SERVER_LIST_FILE" ]; then
  # Clear temp results file and ensure /tmp is writable
  rm -f "/tmp/ssl_results.tmp"
  
  # Create temp directory if it doesn't exist
  mkdir -p /tmp
  
  while IFS= read -r url_from_list || [[ -n "$url_from_list" ]]; do
    trimmed_url=$(echo "$url_from_list" | xargs)
    check_ssl_dates "$trimmed_url"
  done < "$SERVER_LIST_FILE"
  
  # Build final JSON array
  if [ -f "/tmp/ssl_results.tmp" ] && [ -s "/tmp/ssl_results.tmp" ]; then
    echo '{"results": [' > "$LOG_FILE"
    
    # Read JSON objects and add them to array (objects are separated by blank lines)
    first=true
    current_object=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [ -z "$line" ]; then
        # Empty line indicates end of JSON object
        if [ -n "$current_object" ]; then
          if [ "$first" = true ]; then
            first=false
          else
            echo "," >> "$LOG_FILE"
          fi
          echo "$current_object" >> "$LOG_FILE"
          current_object=""
        fi
      else
        # Add line to current object
        if [ -z "$current_object" ]; then
          current_object="$line"
        else
          current_object="$current_object"$'\n'"$line"
        fi
      fi
    done < "/tmp/ssl_results.tmp"
    
    # Handle the last object if there's no trailing empty line
    if [ -n "$current_object" ]; then
      if [ "$first" = true ]; then
        first=false
      else
        echo "," >> "$LOG_FILE"
      fi
      echo "$current_object" >> "$LOG_FILE"
    fi
    
    echo '], "timestamp": "'$(date -Iseconds)'"}' >> "$LOG_FILE"
    
    # Clean up temp file
    rm -f "/tmp/ssl_results.tmp"
  else
    # No results, just empty array
    echo '{"results": [], "timestamp": "'$(date -Iseconds)'"}' > "$LOG_FILE"
  fi
fi