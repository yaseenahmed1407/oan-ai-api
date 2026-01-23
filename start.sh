#!/bin/bash
# OAN AI API - Minimal Startup Script

set -e

echo "Starting OAN AI API..."
echo "Port: ${PORT:-80}"

# Ensure we are in the right directory
cd /app

# Run uvicorn directly for better log capture in Azure
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-80} --log-level info --workers 1
