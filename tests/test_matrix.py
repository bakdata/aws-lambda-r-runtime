import json
import os
import unittest

from tests import get_version, get_function_name
from tests.sam import LocalLambdaServer, start_local_lambda


class TestRecommendedLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def isLocal(cls) -> bool:
        return os.getenv('INTEGRATION_TEST') == 'True'

    @classmethod
    def setUpClass(cls):
        if cls.isLocal():
            cls.lambda_server = start_local_lambda(template_path="test-template.yaml",
                                                   parameter_overrides={'Version': get_version()},
                                                   )

    def test_matrix(self):
        lambda_client = self.lambda_server.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MatrixFunction", self.isLocal()))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(len(result), 3)
        self.assertIn(4, result)
        self.assertIn(5, result)
        self.assertIn(6, result)

    @classmethod
    def tearDownClass(cls):
        if cls.isLocal():
            cls.lambda_server.kill()
