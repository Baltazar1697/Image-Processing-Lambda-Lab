# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
import json
import urllib.parse
import boto3
import os
from io import BytesIO
from PIL import Image
print('Loading function')

s3 = boto3.client('s3')

def get_object_s3(bucket, key):
    file_byte_string = s3.get_object(Bucket=bucket, Key=key)['Body'].read()
    return Image.open(BytesIO(file_byte_string))

def upload_to_s3(bucket, key, image):
    buffer = BytesIO()
    image.save(buffer, get_safe_ext(key))
    buffer.seek(0)
    sent_data = s3.put_object(Bucket=bucket, Key=f"output/cropped_{key}", Body=buffer.getvalue())
    if sent_data['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise Exception(f'Failed to upload image {key} to bucket {bucket}')

def get_safe_ext(key):
    ext = os.path.splitext(key)[1]
    if ext.lower() in ['.jpg', '.jpeg']:
        return 'JPEG'
    elif ext.lower() == '.png':
        return 'PNG'
    else:
        raise ValueError(f'Unsupported file extension: {ext}')

def lambda_handler(event, context):
    print("Event message: ", event)
    sns_message = event['Records'][0]['Sns']['Message']
    print("SNS message: ", sns_message)
    
    # Parse the JSON string in the SNS message
    message = json.loads(sns_message)
    
    print("Parsed message: ", message)
    bucket_name = message['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(message['Records'][0]['s3']['object']['key'], encoding='utf-8')

    try:
        image = get_object_s3(bucket_name,key)

        # Define the cropping coordinates
        left = 100
        top = 100
        right = 300
        bottom = 300

        # Crop the image
        cropped_image = image.crop((left, top, right, bottom))

        upload_to_s3(bucket_name,key,cropped_image)

    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket_name))
        raise e
    return 0
