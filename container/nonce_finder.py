from hashlib import sha256
import random
import logging
import boto3
import os
import json

logging.basicConfig(level=logging.INFO)


def b_str(x: int) -> bytes:
    '''
    Convert an integer to it's hex bytes representation
    '''
    return x.to_bytes(4, byteorder='big')


def is_golden(hsh: str, difficulty: int = 32) -> bool:
    '''
    Given a hash, check if it meets difficulty requirements
    '''
    b = bin(int(hsh, 16))[2:].zfill(len(hsh)*4)
    zeros = 0
    for char in b:
        if char != '0':
            break
        zeros += 1
    return zeros >= difficulty


def apply_sha(nonce: bytes, block: bytes, difficulty: int = 32) -> bool:
    '''
    Apply the SHA256 twice to the block and determine if it's a golden result
    '''
    block_hash = block + nonce
    hsh = sha256(block_hash).digest()
    sqr_hsh = sha256(hsh).hexdigest()
    return is_golden(sqr_hsh, difficulty)


def find(rang=(0, 2**32), difficulty=9, block="COMSM0010cloud") -> int:
    '''
    Search the given input range for a golden nonce, return -1 if it doesn't exist in the range
    '''
    logging.info(f'Starting search in range {rang}')
    r = 0
    iterator = range(rang[0], rang[1])
    block = block.encode('utf-8')
    while not apply_sha(b_str(iterator[r]), block, difficulty=difficulty):
        logging.debug(f'Trying: {iterator[r]}')
        r += 1
        if r > rang[1]:
            logging.info('No Found Nonce')
            return -1 
    logging.info(f'found Nonce: {iterator[r]}')
    return iterator[r]


def verify_params(params: dict):
    logging.info(params)
    if 'high' in params and 'low' in params and 'difficulty' and 'block' in params:
        return params
    logging.error(f'Invalid params {params}')
    return None


def pull_queue(sqs) -> dict:
    '''
    Pull a message from the queue and valdidate it
    '''
    queue_name: str = os.environ.get('SQS_INPUT_QUEUE_NAME')
    queue = sqs.get_queue_by_name(QueueName=queue_name)
    for message in queue.receive_messages():
        try:
            params = json.loads(message.body)
            v_params = verify_params(params)
            if v_params is not None:
                message.delete()
                return v_params
        except NameError:
            logging.error(f'Malformed input message: {message}')
            continue


def push_queue(sqs, nonce):
    '''
    Push the result back to the output queue once found
    '''
    logging.info(f'Pushing nonce: {nonce} to queue')
    queue_name: str = os.environ.get('SQS_OUTPUT_QUEUE_NAME')
    queue = sqs.get_queue_by_name(QueueName=queue_name)
    response = queue.send_message(MessageBody=json.dumps({'nonce': nonce}))
    if not response.get('MessageId'):
        logging.error('Could not push result to queue')


if __name__ == '__main__':
    sqs = boto3.resource('sqs')
    params = pull_queue(sqs)
    nonce = find((int(params['low']), int(
        params['high'])), params['difficulty'], params['block'])
    push_queue(sqs, nonce)
