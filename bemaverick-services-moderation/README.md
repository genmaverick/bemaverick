# Moderation Microservice

# Development
```sh
npm install
npm run dev
```
# Deployment
```sh
npm run deploy:dev
npm run deploy:prod
```

# Endpoints

## POST /text
Endpoint for moderating text not associated with specific content
```sh
curl -X POST \
  https://dev-lambda.genmaverick.com/moderate/text \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{ "text": "this is a test, bitch" }'
```

_sample response_
```json
{
    "action": "reject",
    "text": "this is a test, *****"
}
```
## POST /response
Endpoint for moderating a response
```sh
curl -X POST \
  https://dev-lambda.genmaverick.com/moderate/response \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{"id":1244,"responseUUID":"d027bb6c-638a-4841-8d2a-211a20363781","responseType":"image","mainImageUrl":"https://s3.amazonaws.com/dev-bemaverick-images/iOS_image_10EEAF89-ECE4-4C92-B7E4-DD7897543508_1529705855.jpg","videoURL":null,"coverImageURL":null,"description":"testing fu*k...","tags":["test1","test2","fu***cck"],"userUUID":"1764da4f-a2f1-4869-89e7-5bd7dd19b669","username":"testkid100"}'
```

_sample response_
```json
{
    "statusCode": 200,
    "body": "success"
}
```
