import json
import os
import unittest

from tests import get_function_name, get_version
from tests.sam import LocalLambdaServer, start_local_lambda


class TestAWSLayer(unittest.TestCase):
    lambda_server: LocalLambdaServer = None

    @classmethod
    def isLocal(cls) -> bool:
        return os.getenv('INTEGRATION_TEST') != 'True'

    @classmethod
    def setUpClass(cls):
        if cls.isLocal():
            cls.lambda_server = start_local_lambda(template_path="test-template.yaml",
                                                   parameter_overrides={'Version': get_version()},
                                                   )

    def test_s3_get_object(self):
        lambda_client = self.lambda_server.get_client()
        response = lambda_client.invoke(FunctionName=get_function_name("AWSFunction", self.isLocal()))
        raw_payload = response['Payload'].read().decode('utf-8')
        result = json.loads(raw_payload)
        self.assertEqual(len(result), 1)
        self.assertDictEqual(result[0], {
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
        })

    @classmethod
    def tearDownClass(cls):
        if cls.isLocal():
            cls.lambda_server.kill()
