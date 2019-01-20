#!/bin/bash
cat ./data/wordpress.sql | docker exec -i bemaverick_wordpress_db /usr/bin/mysql -u wordpress --password=wordpress wordpress
