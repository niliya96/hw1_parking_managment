# 🚗 Parking Lot Management System

A serverless parking lot management system built with AWS Lambda, DynamoDB, and API Gateway. This system handles vehicle entry and exit operations with automatic fee calculation.

## 🏗️ Architecture

- **AWS Lambda**: Serverless compute for handling API requests
- **DynamoDB**: NoSQL database for storing parking records
- **API Gateway**: RESTful API endpoints
- **Serverless Framework**: Infrastructure as Code

## 📋 Features

- Vehicle entry tracking with license plate recognition
- Automatic ticket generation
- Fee calculation based on parking duration (15-minute increments)
- Secure and scalable serverless architecture
- Real-time processing with sub-second response times

## 🚀 Quick Start

### Prerequisites

1. **AWS Account**: [Sign up here](https://aws.amazon.com/free/)
2. **AWS CLI**: [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. **Node.js**: [Download here](https://nodejs.org/) (v14 or higher)
4. **Python**: v3.9 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd parking-lot-management
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, and preferred region.

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Deploy to AWS**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   Or deploy manually:
   ```bash
   serverless deploy
   ```

## 📡 API Endpoints

### Vehicle Entry
**POST** `/entry?plate={license-plate}&parkingLot={lot-id}`

**Example Request:**
```bash
curl -X POST "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/entry?plate=ABC-123&parkingLot=1"
```

**Example Response:**
```json
{
  "ticketId": "123e4567-e89b-12d3-a456-426614174000",
  "plate": "ABC-123",
  "parkingLot": "1",
  "entryTime": "2024-01-20T10:30:00.000Z"
}
```

### Vehicle Exit
**POST** `/exit?ticketId={ticket-id}`

**Example Request:**
```bash
curl -X POST "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/exit?ticketId=123e4567-e89b-12d3-a456-426614174000"
```

**Example Response:**
```json
{
  "ticketId": "123e4567-e89b-12d3-a456-426614174000",
  "plate": "ABC-123",
  "parkingLot": "1",
  "entryTime": "2024-01-20T10:30:00.000Z",
  "exitTime": "2024-01-20T12:45:00.000Z",
  "totalMinutes": 135,
  "totalHours": 2.25,
  "charge": 7.5
}
```

## 💰 Pricing Model

- **Rate**: $10 per hour
- **Billing**: 15-minute increments (rounded up)
- **Minimum charge**: $2.50 (first 15 minutes)

### Examples:
- 10 minutes = $2.50
- 30 minutes = $5.00
- 1 hour = $10.00
- 1 hour 45 minutes = $17.50

## 🔧 Configuration

### Environment Variables
- `PARKING_TABLE`: DynamoDB table name (automatically set)

### Deployment Stages
- **Development**: `serverless deploy --stage dev`
- **Production**: `serverless deploy --stage prod`

## 📊 Monitoring

### AWS Console Links
- **Lambda Functions**: [AWS Lambda Console](https://console.aws.amazon.com/lambda)
- **DynamoDB Tables**: [DynamoDB Console](https://console.aws.amazon.com/dynamodb)
- **API Gateway**: [API Gateway Console](https://console.aws.amazon.com/apigateway)


## 🛠️ Development

### Local Testing
```bash
# Install development dependencies
pip install -r requirements.txt

# Run tests (if you add them)
python -m pytest tests/
```


## 🔒 Security

- All API endpoints use HTTPS
- AWS IAM roles with least privilege
- DynamoDB encryption at rest
- No hardcoded credentials (use AWS IAM roles)





