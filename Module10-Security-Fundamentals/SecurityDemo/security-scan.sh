#!/bin/bash

# OWASP ZAP Automated Security Scan Script
set -e

echo "🔍 Starting OWASP ZAP Security Scan..."

# Configuration
TARGET_URL="http://localhost:5000"
ZAP_PORT="8080"
REPORT_DIR="security-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create reports directory
mkdir -p "$REPORT_DIR"

# Check if ZAP is available
if ! command -v zap.sh &> /dev/null; then
    echo "❌ OWASP ZAP is not installed or not in PATH"
    echo "Please install OWASP ZAP from: https://www.zaproxy.org/download/"
    exit 1
fi

# Start ZAP in daemon mode
echo "🚀 Starting ZAP daemon..."
zap.sh -daemon -port $ZAP_PORT -config api.disablekey=true &
ZAP_PID=$!

# Wait for ZAP to start
echo "⏳ Waiting for ZAP to initialize..."
sleep 30

# Spider the target
echo "🕷️  Spidering target: $TARGET_URL"
curl -s "http://localhost:$ZAP_PORT/JSON/spider/action/scan/?url=$TARGET_URL" > /dev/null

# Wait for spider to complete
echo "⏳ Waiting for spider to complete..."
while [ $(curl -s "http://localhost:$ZAP_PORT/JSON/spider/view/status/" | jq -r .status) != "100" ]; do
    sleep 5
done

# Active scan
echo "🔍 Starting active security scan..."
curl -s "http://localhost:$ZAP_PORT/JSON/ascan/action/scan/?url=$TARGET_URL" > /dev/null

# Wait for active scan to complete
echo "⏳ Waiting for active scan to complete..."
while [ $(curl -s "http://localhost:$ZAP_PORT/JSON/ascan/view/status/" | jq -r .status) != "100" ]; do
    sleep 10
done

# Generate reports
echo "📊 Generating security reports..."

# HTML Report
curl -s "http://localhost:$ZAP_PORT/OTHER/core/other/htmlreport/" > "$REPORT_DIR/security_report_$TIMESTAMP.html"

# JSON Report
curl -s "http://localhost:$ZAP_PORT/JSON/core/view/alerts/" > "$REPORT_DIR/security_report_$TIMESTAMP.json"

# XML Report
curl -s "http://localhost:$ZAP_PORT/OTHER/core/other/xmlreport/" > "$REPORT_DIR/security_report_$TIMESTAMP.xml"

# Stop ZAP
echo "🛑 Stopping ZAP daemon..."
kill $ZAP_PID

echo "✅ Security scan completed!"
echo "📁 Reports saved in: $REPORT_DIR/"
echo "📊 HTML Report: $REPORT_DIR/security_report_$TIMESTAMP.html"

