# Quick Fix: GitHub Actions Failing

## Problem
The workflow is failing with: **"Error: Username and password required"**

## Root Cause
The GitHub secrets `DOCKER_USERNAME` and `DOCKER_PASSWORD` are not configured in your repository.

## Solution

### Step 1: Add Secrets to GitHub
Go to: https://github.com/yaseenahmed1407/oan-ai-api/settings/secrets/actions

### Step 2: Add DOCKER_USERNAME
- Click "New repository secret"
- Name: `DOCKER_USERNAME`
- Value: `yaseen1407`
- Click "Add secret"

### Step 3: Add DOCKER_PASSWORD
- Click "New repository secret"
- Name: `DOCKER_PASSWORD`
- Value: Your Docker Hub Personal Access Token
- Click "Add secret"

### Step 4: Get Docker Hub PAT (if you don't have one)
1. Go to: https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: `github-actions`
4. Permissions: Read, Write, Delete
5. Click "Generate"
6. **COPY THE TOKEN**

### Step 5: Re-run the Workflow
After adding secrets:
1. Go to: https://github.com/yaseenahmed1407/oan-ai-api/actions
2. Click on the failed workflow run
3. Click "Re-run all jobs" button (top right)

OR make a small change and push:
```bash
# Add a comment to README or any file
git add .
git commit -m "Trigger workflow after adding secrets"
git push origin main
```

## Verification
After re-running, the workflow should:
- ✅ Log in to Docker Hub successfully
- ✅ Build the Docker image
- ✅ Push to Docker Hub as `yaseen1407/oan-ai-api:latest`

Check the progress at: https://github.com/yaseenahmed1407/oan-ai-api/actions
