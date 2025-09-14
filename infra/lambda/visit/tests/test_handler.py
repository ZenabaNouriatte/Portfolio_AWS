import os, sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))  # ajoute infra/lambda/visit au PYTHONPATH

import json
import os
import boto3
from moto import mock_aws
import handler
import os
os.environ["AWS_DEFAULT_REGION"] = "eu-west-3"

@mock_aws
def test_lambda_increments_counter():
    # Arrange: variables d'env attendues par ta Lambda
    os.environ["TABLE_NAME"] = "portfolio-dev-visit-counter"
    os.environ["PARTITION"] = "site"

    # Crée une table DynamoDB “fake” avec moto
    ddb = boto3.resource("dynamodb", region_name="eu-west-3")
    table = ddb.create_table(
        TableName=os.environ["TABLE_NAME"],
        KeySchema=[{"AttributeName":"site_id","KeyType":"HASH"}],
        AttributeDefinitions=[{"AttributeName":"site_id","AttributeType":"S"}],
        BillingMode="PAY_PER_REQUEST",
    )
    table.wait_until_exists()

    # Act: exécute ta Lambda 2 fois
    resp1 = handler.lambda_handler({}, {})
    resp2 = handler.lambda_handler({}, {})

    # Assert: le compteur a bien incrémenté
    assert resp1["statusCode"] == 200
    assert resp2["statusCode"] == 200

    body2 = json.loads(resp2["body"])
    assert "count" in body2
    assert body2["count"] == 2
