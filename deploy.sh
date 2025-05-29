#!/bin/bash

# Parking Lot Management System - Deployment Script
# Exercise 1 - Cloud Computing Course
# Serverless deployment to AWS Lambda

echo "Deploying Parking Lot Management System..."
echo "========================================="

# Install Serverless Framework if not installed
if ! command -v serverless &> /dev/null; then
    echo "Installing Serverless Framework..."
    npm install -g serverless
fi

# Install project dependencies
echo "Installing dependencies..."
npm install

# Deploy to AWS
echo "Deploying to AWS Lambda..."
serverless deploy

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "📋 API Endpoints:"
    echo "POST /entry?plate={plate}&parkingLot={lotId}"
    echo "POST /exit?ticketId={ticketId}"
    echo ""
    echo "🔗 Get your API URL:"
    echo "serverless info"
    echo ""
else
    echo "❌ Deployment failed!"
    exit 1
fi
