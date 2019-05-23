import json
import unittest

from tests.aws_lambda import LocalLambdaServer, start_local_lambda


class TestRecommendedLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        cls.lambda_server = start_local_lambda()

    def test_matrix(self):
        lambda_client = self.lambda_server.get_client()
        response = lambda_client.invoke(FunctionName="MatrixFunction")
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        result = json_payload['result']
        self.assertEqual(len(result), 3)
        self.assertIn(4, result)
        self.assertIn(5, result)
        self.assertIn(6, result)

    @classmethod
    def tearDownClass(cls):
        cls.lambda_server.kill()
