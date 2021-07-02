---
title: Simple API for Secret Scanning
author: Cihat Yildiz
date: 2020-09-24 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---
Secret scanning is an essential process before application deployment. You need to check any information left in the code, such as password, keys, etc. There are many tools to identify secrets. Whispers are one of those tools, and it is opensource. But this is a command-line tool.
I want each developer should be able to use these tool and also, I want to run this scan in each deployment process on Jenkins. So, I created a simple API to use this command line tool. It is a basic API call. Teams will be able to use this tool to in CI/CD pipeline.

# Using CLI
If you want to use pip3 repository, we can istall whispers with the below command:
```
pip3 install whispers
```
or you can download it from the git repository
```
git clone https://github.com/Skyscanner/whispers
cd whispers
make install
```

## Initiate a scan
Basically you can run the below command to inintiate a scan. But if you want to use custom configurations you need to check to documentation of this tool.  https://github.com/Skyscanner/whispers
```
$ whispers <source-code-dir>
$ whispers --config config.yml <source-code-dir>
$ whispers --output outputs.yml <source-code-dir>
```

# Using the API
The API script will use this command line application in backend, and provides results as a response. This API can be used with the curl command below.
```sh
curl --request POST \
  --url http://apiserver/secret/scan/ \
  --header 'Content-Type: application/json' \
  --data '{
	"app_name" : "Application Name",
	"git_url" : "https://github.com/microsoft/application-test",
	"branch": "master"
}'
```

# The API Code
In this post I am not showing all the application code because there are some other API's. But everything related to secret scanning is here. The python script looks like this.  
```python
from flask import Flask, request, jsonify, Blueprint, abort
from flask_api import status
import requests, json, os, sys, time, subprocess, yaml
from requests.auth import HTTPBasicAuth

whispers_scan = Blueprint('whispers_scan', __name__)
github_token = os.environ['GIT_TOKEN'].replace('"', "")

secret_scan_root = scanPath = '/tmp/ee-secretscan/'

def downloadGITCode(appName, gitRepo, branch):
    gitRepo = gitRepo.replace('https://', '')
    cwd = os.getcwd()
    os.system('mkdir -p {}'.format(secret_scan_root))
    os.chdir(secret_scan_root)
    os.system('mkdir -p {}'.format(appName))
    scanPath = '/tmp/ee-secretscan/{}'.format(appName)
    os.chdir(scanPath)
    os.system('rm -rf *')
    print ('rm -rf *')
    git_download_cmd = "git clone -b {} https://{}@{}".format(branch, github_token, gitRepo)
    result = os.system(git_download_cmd)
    print("result "+ str(result))
    if result == 0:
        print("Remote repo successfully downloaded!!")
        return scanPath
    else:
        print("Error while cloning the repository")
        os.chdir(cwd)
        return 0

def runSecretScan(path):
    scan_cmd = "/usr/local/bin/whispers -o /tmp/ee-secretscan/scanresult.yml {}".format(path)
    os.system(scan_cmd)
    f = open("/tmp/ee-secretscan/scanresult.yml", "r")
    jf = yaml.load(f)
    return jf

@whispers_scan.route('/secret/scan/', methods = ['POST'])
def whispersScanStart():
    params = request.json
    appName = params['app_name']
    url = params['git_url']
    branch = params['branch']
    scanPath = downloadGITCode(appName, url, branch)
    print(scanPath)
    if scanPath == 0:
        return "Error while downloading the repo"
    scanResult = runSecretScan(scanPath)

    return jsonify({
        'response_message': 'Scan process has been initiated.',
        'response_code': 200,
        'scan_results' : scanResult
    })

```
