# Maverick Events Queue

## Topic Subscription

The AWS SQS Queue has to manually be manually subscribed to the Topic after creation.

```sh
sls deploy
```

## Watch SQS Worker Logs

```sh
sls logs -t -f worker
```

## TODO

* Setup shared services S3 config file

## References

* https://dev.to/piczmar_0/aws-lambda-sqs-events-with-serverless-framework-oj6
* https://gist.github.com/DavidWells/fc324ee4cdd0600a4b076deb3ee70f1b
* https://gist.github.com/martinssipenko/4d7b48a3d6a6751e7464

