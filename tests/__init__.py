import logging
import os
import socket
import time

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)


def wait_for_port(port: int, host: str = 'localhost', interval: int = 10, retries: int = 6) -> bool:
    for i in range(1, retries + 1):
        try:
            logging.info("Try %s/%s: Connecting to %s:%s", i, retries, host, port)
            s = socket.create_connection((host, port))
            s.close()
            logging.info("Try %s/%s: Connection succeeded", i, retries)
            return True
        except ConnectionRefusedError as e:
            logging.info("Try %s/%s: Connection to %s:%s not possible: %s. Waiting %ss",
                         i, retries, host, port, e, interval)
            time.sleep(interval)
    return False


def get_function_name(name: str) -> str:
    return name if is_local() else '{0}-{1}'.format(name, get_version())


def get_version() -> str:
    return os.getenv('VERSION', '3_6_0')


def is_local() -> bool:
    return os.getenv('INTEGRATION_TEST') != 'True'
