import requests, datetime, json, boto3, os, gzip

def jc_events(event, context):
    jcapikey = os.environ['JCAPIKEY']
    incrementType = os.environ['incrementType']
    incrementAmount = int(os.environ['incrementAmount'])
    bucketName = os.environ['BucketName']

    now = datetime.datetime.utcnow()

    if incrementType == "minutes":
        start_dt = now - datetime.timedelta(minutes=incrementAmount)
    elif incrementType == "minute":
        start_dt = now - datetime.timedelta(minutes=incrementAmount)
    elif incrementType == "hours":
        start_dt = now - datetime.timedelta(hours=incrementAmount)
    elif incrementType == "hour":
        start_dt = now - datetime.timedelta(minutes=incrementAmount)
    elif incrementType == "days":
        start_dt = now - datetime.timedelta(days=incrementAmount)
    elif incrementType == "day":
        start_dt = now - datetime.timedelta(days=incrementAmount)
    else:
        print("Unknown increment value.")

    start_date = start_dt.isoformat("T") + "Z"
    end_date = now.isoformat("T") + "Z"

    fileStartDate = datetime.datetime.strftime(start_dt, "%m-%d-%YT%H-%M-%SZ")
    fileEndDate = datetime.datetime.strftime(now, "%m-%d-%YT%H-%M-%SZ")
    outfileName = "jcevents" + fileEndDate + "_" + fileStartDate + ".json.gz"

    url = "https://events.jumpcloud.com/events"

    payload = "startDate=" + start_date + "&endDate=" + end_date
    headers = {
        'x-api-key': jcapikey,
        'content-type': "application/json",
        }

    try:
        response = requests.request("GET", url, params=payload, headers=headers)
        response = json.loads(response.text)
    except (requests.exceptions.RequestException, requests.exceptions.HTTPError) as e:
        raise Exception(e)
        exit(1)

    if response is None:
        raise Exception("There have been no events in the last {0} {1}.".format(incrementAmount, incrementType))
        return 

    gzOutfile = gzip.GzipFile(filename="/tmp/" + outfileName, mode="w", compresslevel=9)
    gzOutfile.write(json.dumps(response, indent=4).encode("UTF-8"))
    gzOutfile.close()

    s3 = boto3.client('s3')
    s3.upload_file("/tmp/" + outfileName, bucketName, outfileName)
