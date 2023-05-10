import json
import openai
import boto3
from botocore.exceptions import ClientError
import urllib.parse


def get_secret():
    """Get secret from AWS Secrets Manager"""
    print("invoking get_secret")

    secret_name = "chatGPT_key"
    region_name = "eu-central-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)
    print("client created")
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        print(
            e
        )  # will this have any effect in the lambda function? yes, it will. check your logs! ;-)
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response["SecretString"]
    # Parse the JSON string into a dictionary and extract the API key
    secret_dict = json.loads(secret)
    api_key = secret_dict["chatGPT_key"]

    print("API key received. Returning API key")
    return api_key


def message_chatgpt(message, conversation_history):
    """Send message to chatGPT and return response"""
    print("conversation history: ", conversation_history)
    openai.api_key = get_secret()
    conversation = conversation_history + [{"role": "user", "content": message}]
    print("conversation: ", conversation)
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo", messages=conversation, temperature=0.7
    )
    print("response received: ", response)
    print("response content: ", response.choices[0].message.content.strip())
    return response.choices[0].message.content.strip()


def read_conversation_from_s3(bucket, key):
    """Read conversation from S3"""
    s3 = boto3.client("s3")
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        conversation_history = response["Body"].read().decode("utf-8")
        return json.loads(conversation_history)
    except Exception as e:
        print(f"Error reading conversation from S3: {e}")
        return []


def write_conversation_to_s3(bucket, key, conversation_history):
    """Write conversation to S3"""
    s3 = boto3.client("s3")
    try:
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(conversation_history).encode("utf-8"),
        )
    except Exception as e:
        print(f"Error writing conversation to S3: {e}")


def lambda_handler(event, context):
    """Lambda function handler"""
    print("incoming event: ", event)
    print("incoming context: ", context)
    print("incoming event body: ", event["body"])

    # Parse the event body
    body = urllib.parse.parse_qs(event["body"])
    uuid = body["uuid"][0]
    message_text = body["message"][0]

    # Read conversation history from S3
    bucket = "chat-daniel-wrede.de"
    key = f"conversations/{uuid}.json"
    conversation_history = read_conversation_from_s3(bucket, key)

    # Process message and update conversation history
    response = message_chatgpt(message_text, conversation_history)
    print("response: ", response)

    # Write conversation history to S3
    conversation_history.append({"role": "bot", "content": response.strip()})
    write_conversation_to_s3(bucket, key, conversation_history)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": response}),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        },
    }
