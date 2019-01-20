# Docker Environment
Your own local `bemaverick-web` development environment.

## Get Started

### Install Docker  
https://docs.docker.com/engine/installation/

### Clone required repositories
Since we are mounting the PHP code from your host to enable ease of development we need to have a few required repositories in place adjacent to this `bemaverick-web` clone:

- https://github.com/SlyTrunk/sly-core
- https://github.com/SlyTrunk/zend
- https://github.com/SlyTrunk/less.js-server
- https://github.com/SlyTrunk/twitter

Cloning will not work without proper permissions - if you download them as zip files, be sure to remove the '-master' from the folder name.

### Install bemaverick-web deps via composer on your local host
PHP version should be 7.0+. From the `bemaverick-web` project root run:

```
composer install
```

### Change directory to bin
```
cd docker/bin
```

### Build the docker image
```
./build-image
```

### Update your local hosts file
Quick method in bash: `sudo nano /etc/hosts`
```
127.0.0.1 <username>-admin-bemaverick.local.slytrunk.com
127.0.0.1 <username>-api-bemaverick.local.slytrunk.com
127.0.0.1 <username>-website-bemaverick.local.slytrunk.com
```

### Create and start the bemaverick-web container
```
./run <username>
```

Note: You will be prompted with "Are you sure you want to remove the existing bemaverick-web container and start a new one. All data will be lost?" Respond with a `Y` to stop and remove the existing `bemaverick-web` container and start a new one.

## Commands

### test 
Create a one off container and run the phpunit tests.

```
./test <username>
```

### shell
Open a `bash` shell in your running container to inspect the database etc.

```
./shell <username>
```

### stop
Stop the `bemaverick-web` container so the ports can be used for another container etc.

```
./stop
```

### restart
Restart the `bemaverick-web` container after a stop or reboot.

```
./restart <username>
```

### logs
Tail the `bemaverick-web` container's logs

```
./logs
```

