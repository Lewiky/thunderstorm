import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)

ecs = boto3.client('ecs')
sqs = boto3.resource('sqs')

def request_handler(event, context):
    cluster = os.environ.get('ECS_CLUSTER_NAME')
    out_queue_name = os.environ.get('SQS_OUTPUT_QUEUE')
    out_queue = sqs.get_queue_by_name(QueueName=out_queue_name)
    in_queue_name = os.environ.get('SQS_INPUT_QUEUE')
    in_queue = sqs.get_queue_by_name(QueueName=in_queue_name)
    tasks = ecs.list_tasks(
        cluster= cluster,
        family=os.environ.get('ECS_TASK_FAMILY_NAME')
    )['taskArns']
    for task in tasks:
        logging.info(f'Stopping task: {task}')
        ecs.stop_task(
            cluster= cluster,
            task= task
        )
    logging.info('Stopped all running tasks')
    out_queue.purge()
    in_queue.purge()
    logging.info('Purged Queues')
    return {
        'isBase64Encoded': False,
        'statusCode': '200',
        'body': json.dumps({'success': True}),
        'headers': {
            'Content-Type': 'application/json'
        } 
    }
