import json
import unittest

from tests.aws_lambda import LocalLambdaServer, start_local_lambda


class TestRuntimeLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        cls.lambda_server = start_local_lambda()

    def test_script(self):
        lambda_client = self.lambda_server.get_client()
        response = lambda_client.invoke(FunctionName="ExampleFunction", Payload=json.dumps({'x': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        result = json_payload['result']
        self.assertEqual(result, 2)

    @classmethod
    def tearDownClass(cls):
        cls.lambda_server.kill()
