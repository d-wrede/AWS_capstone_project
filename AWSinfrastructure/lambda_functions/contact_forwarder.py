import os
import boto3
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
#from urllib.parse import unquote
from urllib.parse import parse_qs


def create_message(name, email, message_text):
    """Create email message to be sent"""
    
    sender = os.environ["MailSender"]
    recipient = os.environ["MailRecipient"]

    subject = "Contact Form: Message from {} ({})".format(name, email)

    body_text = "Name: {}\nEmail: {}\n\nMessage:\n{}".format(name, email, message_text)

    msg = MIMEMultipart()
    text_part = MIMEText(body_text, _subtype="plain")
    msg.attach(text_part)

    msg["Subject"] = subject
    msg["From"] = sender
    msg["To"] = recipient

    message = {"Source": sender, "Destinations": recipient, "Data": msg.as_string()}
    return message


def send_email(message):
    """Send email using Amazon SES"""

    aws_region = os.environ["Region"]

    # Create a new SES client.
    client_ses = boto3.client("ses", aws_region)
    # use email.eu-central-1.amazonaws.com

    # Send the email.
    try:
        # Provide the contents of the email.
        response = client_ses.send_raw_email(
            Source=message["Source"],
            Destinations=[message["Destinations"]],
            RawMessage={"Data": message["Data"]},
        )

    # Display an error if something goes wrong.
    except ClientError as e:
        output = e.response["Error"]["Message"]
    else:
        output = "Email sent! Message ID: " + response["MessageId"]

    return output


def lambda_handler(event, context):
    """Handle an incoming HTTP request from a contact form and forward as
    email."""

    body = parse_qs(event["body"])

    name = body["name"][0]
    email = body["email"][0]
    message_text = body["message"][0]

    # name = unquote(event["queryStringParameters"]["name"])
    # email = unquote(event["queryStringParameters"]["email"])
    # message_text = unquote(event["queryStringParameters"]["message"])

    message = create_message(name, email, message_text)
    result = send_email(message)
    print(result)

    return {"statusCode": 200, "body": result}
