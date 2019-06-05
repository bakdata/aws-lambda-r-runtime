import logging
from subprocess import Popen

import boto3
import botocore

from tests import wait_for_port


class LocalApi:

    def __init__(self, host: str = '127.0.0.1', port: int = 3000):
        self.host = host
        self.port = port
        self.process = Popen(['sam', 'local', 'start-api', '--host', self.host, '--port', str(self.port)])

    def kill(self):
        self.process.kill()
        return_code = self.process.wait()
        logging.info('Killed server with code %s', return_code)

    def wait(self, interval: int = 10, retries: int = 6):
        wait_for_port(self.port, self.host, interval=interval, retries=retries)

    def get_uri(self) -> str:
        return 'http://{}:{}'.format(self.host, self.port)


def start_local_api() -> LocalApi:
    server = LocalApi()
    server.wait()
    return server


class LocalLambdaServer:

    def __init__(self, host: str = '127.0.0.1', port: int = 3001):
        self.host = host
        self.port = port
        self.process = Popen(['sam', 'local', 'start-lambda', '--host', self.host, '--port', str(self.port)])

    def get_client(self):
        config = botocore.client.Config(signature_version=botocore.UNSIGNED,
                                        read_timeout=300,
                                        retries={'max_attempts': 0},
                                        )
        return boto3.client('lambda',
                            region_name="eu-central-1",
                            endpoint_url="http://{}:{}".format(self.host, self.port),
                            use_ssl=False,
                            verify=False,
                            config=config,
                            )

    def kill(self):
        self.process.kill()
        return_code = self.process.wait()
        logging.info('Killed server with code %s', return_code)

    def wait(self, interval: int = 10, retries: int = 6):
        wait_for_port(self.port, self.host, interval=interval, retries=retries)


def start_local_lambda() -> LocalLambdaServer:
    server = LocalLambdaServer()
    server.wait()
    return server
