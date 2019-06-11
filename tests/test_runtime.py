import json
import os
import unittest

import boto3

from tests import get_version, get_function_name, is_local
from tests.sam import LocalLambdaServer, start_local_lambda


class TestRuntimeLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        if is_local():
            cls.lambda_server = start_local_lambda(template_path="test-template.yaml",
                                                   parameter_overrides={'Version': get_version()},
                                                   )

    def get_client(self):
        return self.lambda_server.get_client() if is_local() else boto3.client('lambda')

    def test_script(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"),
                                        Payload=json.dumps({'x': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(result, 2)

    def test_lowercase_extension(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("LowerCaseExtensionFunction"),
                                        Payload=json.dumps({'x': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(result, 2)

    def test_multiple_arguments(self):
        lambda_client = self.get_client()
        payload = {'x': 'bar', 'y': 1}
        response = lambda_client.invoke(FunctionName=get_function_name("MultipleArgumentsFunction"),
                                        Payload=json.dumps(payload),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertDictEqual(result, payload)

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_source_file(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingSourceFileFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Source file does not exist: missing.[R|r]', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_function(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingFunctionFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Function "handler_missing" does not exist', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_function_as_variable(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("HandlerAsVariableFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('Function "handler_as_variable" does not exist', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('argument "x" is missing, with no default', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_unused_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"),
                                        Payload=json.dumps({'x': 1, 'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('unused argument (y = 1)', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @unittest.skip('Lambda local does not pass errors properly')
    def test_long_argument(self):
        lambda_client = self.get_client()
        payload = {x: x for x in range(0, 100000)}
        response = lambda_client.invoke(FunctionName=get_function_name("VariableArgumentsFunction"),
                                        Payload=json.dumps(payload),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual(json_payload['errorType'], 'Runtime.ExitError')

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_library(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingLibraryFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertIn('there is no package called ‘Matrix’', json_payload['errorMessage'])
        self.assertEqual(json_payload['errorType'], 'simpleError')

    @classmethod
    def tearDownClass(cls):
        if is_local():
            cls.lambda_server.kill()
