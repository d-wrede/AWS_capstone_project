import json
import openai
import boto3
from botocore.exceptions import ClientError


def get_secret():
    """Get secret from AWS Secrets Manager"""
    print("invoking get_secret")

    secret_name = "chatGPT_key"
    region_name = "eu-central-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    print("client created")
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        print(e) # will this have any effect in the lambda function? yes, it will. check your logs! ;-)
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']
    print("secret received. returning secret")
    return secret


def message_chatgpt(message):
    """Send message to chatGPT and return response"""
    print("invoking message_chatgpt")
    openai.api_key = get_secret()
    print("secret received")
    print("sending message: ", message)    
    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=message,
        temperature=0.7,
        max_tokens=256,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
        )
    print("response received: ", response)
    print("response.choices[0].text: ", response.choices[0].text")
    return response.choices[0].text.strip()


def lambda_handler(event, context):
    """Lambda function handler"""
    print("incoming event: ", event)
    print("incoming context: ", context")
    print("incoming event body: ", event['body'])
    message_text = event['body']
    response = message_chatgpt(message_text)
    print("response: ", response)

    # response = {
    #     "statusCode": 200,
    #     "body": json.dumps({"message": "Hello from Lambda!"}),
    #     "headers": {
    #         "Content-Type": "application/json",
    #         "Access-Control-Allow-Origin": "*",
    #     },
    # }
    return response
