import json
import unittest

import boto3

from tests.sam import LocalLambdaServer, start_local_lambda


class TestRuntimeLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def isLocal(cls) -> bool:
        return True

    @classmethod
    def setUpClass(cls):
        if cls.isLocal():
            cls.lambda_server = start_local_lambda()

    def test_script(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="ExampleFunction", Payload=json.dumps({'x': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(result, 2)

    def get_client(self):
        return self.lambda_server.get_client() if self.isLocal() else boto3.client('lambda')

    def test_lowercase_extension(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="LowerCaseExtensionFunction", Payload=json.dumps({'x': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(result, 2)

    def test_multiple_arguments(self):
        lambda_client = self.get_client()
        payload = {'x': 'bar', 'y': 1}
        response = lambda_client.invoke(FunctionName="MultipleArgumentsFunction", Payload=json.dumps(payload))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertDictEqual(result, payload)

    @unittest.skip('Lambda local does not pass errors properly')
    def test_missing_source_file(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="MissingSourceFileFunction", Payload=json.dumps({'y': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Source file does not exist: missing.[R|r]', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_missing_function(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="MissingFunctionFunction", Payload=json.dumps({'y': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Function "handler_missing" does not exist', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_function_as_variable(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="HandlerAsVariableFunction", Payload=json.dumps({'y': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Function "handler_as_variable" does not exist', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_missing_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="ExampleFunction")
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('argument "x" is missing, with no default', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_unused_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="ExampleFunction", Payload=json.dumps({'x': 1, 'y': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('unused argument (y = 1)', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_long_argument(self):
        lambda_client = self.get_client()
        payload = {x: x for x in range(0, 100000)}
        response = lambda_client.invoke(FunctionName="VariableArgumentsFunction", Payload=json.dumps(payload))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual(json_payload['errorType'], 'Runtime.ExitError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_missing_library(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName="MissingLibraryFunction", Payload=json.dumps({'y': 1}))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('there is no package called ‘Matrix’', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @classmethod
    def tearDownClass(cls):
        if cls.isLocal():
            cls.lambda_server.kill()
