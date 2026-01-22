# Configure Azure Function App Environment Variables
# Run this after creating the Function App

$functionAppName = "oan-ai-function"
$resourceGroup = "OAN-Org"

Write-Host "Configuring environment variables for $functionAppName..." -ForegroundColor Green

# Set all required environment variables
az functionapp config appsettings set `
    --name $functionAppName `
    --resource-group $resourceGroup `
    --settings `
    "FUNCTIONS_WORKER_RUNTIME=python" `
    "AzureWebJobsFeatureFlags=EnableWorkerIndexing" `
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE=false" `
    "SCM_DO_BUILD_DURING_DEPLOYMENT=false" `
    "ENABLE_ORYX_BUILD=false" `
    "ENVIRONMENT=production" `
    "PYTHONUNBUFFERED=1" `
    "REDIS_HOST=localhost" `
    "REDIS_PORT=6379" `
    "REDIS_DB=0"

Write-Host "Basic settings configured!" -ForegroundColor Green
Write-Host ""
Write-Host "NOW ADD YOUR SECRETS:" -ForegroundColor Yellow
Write-Host "Go to Azure Portal -> Function App -> Configuration -> Application Settings" -ForegroundColor White
Write-Host ""
Write-Host "Add these (from your .env file):" -ForegroundColor Yellow
Write-Host "- OPENAI_API_KEY" -ForegroundColor Cyan
Write-Host "- AWS_ACCESS_KEY_ID" -ForegroundColor Cyan
Write-Host "- AWS_SECRET_ACCESS_KEY" -ForegroundColor Cyan
Write-Host "- AWS_REGION" -ForegroundColor Cyan
Write-Host "- AWS_BUCKET_NAME" -ForegroundColor Cyan
Write-Host "- REDIS_PASSWORD (if using Azure Redis)" -ForegroundColor Cyan
Write-Host "- MARQO_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then restart the app:" -ForegroundColor Yellow
Write-Host "az functionapp restart --name $functionAppName --resource-group $resourceGroup" -ForegroundColor White
