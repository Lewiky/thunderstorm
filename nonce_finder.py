from hashlib import sha256
import random
import logging

logging.basicConfig(level=logging.INFO)

def b_str(x: int) -> bytes:
    return x.to_bytes(4, byteorder='big')

def is_golden(hsh: str, difficulty: int = 32) -> bool:
    b = bin(int(hsh, 16))[2:].zfill(len(hsh)*4)
    zeros = 0
    for char in b:
        if char != '0':
            break
        zeros += 1
    return zeros >= difficulty

def apply_sha(nonce: bytes, block: bytes, difficulty: int = 32) -> bool:
    block_hash = block + nonce
    hsh = sha256(block_hash).digest()
    sqr_hsh = sha256(hsh).hexdigest()
    return is_golden(sqr_hsh, difficulty)

def find(rang = (0, 2**32), difficulty=9) -> int:
    r = 0
    iterator = range(rang[0], rang[1])
    block = "COMSM0010cloud".encode('utf-8')
    while not apply_sha(b_str(iterator[r]), block, difficulty=difficulty):
        logging.debug(f'Trying: {iterator[r]}')
        r += 1
    logging.info(f'found Nonce: {iterator[r]}')
    return iterator[r]

if __name__ == '__main__':
    nonce = find()
