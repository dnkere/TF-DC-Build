import json
import logging
import os

from urllib.parse import parse_qs
from base64 import b64decode


CONFIGURED_TOKEN = os.environ['slack_verification_token']

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def respond(err, res=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(res),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def lambda_handler(event, context):
    params = parse_qs(event['body'])

    token = params['token'][0]
    if token != CONFIGURED_TOKEN:
        logging.debug(f'''Given slack token: {token}''')
        logging.debug(f'''Expected slack token: {CONFIGURED_TOKEN}''')
        logger.error(f'''Request token {token} does not match expected.''')
        return respond(Exception('Invalid request token'))

    if 'text' in params:
        command_text = params['text'][0]
    else:
        command_text = ''

    return respond(None, f'''{command_text} {command_text}''')
