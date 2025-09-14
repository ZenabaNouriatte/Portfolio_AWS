# handler.py
import os
import json
import boto3
from botocore.exceptions import ClientError

REGION = os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION") or "eu-west-3"
dynamodb = boto3.resource("dynamodb", region_name=REGION)
table = dynamodb.Table(os.environ.get("TABLE_NAME", "portfolio-dev-visit-counter"))

def lambda_handler(event, context):
    try:
        resp = table.update_item(
            Key={"site_id": os.environ.get("PARTITION", "site")},
            UpdateExpression="SET #c = if_not_exists(#c, :start) + :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1, ":start": 0},
            ReturnValues="UPDATED_NEW",
        )
        new_count = int(resp["Attributes"]["count"])
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
            },
            "body": json.dumps({"count": new_count}),
        }
    except ClientError as e:
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
            },
            "body": json.dumps({"error": str(e)}),
        }
