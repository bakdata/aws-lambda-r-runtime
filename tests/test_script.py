import json
import unittest
import boto3
import botocore


class TestLambdaR(unittest.TestCase):

    def test(self):
        lambda_client = boto3.client('lambda',
                                     region_name="eu-central-1",
                                     endpoint_url="http://127.0.0.1:3001",
                                     use_ssl=False,
                                     verify=False,
                                     config=botocore.client.Config(
                                         signature_version=botocore.UNSIGNED,
                                         read_timeout=60,
                                         retries={'max_attempts': 0},
                                     )
                                     )
        response = lambda_client.invoke(FunctionName="ExampleFunction",
                                        Payload=json.dumps({'x': 1}))
        payload = response['Payload'].read().decode('utf-8')
        result = json.loads(payload)['result']
        self.assertEqual(result, 2)
