#!/usr/bin/env bash
aws s3 cp ./out/artifacts/Maverick_jar/Maverick.jar s3://notifications-lambda

aws lambda update-function-code --function-name notification-dev-attemptToSend --s3-bucket notifications-lambda --s3-key Maverick.jar
aws lambda update-function-code --function-name notification-dev-markAllRead --s3-bucket notifications-lambda --s3-key Maverick.jar 
aws lambda update-function-code --function-name notification-dev-sendToMany --s3-bucket notifications-lambda --s3-key Maverick.jar

aws lambda update-function-configuration --function-name notification-dev-attemptToSend --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "4618772119552000",
    "appInboxMessageId_priority": "4618772119552000",
    "appKey": "leanplum",
    "devMode": "true",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "4865809522491392",
    "pushMessageId_follow": "5008322403106816",
    "pushMessageId_general": "5643727300984832",
    "pushMessageId_posts": "4818205004660736"
  }
}'

aws lambda update-function-configuration --function-name notification-dev-markAllRead --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "4618772119552000",
    "appInboxMessageId_priority": "4618772119552000",
    "appKey": "leanplum",
    "devMode": "true",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "4865809522491392",
    "pushMessageId_follow": "5008322403106816",
    "pushMessageId_general": "5643727300984832",
    "pushMessageId_posts": "4818205004660736"
  }
}'


aws lambda update-function-configuration --function-name notification-dev-sendToMany --environment '{
  "Variables": {
    "apiVersion": "1.0.6",
    "appInboxMessageId": "4618772119552000",
    "appInboxMessageId_priority": "4618772119552000",
    "appKey": "leanplum",
    "devMode": "true",
    "maverickToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MzYxODI4N30.jfYCbk8jdPDygcc7X82FJqntCXInvzMu8bUUS4rqm7c",
    "maverickTokenDev": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsZWFucGx1bSIsImV4cCI6MTU1MjY5OTI1NX0.Gb0jLXAH2BGaJtSUJMLB3mdxrjYlW0qKaCJmyBvI4cA",
    "pushMessageId_priority": "4865809522491392",
    "pushMessageId_follow": "5008322403106816",
    "pushMessageId_general": "5643727300984832",
    "pushMessageId_posts": "4818205004660736"
  }
}'







