# SSL Certificate Checker (Alpine Docker)

## Overview
This project is a web-based SSL certificate checker built using Alpine Linux, Nginx, Bash, and OpenSSL. It allows users to submit a list of domain names and view SSL certificate details and expiration warnings directly in the browser. The system is containerized using Docker for easy deployment.

## Features
- **Single-page web interface**: Enter multiple domains, check certificates, and view results instantly.
- **Expiration highlighting**: Results are color-coded based on how soon certificates expire (green, yellow, red, pulsing red for urgent/expired).
- **No results.html needed**: Results are displayed directly below the "Check Certificates" button.
- **Auto-scroll to results**: After checking, the page scrolls to the results section.
- **Robust error handling**: Invalid or missing certificates are clearly marked.
- **FastCGI Bash backend**: Uses fcgiwrap to run Bash scripts from Nginx.
- **Alpine-based Docker image**: Lightweight and fast.

## How It Works
1. **Frontend**: `index.html` provides a form for users to enter domains. When submitted, it sends the list to `/check` via POST.
2. **Nginx**: Configured to pass `/check` requests to the Bash script using FastCGI (`fcgiwrap`).
3. **Backend Bash Scripts**:
   - `submit_urls.sh`: Receives the POST data, saves it to a temp file, runs `ssl_checker.sh`, and returns results as JSON.
   - `ssl_checker.sh`: Reads the domain list, checks each SSL certificate using OpenSSL, and writes results to a JSON file.
4. **Frontend JS**: Fetches the JSON results and displays them inline, parsing expiration dates and applying color-coded warnings.

## File Structure
- `Dockerfile`: Builds the Alpine-based container, installs dependencies, copies scripts and config, sets permissions.
- `index.html`: Main web interface and client-side logic.
- `nginx.conf`: Nginx configuration for serving the app and handling FastCGI requests.
- `ssl_checker.sh`: Bash script to check SSL certificates and output results as JSON.
- `submit_urls.sh`: Bash script to handle POST requests and return JSON results.
- `start.sh`: Entrypoint script to start fcgiwrap and Nginx.
- `.dockerignore`: (optional) Files to ignore in Docker builds.

## Usage
### Build and Run with Docker
```bash
docker build -t ssl-checker .
docker run -p 8080:80 ssl-checker
```
Then open [http://localhost:8080](http://localhost:8080) in your browser.

### How to Use
1. Enter one or more domain names (one per line) in the textarea.
2. Click "Check Certificates".
3. View certificate details and expiration warnings below the button.

### Expiration Highlighting
- **Green**: 90+ days left
- **Yellow**: 60-90 days left
- **Red**: 8-30 days left
- **Pulsing Red/Bold**: 7 days or less, or expired

## Customization
- You can modify the Bash scripts to change how certificates are checked or how results are formatted.
- Update `nginx.conf` for custom server settings.

## Troubleshooting
- If you see errors about permissions, make sure `/tmp` and `/var/www/html` are writable in the container.
- If you see "NaN days" or "Invalid Date", make sure the certificate date parsing logic in `index.html` is up to date.
- For push/pull issues with GitHub, make sure your local repo is synced with the remote before pushing.

## License
MIT License

## Author
Brian Davisson
