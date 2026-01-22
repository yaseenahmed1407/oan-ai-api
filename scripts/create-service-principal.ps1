# Azure Service Principal Creation Script
# Run this in Azure Cloud Shell or local terminal with Azure CLI installed

# Variables
$SUBSCRIPTION_ID = "your-subscription-id"  # Replace with your Azure subscription ID
$RESOURCE_GROUP = "OAN-Org"
$APP_NAME = "oan-ai-function-sp"

# Login to Azure (if not already logged in)
# az login

# Get your subscription ID (if you don't know it)
# az account show --query id -o tsv

# Create a service principal with Contributor role scoped to the resource group
az ad sp create-for-rbac `
  --name $APP_NAME `
  --role Contributor `
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP `
  --sdk-auth

# The output will be a JSON object that you need to copy and paste as AZURE_CREDENTIALS secret in GitHub
# It will look like this:
# {
#   "clientId": "...",
#   "clientSecret": "...",
#   "subscriptionId": "...",
#   "tenantId": "...",
#   "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
#   "resourceManagerEndpointUrl": "https://management.azure.com/",
#   "activeDirectoryGraphResourceId": "https://graph.windows.net/",
#   "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
#   "galleryEndpointUrl": "https://gallery.azure.com/",
#   "managementEndpointUrl": "https://management.core.windows.net/"
# }
