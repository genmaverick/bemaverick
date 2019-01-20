#!/bin/bash
docker exec bemaverick_wordpress_db /usr/bin/mysqldump -u wordpress --password=wordpress wordpress > ./data/wordpress.sql
