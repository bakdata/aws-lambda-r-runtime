import json
import unittest

import boto3

from tests import get_version, get_function_name, is_local
from tests.sam import LocalLambdaServer, start_local_lambda


class TestRecommendedLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        if is_local():
            cls.lambda_server = start_local_lambda(template_path="test-template.yaml",
                                                   parameter_overrides={'Version': get_version()},
                                                   )

    def get_client(self):
        return self.lambda_server.get_client() if is_local() else boto3.client('lambda')

    def test_matrix(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MatrixFunction"))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(3, len(result))
        self.assertIn(4, result)
        self.assertIn(5, result)
        self.assertIn(6, result)

    @classmethod
    def tearDownClass(cls):
        if is_local():
            cls.lambda_server.kill()
