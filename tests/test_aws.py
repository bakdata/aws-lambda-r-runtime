import json
import unittest

from tests.aws_lambda import LocalLambdaServer, start_local_lambda


class TestAWSLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        cls.lambda_server = start_local_lambda()

    def test_s3_get_object(self):
        lambda_client = self.lambda_server.get_client()
        response = lambda_client.invoke(FunctionName="MatrixFunction", Payload=json.dumps({'x': 1}))
        payload = response['Payload'].read().decode('utf-8')
        result = json.loads(payload)['result']
        self.assertEqual(len(result), 2)
        self.assertIn(3, result)
        self.assertIn(7, result)

    @classmethod
    def tearDownClass(cls):
        cls.lambda_server.kill()
