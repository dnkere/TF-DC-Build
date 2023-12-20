import logging
import os
from urllib.parse import parse_qs
import azure.functions as func

SLACK_TOKEN = os.getenv("slack_verification_token")

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    payload = req.get_body().decode('utf8').replace("'", '"')
    payload_json = parse_qs(payload)
    if 'token' in payload_json:
        token = payload_json['token'][0].rstrip()
    else:
        return func.HttpResponse("Bad Request.", status_code=400)
    if SLACK_TOKEN != token:
        return func.HttpResponse("Slack tokens do not match.", status_code=403)
    
    if 'text' in payload_json:
        slash_argument = payload_json['text'][0].rstrip()
        return func.HttpResponse(f"{slash_argument}", status_code=200)
    else:
        return func.HttpResponse("", status_code=200)
