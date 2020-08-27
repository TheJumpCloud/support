import requests, datetime, json, boto3, os, gzip, csv

def jc_users(event, context):
    try:
        jcapikey =  os.environ['JCAPIKEY']
        incrementType = os.environ['incrementType']
        incrementAmount = int(os.environ['incrementAmount'])
        bucketName = os.environ['BucketName']
        UserFields = os.environ['UserFields']
    except KeyError as e:
        raise Exception(e)


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

    fileStartDate = datetime.datetime.strftime(start_dt, "%m-%d-%YT%H-%M-%SZ")
    # fileEndDate = datetime.datetime.strftime(now, "%m-%d-%YT%H-%M-%SZ")
    outfileName = "jcusers" + fileStartDate + ".json.gz"

    url = "https://console.jumpcloud.com/api/systemusers"

    payload = "startDate=" + start_date + "&endDate=" + end_date
    headers = {
        'x-api-key': jcapikey,
        'content-type': "application/json",
        'user-agent': "JumpCloud_AWSServerless.UserCSV/0.0.1"
        }
    skip = 0
    body = {
        'fields': ("email", "firstname", "lastname", "suspended"),
        'skip': skip
    }

    try:
        users = []
        response = requests.request("GET", url, headers=headers, params=body)
        response = json.loads(response.text)
        users = response['results']
        while len(response['results']) != 0:
            response = requests.request(
                "GET", url, headers=headers, params=body)
            response = json.loads(response.text)
            users += response['results']
            body['skip'] += 100
        header = users[0].keys()
        with open('data.csv', 'w') as f:
            writer = csv.writer(f, delimiter=',')
            writer.writerow(header)
            i = 0
            while i < len(users):
                user = users[i].values()
                writer.writerow(user)
                i += 1

    except (requests.exceptions.RequestException, requests.exceptions.HTTPError) as e:
        raise Exception(e)
        exit(1)

    if response is None:
        raise Exception("There have been no events in the last {0} {1}.".format(incrementAmount, incrementType))
        return

    # gzOutfile = gzip.GzipFile(filename="/tmp/" + outfileName, mode="w", compresslevel=9)
    # gzOutfile.write(json.dumps(response, indent=4).encode("UTF-8"))
    # gzOutfile.close()

    # s3 = boto3.client('s3')
    # s3.upload_file("/tmp/" + outfileName, bucketName, outfileName)


if __name__ == "__main__":
    jc_users("","")
