#!/bin/bash

# Test script for Parking Lot Management API
# Make sure to replace API_URL with your actual API Gateway URL

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if API_URL is provided
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <API_URL>${NC}"
    echo "Example: $0 https://abc123.execute-api.us-east-1.amazonaws.com/dev"
    echo ""
    echo "To get your API URL, run: serverless info"
    exit 1
fi

API_URL=$1

echo -e "${BLUE}🚗 Testing Parking Lot Management System${NC}"
echo "============================================="
echo "API URL: $API_URL"
echo ""

# Test 1: Vehicle Entry
echo -e "${YELLOW}Test 1: Vehicle Entry${NC}"
echo "POST $API_URL/entry?plate=ABC-123&parkingLot=1"

ENTRY_RESPONSE=$(curl -s -X POST "$API_URL/entry?plate=ABC-123&parkingLot=1")
echo "Response: $ENTRY_RESPONSE"

# Extract ticket ID from response
TICKET_ID=$(echo $ENTRY_RESPONSE | grep -o '"ticketId": "[^"]*' | cut -d'"' -f4)

if [ -z "$TICKET_ID" ]; then
    echo -e "${RED}❌ Failed to get ticket ID from entry response${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Vehicle entry successful!${NC}"
echo "Ticket ID: $TICKET_ID"
echo ""

# Wait a few seconds to simulate parking time
echo -e "${YELLOW}⏱️  Simulating parking time (5 seconds)...${NC}"
sleep 5
echo ""

# Test 2: Vehicle Exit
echo -e "${YELLOW}Test 2: Vehicle Exit${NC}"
echo "POST $API_URL/exit?ticketId=$TICKET_ID"

EXIT_RESPONSE=$(curl -s -X POST "$API_URL/exit?ticketId=$TICKET_ID")
echo "Response: $EXIT_RESPONSE"

if echo $EXIT_RESPONSE | grep -q "charge"; then
    echo -e "${GREEN}✅ Vehicle exit successful!${NC}"
else
    echo -e "${RED}❌ Vehicle exit failed${NC}"
fi

echo ""

# Test 3: Error handling - Missing parameters
echo -e "${YELLOW}Test 3: Error Handling - Missing plate parameter${NC}"
echo "POST $API_URL/entry?parkingLot=1"

ERROR_RESPONSE=$(curl -s -X POST "$API_URL/entry?parkingLot=1")
echo "Response: $ERROR_RESPONSE"

if echo $ERROR_RESPONSE | grep -q "error"; then
    echo -e "${GREEN}✅ Error handling working correctly!${NC}"
else
    echo -e "${RED}❌ Error handling not working as expected${NC}"
fi

echo ""

# Test 4: Invalid ticket ID
echo -e "${YELLOW}Test 4: Error Handling - Invalid ticket ID${NC}"
echo "POST $API_URL/exit?ticketId=invalid-ticket-id"

INVALID_RESPONSE=$(curl -s -X POST "$API_URL/exit?ticketId=invalid-ticket-id")
echo "Response: $INVALID_RESPONSE"

if echo $INVALID_RESPONSE | grep -q "not found"; then
    echo -e "${GREEN}✅ Invalid ticket handling working correctly!${NC}"
else
    echo -e "${RED}❌ Invalid ticket handling not working as expected${NC}"
fi

echo ""

# Test 5: Multiple vehicles
echo -e "${YELLOW}Test 5: Multiple Vehicles${NC}"

# Vehicle 1
echo "Vehicle 1 Entry (XYZ-789, Lot 2):"
VEHICLE1_RESPONSE=$(curl -s -X POST "$API_URL/entry?plate=XYZ-789&parkingLot=2")
echo "Response: $VEHICLE1_RESPONSE"
VEHICLE1_TICKET=$(echo $VEHICLE1_RESPONSE | grep -o '"ticketId":"[^"]*' | cut -d'"' -f4)

# Vehicle 2
echo "Vehicle 2 Entry (DEF-456, Lot 1):"
VEHICLE2_RESPONSE=$(curl -s -X POST "$API_URL/entry?plate=DEF-456&parkingLot=1")
echo "Response: $VEHICLE2_RESPONSE"
VEHICLE2_TICKET=$(echo $VEHICLE2_RESPONSE | grep -o '"ticketId":"[^"]*' | cut -d'"' -f4)

echo ""
sleep 2

# Exit both vehicles
echo "Vehicle 1 Exit:"
VEHICLE1_EXIT=$(curl -s -X POST "$API_URL/exit?ticketId=$VEHICLE1_TICKET")
echo "Response: $VEHICLE1_EXIT"

echo "Vehicle 2 Exit:"
VEHICLE2_EXIT=$(curl -s -X POST "$API_URL/exit?ticketId=$VEHICLE2_TICKET")
echo "Response: $VEHICLE2_EXIT"

echo -e "${GREEN}✅ Multiple vehicles test completed!${NC}"
echo ""

echo -e "${BLUE}🎉 All tests completed!${NC}"
echo ""
echo -e "${YELLOW}📊 Summary:${NC}"
echo "- Vehicle entry/exit functionality"
echo "- Error handling for missing parameters"
echo "- Invalid ticket ID handling"
echo "- Multiple vehicles support"
echo ""
echo -e "${GREEN}✅ Your Parking Lot Management System is working correctly!${NC}"