import os


def is_pull_request() -> bool:
    return os.getenv('TRAVIS_PULL_REQUEST') == 'true' \
           and os.getenv('TRAVIS_PULL_REQUEST_SLUG') != os.getenv('TRAVIS_REPO_SLUG')
