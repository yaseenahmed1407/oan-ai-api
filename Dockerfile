# Use Python 3.10 slim image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port 80 for Azure Functions
EXPOSE 80

# Run the application with Azure Functions optimized settings
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80", "--timeout-keep-alive", "75", "--log-level", "info"]