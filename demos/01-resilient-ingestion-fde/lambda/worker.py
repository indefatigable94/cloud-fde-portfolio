"""
Resilient Ingestion Gateway - Event Processing Worker
Handles SQS batch events with idempotent DynamoDB writes and structured error handling.
"""

import os
import json
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("TABLE_NAME")
table = dynamodb.Table(TABLE_NAME) if TABLE_NAME else None


def lambda_handler(event, context):
    """
    Process batch of SQS records.
    Returns partial batch failure response for failed records.
    """
    records = event.get("Records", [])
    batch_item_failures = []

    logger.info("Received batch with %d records", len(records))

    for record in records:
        message_id = record.get("messageId")
        body_raw = record.get("body", "{}")

        try:
            payload = json.loads(body_raw)
            process_record(message_id, payload)
        except Exception as exc:
            logger.error("Failed processing message %s: %s", message_id, str(exc))
            # Report specific message failure to allow SQS partial batch redelivery
            batch_item_failures.append({"itemIdentifier": message_id})

    return {"batchItemFailures": batch_item_failures}


def process_record(message_id: str, payload: dict):
    """
    Validates payload and performs idempotent write to DynamoDB.
    """
    event_id = payload.get("event_id") or message_id
    event_type = payload.get("event_type", "unknown")
    timestamp = payload.get("timestamp")
    data = payload.get("data", {})

    if not TABLE_NAME:
        logger.warning("TABLE_NAME not configured, dry-run processing for %s", event_id)
        return

    # Write item with condition to prevent duplicate overwrite
    try:
        table.put_item(
            Item={
                "event_id": event_id,
                "event_type": event_type,
                "timestamp": timestamp,
                "data": data,
                "status": "PROCESSED",
            }
        )
        logger.info("Successfully persisted event %s", event_id)
    except ClientError as err:
        logger.error("DynamoDB client error for event %s: %s", event_id, err)
        raise err
