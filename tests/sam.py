import logging
from subprocess import Popen

import boto3
import botocore

from tests import wait_for_port


class LocalApi:

    def __init__(self,
                 host: str = '127.0.0.1',
                 port: int = 3000,
                 template_path: str = None,
                 parameter_overrides: dict = None,
                 ):
        self.host = host
        self.port = port
        command = ['sam', 'local', 'start-api', '--host', self.host, '--port', str(self.port)]
        if template_path:
            command += ['--template', template_path]
        if parameter_overrides:
            command += ['--parameter-overrides', create_parameter_overrides(parameter_overrides)]
        self.process = Popen(command)

    def kill(self):
        self.process.kill()
        return_code = self.process.wait()
        logging.info('Killed server with code %s', return_code)

    def wait(self, interval: int = 10, retries: int = 6):
        wait_for_port(self.port, self.host, interval=interval, retries=retries)

    def get_uri(self) -> str:
        return 'http://{}:{}'.format(self.host, self.port)


def start_local_api(host: str = '127.0.0.1',
                    port: int = 3000,
                    template_path: str = None,
                    parameter_overrides: dict = None) -> LocalApi:
    server = LocalApi(host=host,
                      port=port,
                      template_path=template_path,
                      parameter_overrides=parameter_overrides)
    server.wait()
    return server


def create_parameter_overrides(parameter_overrides):
    return "'" + ' '.join(['ParameterKey={},ParameterValue={}'.format(key, value) for key, value in
                           parameter_overrides.items()]) + "'"


class LocalLambdaServer:

    def __init__(self,
                 host: str = '127.0.0.1',
                 port: int = 3001,
                 template_path: str = None,
                 parameter_overrides: dict = None,
                 ):
        self.host = host
        self.port = port
        command = ['sam', 'local', 'start-lambda', '--host', self.host, '--port', str(self.port)]
        if template_path:
            command += ['--template', template_path]
        if parameter_overrides:
            command += ['--parameter-overrides', create_parameter_overrides(parameter_overrides)]
        self.process = Popen(command)

    def get_client(self):
        config = botocore.client.Config(signature_version=botocore.UNSIGNED,
                                        read_timeout=900,
                                        retries={'max_attempts': 0},
                                        )
        return boto3.client('lambda',
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


def start_local_lambda(host: str = '127.0.0.1',
                       port: int = 3001,
                       template_path: str = None,
                       parameter_overrides: dict = None) -> LocalLambdaServer:
    server = LocalLambdaServer(host=host,
                               port=port,
                               template_path=template_path,
                               parameter_overrides=parameter_overrides)
    server.wait()
    return server
