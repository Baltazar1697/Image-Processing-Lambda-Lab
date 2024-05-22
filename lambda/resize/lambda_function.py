# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
import json
import urllib.parse
import boto3
import os, sys, Image
from io import BytesIO
from PIL import Image
print('Loading function')

s3 = boto3.client('s3')

def get_object_s3(bucket,key):
    file_byte_string = s3.get_object(Bucket=bucket, Key=key)['Body'].read()
    return Image.open(BytesIO(file_byte_string))

def upload_to_s3(bucket,key,image):
    buffer = BytesIO()
    image.save(buffer, self.__get_safe_ext(key))
    buffer.seek(0)
    sent_data = self.s3.put_object(Bucket=bucket, Key="output/resized_"+key, Body=buffer)
    if sent_data['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise S3ImagesUploadFailed('Failed to upload image {} to bucket {}'.format(key, bucket))

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    bucket = s3.bucket
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        
        image = get_object_s3(bucket,key)
        
        newsize = (300, 300)
        resized = image.resize(newsize)
        
        upload_to_s3(bucket,key,resized)

    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
    return 0