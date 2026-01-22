# Use Azure Functions Python 3.10 image
FROM mcr.microsoft.com/azure-functions/python:4-python3.10

# Set environment variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME=python \
    PYTHONUNBUFFERED=1 \
    ASPNETCORE_URLS=http://+:80

# Set working directory
WORKDIR /home/site/wwwroot

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all application files
COPY . .

# Create a startup script
RUN echo '#!/bin/bash\necho "Starting Azure Functions..."\nexec /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost' > /home/site/wwwroot/startup.sh && \
    chmod +x /home/site/wwwroot/startup.sh

# Expose port 80
EXPOSE 80
