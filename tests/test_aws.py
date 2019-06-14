import json
import unittest

import boto3

from tests import get_function_name, get_version, is_local
from tests.sam import LocalLambdaServer, start_local_lambda


class TestAWSLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def setUpClass(cls):
        if is_local():
            cls.lambda_server = start_local_lambda(template_path="test-template.yaml",
                                                   parameter_overrides={'Version': get_version()},
                                                   )

    def get_client(self):
        return self.lambda_server.get_client() if is_local() else boto3.client('lambda')

    @unittest.skipUnless(is_local(), "Credentials missing for remote Lambda")
    def test_s3_get_object(self):
        lambda_client = self.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("AWSFunction"))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(1, len(result))
        self.assertDictEqual({
            "DRG.Definition": "039 - EXTRACRANIAL PROCEDURES W/O CC/MCC",
            "Provider.Id": "10001",
            "Provider.Name": "SOUTHEAST ALABAMA MEDICAL CENTER",
            "Provider.Street.Address": "1108 ROSS CLARK CIRCLE",
            "Provider.City": "DOTHAN",
            "Provider.State": "AL",
            "Provider.Zip.Code": 36301,
            "Hospital.Referral.Region.Description": "AL - Dothan",
            "Total.Discharges": 91,
            "Average.Covered.Charges": "$32963.07",
            "Average.Total.Payments": "$5777.24",
            "Average.Medicare.Payments": "$4763.73"
        }, result[0])

    @classmethod
    def tearDownClass(cls):
        if is_local():
            cls.lambda_server.kill()
