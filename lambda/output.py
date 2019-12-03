import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)

sqs = boto3.resource('sqs')

def request_handler(event, context):
    out_queue_name = os.environ.get('SQS_OUTPUT_QUEUE')
    out_queue = sqs.get_queue_by_name(QueueName=out_queue_name)
    messages = out_queue.receive_messages(WaitTimeSeconds=20)
    results = {'success': True}
    if len(messages) != 0:
        results['messages'] = [message.body for message in messages]
        for message in messages:
            message.delete()
    return {
        'isBase64Encoded': False,
        'statusCode': '200',
        'body': json.dumps(results),
        'headers': {
            'Content-Type': 'application/json'
        } 
    }
