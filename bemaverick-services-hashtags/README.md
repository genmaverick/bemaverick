# bemaverick-services-hashtags

API for managing Hashtags

## Deployment
```sh
npm run deploy:dev
npm run deploy:prod
```

## Hashtags API

### Autocomplete
```sh
curl -X GET \
  'https://dev-lambda.genmaverick.com/hashtags/autocomplete?query=ba' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
```

### Search
```sh
curl -X GET \
  'https://dev-lambda.genmaverick.com/hashtags?contentType=response&contentId=2' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
```

`contentType = enum: ['user', 'challenge', 'response', 'comment']`