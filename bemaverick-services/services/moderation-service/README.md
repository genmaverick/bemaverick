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