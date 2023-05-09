#!/bin/bash

rm -rf python
mkdir python

# Install the dependencies into the python folder
python3.10 -m pip install -r requirements.txt --target python

# Copy the Lambda function code to the package folder
cp lambda_chat.py python/

# Zip the contents of the python folder
cd python
zip -r ../lambda_chat.zip .
cd ..