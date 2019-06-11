import unittest

import requests

from tests import get_version
from tests.sam import LocalApi, start_local_api


class TestApi(unittest.TestCase):
    api: LocalApi = None

    @classmethod
    def setUpClass(cls):
        cls.api = start_local_api(template_path="test-template.yaml",
                                  parameter_overrides={'Version': get_version()},
                                  )

    def test_matrix(self):
        response = requests.get('%s/hello' % self.api.get_uri(), params={'who': 'World'})
        result = response.json()
        self.assertDictEqual({'hello': 'World'}, result)

    @classmethod
    def tearDownClass(cls):
        cls.api.kill()
