#!/bin/bash

# Simple test script to debug JSON generation
echo "Testing SSL checker JSON generation..."

# Create local directories for testing
mkdir -p ./test_var/www/html
mkdir -p ./test_tmp

# Modify ssl_checker.sh temporarily for local testing
cp ssl_checker.sh ssl_checker_test.sh
sed -i 's|/var/www/html/results.json|./test_var/www/html/results.json|g' ssl_checker_test.sh
sed -i 's|/tmp/|./test_tmp/|g' ssl_checker_test.sh

# Create a test input file
echo "google.com" > ./test_tmp/ssl_server_list.txt
echo "invalid-domain-that-should-fail.com" >> ./test_tmp/ssl_server_list.txt

# Run the SSL checker
bash ssl_checker_test.sh

# Show the results
echo "Generated JSON:"
cat ./test_var/www/html/results.json

echo ""
echo "Cleaning up test files..."
rm -rf ./test_var ./test_tmp ssl_checker_test.sh
