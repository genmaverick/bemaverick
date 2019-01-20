#!/usr/bin/env bash
aws s3 cp ./out/artifacts/Maverick_jar/Maverick.jar s3://notifications-lambda

aws lambda update-function-code --function-name notification-attemptToSend --s3-bucket notifications-lambda --s3-key Maverick.jar
aws lambda update-function-code --function-name notification-markAllRead --s3-bucket notifications-lambda --s3-key Maverick.jar
aws lambda update-function-code --function-name notification-sendToMany --s3-bucket notifications-lambda --s3-key Maverick.jar

aws lambda update-function-configuration --function-name notification-attemptToSend --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "6178227410305024",
    "appInboxMessageId_priority": "6676801759870976",
    "appKey": "leanplum",
    "devMode": "false",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "5672132807884800",
    "pushMessageId_follow": "4857259467341824",
    "pushMessageId_general": "4966979708518400",
    "pushMessageId_posts": "5157976098865152"
  }
}'

aws lambda update-function-configuration --function-name notification-markAllRead --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "6178227410305024",
    "appInboxMessageId_priority": "6676801759870976",
    "appKey": "leanplum",
    "devMode": "false",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "5672132807884800",
    "pushMessageId_follow": "4857259467341824",
    "pushMessageId_general": "4966979708518400",
    "pushMessageId_posts": "5157976098865152"
  }
}'


aws lambda update-function-configuration --function-name notification-sendToMany --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "6178227410305024",
    "appInboxMessageId_priority": "6676801759870976",
    "appKey": "leanplum",
    "devMode": "false",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "5672132807884800",
    "pushMessageId_follow": "4857259467341824",
    "pushMessageId_general": "4966979708518400",
    "pushMessageId_posts": "5157976098865152"
  }
}'







