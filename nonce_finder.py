from hashlib import sha256
import random
import logging

logging.basicConfig(level=logging.INFO)

def b_str(x: int) -> str:
    return x.to_bytes(4, byteorder='big')

def is_golden(hsh: str, difficulty: int = 32) -> bool:
    b = bin(int(hsh, 16))[2:].zfill(len(hsh)*4)
    logging.debug(f'hsh: {hsh}')
    logging.debug(f'b:   {b}')
    zeros = 0
    for char in b:
        if char != '0':
            break
        zeros += 1
    return zeros >= difficulty

def apply_rsa(nonce: bytes, block: bytes, difficulty: int = 32) -> bool:
    logging.debug(f'nonce: {nonce}({type(nonce)}, block: {block}({type(block)}))')
    block_hash = block + nonce
    logging.debug(f'block_hash: {block_hash}({type(block_hash)})')
    hsh = sha256(block_hash).digest()
    sqr_hsh = sha256(hsh).hexdigest()
    logging.debug(f'sqr_hash: {sqr_hsh}({type(sqr_hsh)})')
    return is_golden(sqr_hsh, difficulty)

def find(rang = (0, 2**32), difficulty=9) -> int:
    r = 0
    iterator = range(rang[0], rang[1])
    block = "COMSM0010cloud".encode('utf-8')
    while not apply_rsa(b_str(iterator[r]), block, difficulty=difficulty):
        logging.debug(f'Trying: {iterator[r]}')
        r += 1
    logging.info(f'found Nonce: {iterator[r]}')
    return iterator[r]

if __name__ == '__main__':
    nonce = find()
