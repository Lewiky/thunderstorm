#! /usr/bin/python3.7
import requests
import signal
import time
import argparse
import sys

endpoint = 'https://6df9f9687c.execute-api.us-east-1.amazonaws.com/main'

parser = argparse.ArgumentParser()
parser.add_argument('--difficulty', type=int)
parser.add_argument('--time', type=int)
parser.add_argument('--confidence', type=float)
parser.add_argument('--block', type=str)
parser.add_argument('--workers', type=int, default=None)
args = parser.parse_args()

def print_dict(dict):
    for key in dict.keys():
        print(f'{key}: {dict[key]}')

def sig_handler(sig, frame):
    print('Shutting Down....')
    r = requests.delete(endpoint+'/kill')
    print_dict(r.json())
    sys.exit(0)

signal.signal(signal.SIGINT, sig_handler)

start = time.time()
params = {'difficulty': args.difficulty, 'time': args.time, 'block': args.block, 'confidence': args.confidence}
if args.workers:
    params['workers'] = args.workers
r = requests.post(endpoint + '/start',params=params)
print_dict(r.json())

messages = []
while len(messages) == 0:
    r = requests.get(endpoint + '/output')
    if(r.status_code != 200):
        print(f'Get Failed: {r.text}')
        sig_handler(None, None)
    j = r.json()
    if 'messages' in j:
        messages = j['messages']
    if(time.time() - start > args.time):
        print("Out of time...")
        sig_handler(None, None)
for message in messages:
    print(message)
    r = requests.delete(endpoint+'/kill')
    print(r.text)
print(f'Finished in {(time.time() - start):.2f}s')
