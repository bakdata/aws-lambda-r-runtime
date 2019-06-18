import os


def is_pull_request() -> bool:
    return os.getenv('TRAVIS_PULL_REQUEST') == 'true'
