import requests, datetime, json, boto3, os, gzip, csv
from botocore.exceptions import ClientError

def get_secret(secret_name):
    client = boto3.client(service_name='secretsmanager')
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise Exception(e)
        
    secret = get_secret_value_response['SecretString']
    return secret

def get_jcusers(event, context):
    try:
        jcapikeyarn = os.environ['JcApiKeyArn']
        incrementType = os.environ['incrementType']
        incrementAmount = int(os.environ['incrementAmount'])
        bucketName = os.environ['BucketName']
        orgId = os.environ['OrgId']
        userFields = os.environ['UserFields']
    except KeyError as e:
        raise Exception(e)

    jcapikey = get_secret(jcapikeyarn)
    now = datetime.datetime.utcnow()

    if incrementType == "minutes" or incrementType == "minute":
        start_dt = now - datetime.timedelta(minutes=incrementAmount)
    elif incrementType == "hours" or incrementType == "hour":
        start_dt = now - datetime.timedelta(hours=incrementAmount)
    elif incrementType == "days" or incrementType == "day":
        start_dt = now - datetime.timedelta(days=incrementAmount)
    else:
        raise Exception("Unknown increment value.")

    start_date = start_dt.isoformat("T") + "Z"
    end_date = now.isoformat("T") + "Z"

    outfileName = "jc_users_" + start_date + "_" + end_date + ".csv"

    url = "https://console.jumpcloud.com/api/systemusers"

    userFields = [x.strip() for x in userFields.split(';')]
    skip = 0
    limit = 100

    body = {
        'fields': userFields,
        'skip': skip,
        'limit': limit
    }
    headers = {
        'x-api-key': jcapikey,
        'content-type': "application/json",
        'user-agent': "JumpCloud_AWSServerless.UserCSV/0.0.1"
    }

    if orgId != '':
        headers['x-org-id'] = orgId

    response = requests.get(url, json=body, headers=headers)
    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        raise Exception(e)
    responseBody = json.loads(response.text)

    data = responseBody['results']

    while responseBody['totalCount'] == 100:
        body["skip"] += 100
        response = requests.get(url, json=body, headers=headers)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            raise Exception(e)
        responseBody = json.loads(response.text)
        data = data + responseBody['results']
    try:    
        header = data[0].keys()
        with open("/tmp/" + outfileName, 'w') as f:
            writer = csv.writer(f, delimiter=',')
            writer.writerow(header)
            i = 0
            while i < len(data):
                user = data[i].values()
                writer.writerow(user)
                i += 1
    except Exception as e:
        raise Exception(e)

    try:
        s3 = boto3.client('s3')
        s3.upload_file("/tmp/" + outfileName, bucketName, outfileName)
    except ClientError as e:
        raise Exception(e)