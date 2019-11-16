import json
import boto3
import json
import os
import logging

logging.basicConfig(level=logging.INFO)

ecs = boto3.client('ecs')
sqs = boto3.resource('sqs')

MAX_SEARCH = 2**32

def send_message(low, high, difficulty):
    message = json.dumps({'low': low, 'high': high, 'difficulty': difficulty})
    queue_name = os.environ.get('SQS_INPUT_QUEUE_NAME')
    queue = sqs.get_queue_by_name(QueueName=queue_name)
    response = queue.send_message(MessageBody=message)
    if not response.get('MessageId'):
        logging.error('Could not push input to queue')

def start_task():
    try:
        response = ecs.run_task(
            cluster=os.environ.get('ECS_CLUSTER_NAME'),
            launchType='FARGATE',
            taskDefinition=os.environ.get('NONCE_TASK_DEFINITION'),
            count = 1,
            platformVersion = 'LATEST',
            networkConfiguration = {
                'awsvpcConfiguration': {
                        'subnets': [
                            'subnet-a1a6d0ae',
                            'subnet-9e813dc2'
                        ],
                        'assignPublicIp': 'ENABLED'
                    }
            }
        )
        logging.info(f'Started Task: {response}')
        return True
    except Exception as e:
        logging.error(f'Error starting task: {e}')
        return False

def validate_params(params):
    logging.info(f'Validating input{params}')
    if not params['difficulty'] or not params['workers']:
        return False
    return True

def respond(body, status=200):
    return {
        'isBase64Encoded': False,
        'statusCode': str(status),
        'body':json.dumps(body),
        'headers': {
            'Content-Type': 'application/json'
        } 
    }

def request_handler(event, context):
    params = event['queryStringParameters']
    if not validate_params(params):
        return respond({'error': 'Invalid Params', 'params': params, 'success': False}, 400)
    num_workers = int(params['workers'])
    for i in range(num_workers):
        start_task()
        send_message(i*(MAX_SEARCH//num_workers),
            (i+1)*(MAX_SEARCH//num_workers),
            int(params['difficulty'])
        )

    logging.info('Finished Starting')
    return respond({'success': True})
    