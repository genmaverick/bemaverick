# Maverick Wordpress Marketing Website

## DEVELOPMENT
### Getting Started
```sh
./scripts/docker/build.sh
./scripts/docker/up.sh
```

### Restore the dev database (from data/wordpress.sql)
```sh
./scripts/docker/mysql-restore.sh
```

### Open the Site
Open http://localhost:8000

### Enable S3 Uploads
Enable the `amazon-s3-and-cloudfront` plugin and configure the bucket at `/wp-admin/options-general.php?page=amazon-s3-and-cloudfront`.

Default bucket: `bemaverick-wordpress-uploads`

## PRODUCTION
### Deploy AWS Stack
Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
```sh
./scripts/aws/create-stack.sh
```
### Update AWS Stack
Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
```sh
CIRCLE_BUILD_NUM=dev2 ./scripts/aws/update-stack.sh
```
### Overwrite Production data (from data/wordpress.sql)
```sh
./scripts/docker/mysql-backup.sh # optional
./scripts/aws/mysql-restore.sh
```

## TODO

* Implement ACF JSON https://www.advancedcustomfields.com/resources/local-json/


## Plugins

### WP Offload S3 - Gold 

https://deliciousbrains.com/my-account/licenses/#lic-17433-downloads
License: b932578c-ea4a-49b8-9910-7013b1a5a3eb