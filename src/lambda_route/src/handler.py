import os
import simplejson as json
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext


def get_cors_headers(headers: dict = None) -> dict:
    if headers is None:
        origin = "*"
    else:
        origin = headers.get('Origin', '*')

    return {
        "Access-Control-Allow-Origin": origin,
        "Access-Control-Allow-Methods": "*",
        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Credentials": "true",
    }


def api_response(code: int, body=None, headers: dict = None, json_encode_body: bool = True,
                 is_base_64_encoded: bool = False) -> dict:
    if headers is None:
        headers = get_cors_headers()
    else:
        h = get_cors_headers(headers)
        h.update(headers)
        headers = h

    if body is None:
        body = ""
    else:
        if json_encode_body:
            body = json.dumps(body)

    return {
        "statusCode": code,
        "headers": headers,
        "body": body,
        "isBase64Encoded": is_base_64_encoded
    }


logger = Logger()

region = os.environ.get("AWS_REGION", "eu-west-1")

RETURN_CODE = int(os.environ.get("RETURN_CODE", '200'))
MESSAGE = os.environ.get("MESSAGE", 'route')


@logger.inject_lambda_context(log_event=True)
def lambda_handler(event: dict, context: LambdaContext):
    return api_response(
        RETURN_CODE,
        {
            "message": MESSAGE
        }
    )
