from email.parser import BytesParser
from email.policy import default












def get_message_from_s3(object_key):
    object_s3 = client_s3.get_object(Bucket=incoming_email_bucket, Key=object_key)
    original_message = object_s3["Body"].read()

    # Parse the original email message
    message = BytesParser(policy=default).parsebytes(original_message)

    # Extract the plain text content of the email
    plain_text_content = None
    if message.is_multipart():
        for part in message.walk():
            if part.get_content_type() == "text/plain":
                plain_text_content = part.get_payload(decode=True)
                break
    else:
        if message.get_content_type() == "text/plain":
            plain_text_content = message.get_payload(decode=True)

    return plain_text_content


def create_email_object(to_email, from_email, message_text):
    email_object = {
        "Source": from_email,
        "Destinations": [to_email],
        "RawMessage": {"Data": message_text},
    }
    return email_object
