import base64
import json
import re
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
        self.assertEqual(2, result)

    def test_lowercase_extension(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("LowerCaseExtensionFunction"),
                                        Payload=json.dumps({'x': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(2, result)

    def test_multiple_arguments(self):
        lambda_client = self.get_client()
        payload = {'x': 'bar', 'y': 1}
        response = lambda_client.invoke(FunctionName=get_function_name("MultipleArgumentsFunction"),
                                        Payload=json.dumps(payload),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertDictEqual(payload, result)

    @unittest.skipIf(is_local(), 'Lambda local does not support log retrieval')
    def test_debug_logging(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("LoggingFunction"),
                                        LogType='Tail',
                                        Payload=json.dumps({'x': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(1, result)
        log = base64.b64decode(response['LogResult']).decode('utf-8')
        self.assertIn("runtime:Sourcing 'script.R'", log)
        self.assertIn("runtime:Invoking function 'handler_with_debug_logging' with parameters:\n$x\n[1] 1", log)
        self.assertIn("runtime:Function returned:\n[1] 1", log)
        self.assertIn("runtime:Posted result:\n", log)

    @unittest.skipIf(is_local(), 'Lambda local does not support log retrieval')
    def test_no_debug_logging(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"),
                                        LogType='Tail',
                                        Payload=json.dumps({'x': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(2, result)
        log = base64.b64decode(response['LogResult']).decode('utf-8')
        self.assertNotIn("Sourcing ", log)
        self.assertNotIn("Invoking function ", log)
        self.assertNotIn("Function returned:", log)
        self.assertNotIn("Posted result:", log)

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_source_file(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingSourceFileFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('Source file does not exist: missing.[R|r]', json_payload['errorMessage'])
        self.assertEqual('simpleError', json_payload['errorType'])

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_function(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingFunctionFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('Function "handler_missing" does not exist', json_payload['errorMessage'])
        self.assertEqual('simpleError', json_payload['errorType'])

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_function_as_variable(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("HandlerAsVariableFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('Function "handler_as_variable" does not exist', json_payload['errorMessage'])
        self.assertEqual('simpleError', json_payload['errorType'])

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"))
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('argument "x" is missing, with no default', json_payload['errorMessage'])
        self.assertEqual('simpleError', json_payload['errorType'])

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_unused_argument(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("ExampleFunction"),
                                        Payload=json.dumps({'x': 1, 'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('unused argument (y = 1)', json_payload['errorMessage'])
        self.assertEqual('simpleError', json_payload['errorType'])

#    @unittest.skipIf(is_local(), 'Fails locally with "argument list too long"')
    @unittest.skip('Fails with timeout')
    def test_long_argument(self):
        lambda_client = self.get_client()
        payload = {x: x for x in range(0, 100000)}
        response = lambda_client.invoke(FunctionName=get_function_name("VariableArgumentsFunction"),
                                        Payload=json.dumps(payload),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(1, result)

    @unittest.skipIf(is_local(), 'Lambda local does not pass errors properly')
    def test_missing_library(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("MissingLibraryFunction"),
                                        Payload=json.dumps({'y': 1}),
                                        )
        raw_payload = response['Payload'].read().decode('utf-8')
        json_payload = json.loads(raw_payload)
        self.assertEqual('Unhandled', response['FunctionError'])
        self.assertIn('there is no package called ‘Matrix’', json_payload['errorMessage'])
        error_type = 'packageNotFoundError' if get_version() == '3_6_0' else 'simpleError'
        self.assertEqual(error_type, json_payload['errorType'])

    @classmethod
    def tearDownClass(cls):
        if is_local():
            cls.lambda_server.kill()
