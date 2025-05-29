import json
import uuid
import boto3
from datetime import datetime, timezone
from decimal import Decimal
import os

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['PARKING_TABLE'])


def lambda_handler(event, context):
    """
    Main Lambda handler for parking lot management system
    Handles both entry and exit operations
    """
    try:
        # Extract HTTP method and path
        http_method = event['httpMethod']
        path = event['path']
        query_params = event.get('queryStringParameters', {}) or {}

        # Route based on path
        if path == '/entry' and http_method == 'POST':
            return handle_entry(query_params)
        elif path == '/exit' and http_method == 'POST':
            return handle_exit(query_params)
        else:
            return create_response(404, {'error': 'Endpoint not found'})

    except Exception as e:
        print(f"Error: {str(e)}")
        return create_response(500, {'error': 'Internal server error'})


def handle_entry(query_params):
    """
    Handle vehicle entry to parking lot
    Expected params: plate, parkingLot
    Returns: ticketId
    """
    # Validate required parameters
    plate = query_params.get('plate')
    parking_lot = query_params.get('parkingLot')

    if not plate or not parking_lot:
        return create_response(400, {
            'error': 'Missing required parameters: plate and parkingLot'
        })

    # Generate unique ticket ID
    ticket_id = str(uuid.uuid4())
    entry_time = datetime.now(timezone.utc).isoformat()

    # Store entry record in DynamoDB
    try:
        table.put_item(
            Item={
                'ticketId': ticket_id,
                'plate': plate,
                'parkingLot': parking_lot,
                'entryTime': entry_time,
                'status': 'ACTIVE'
            }
        )

        return create_response(200, {
            'ticketId': ticket_id,
            'plate': plate,
            'parkingLot': parking_lot,
            'entryTime': entry_time
        })

    except Exception as e:
        print(f"DynamoDB error: {str(e)}")
        return create_response(500, {'error': 'Failed to store entry record'})


def handle_exit(query_params):
    """
    Handle vehicle exit from parking lot
    Expected params: ticketId
    Returns: plate, totalTime, parkingLot, charge
    """
    ticket_id = query_params.get('ticketId')

    if not ticket_id:
        return create_response(400, {
            'error': 'Missing required parameter: ticketId'
        })

    # Retrieve entry record from DynamoDB
    try:
        response = table.get_item(Key={'ticketId': ticket_id})

        if 'Item' not in response:
            return create_response(404, {'error': 'Ticket not found'})

        entry_record = response['Item']

        # Check if already processed
        if entry_record.get('status') != 'ACTIVE':
            return create_response(400, {'error': 'Ticket already processed'})

        # Calculate parking duration and fee
        entry_time = datetime.fromisoformat(entry_record['entryTime'])
        exit_time = datetime.now(timezone.utc)

        parking_duration = exit_time - entry_time
        total_minutes = int(parking_duration.total_seconds() / 60)

        # Calculate charge in 15-minute increments at $10/hour
        charge = calculate_parking_fee(total_minutes)

        # Update record status
        table.update_item(
            Key={'ticketId': ticket_id},
            UpdateExpression='SET #status = :status, exitTime = :exit_time, charge = :charge',
            ExpressionAttributeNames={'#status': 'status'},
            ExpressionAttributeValues={
                ':status': 'COMPLETED',
                ':exit_time': exit_time.isoformat(),
                ':charge': charge
            }
        )

        return create_response(200, {
            'ticketId': ticket_id,
            'plate': entry_record['plate'],
            'parkingLot': entry_record['parkingLot'],
            'entryTime': entry_record['entryTime'],
            'exitTime': exit_time.isoformat(),
            'totalMinutes': total_minutes,
            'totalHours': round(total_minutes / 60, 2),
            'charge': float(charge)
        })

    except Exception as e:
        print(f"DynamoDB error: {str(e)}")
        return create_response(500, {'error': 'Failed to process exit'})


def calculate_parking_fee(total_minutes):
    """
    Calculate parking fee based on 15-minute increments
    Rate: $10 per hour (prorated)
    """
    # Convert to 15-minute increments (round up)
    increments = (total_minutes + 14) // 15  # Round up to next 15-minute increment

    # Calculate fee: $10/hour = $2.50 per 15-minute increment
    fee = Decimal(str(increments * 2.5))

    return fee


def create_response(status_code, body):
    """
    Create standardized HTTP response
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps(body, default=str)
    }