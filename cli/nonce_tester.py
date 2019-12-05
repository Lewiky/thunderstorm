#! /usr/bin/python3.7
import requests
import boto3
import signal
import time
import argparse
import sys
import json
import csv
import random

#base url for the API gateway output - printed from terraform script
endpoint = 'https://6df9f9687c.execute-api.us-east-1.amazonaws.com/main'

#Setup the queue
sqs = boto3.resource('sqs')
queue_name = 'cloud_nonce-output-queue'
queue = sqs.get_queue_by_name(QueueName=queue_name)

def sig_handler(sig, frame):
    '''
    Gracefully shutdown system on SIGTERM
    '''
    requests.delete(endpoint+'/kill')
    sys.exit(0)

signal.signal(signal.SIGINT, sig_handler)

def test(difficulty, workers):
    '''
    Run a single test and write results to file
    '''
    print(f'Running {difficulty}: {workers} workers')
    start = time.time()
    requests.post(endpoint + '/start',params={'difficulty': difficulty, 'workers': workers, 'block': 'COMSM0010cloud'})

    result = None
    messages = []
    while len(messages) == 0:
        messages = queue.receive_messages(WaitTimeSeconds=20)
    for message in messages:
        result = json.loads(message.body)['nonce']
        message.delete()
        r = requests.delete(endpoint+'/kill')
    length = time.time() - start
    with open('results.csv', 'a') as f:
        writer = csv.writer(f)
        writer.writerow([difficulty, workers, result, length])
    print('Done')
    time.sleep(60) # Sleep 60 seconds to prevent SQS queue purge cooldowns

if __name__ == '__main__':
    with open('results.csv', 'w+') as f:
        f.write('difficulty, workers, result, time\n')
    for i in range(1000):
        test(random.randint(1, 30), random.randint(1, 20))
