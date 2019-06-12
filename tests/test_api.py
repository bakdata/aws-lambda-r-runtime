import unittest

import requests

from tests import get_version, is_local
from tests.sam import LocalApi, start_local_api


class TestApi(unittest.TestCase):
    api: LocalApi = None

    @classmethod
    def setUpClass(cls):
        if is_local():
            cls.api = start_local_api(template_path="test-template.yaml",
                                      parameter_overrides={'Version': get_version()},
                                      )

    @unittest.skipUnless(is_local(), 'Only works locally')
    def test_api(self):
        response = requests.get('%s/hello' % self.api.get_uri(), params={'who': 'World'})
        result = response.json()
        self.assertDictEqual({'hello': 'World'}, result)

    @classmethod
    def tearDownClass(cls):
        if is_local():
            cls.api.kill()
