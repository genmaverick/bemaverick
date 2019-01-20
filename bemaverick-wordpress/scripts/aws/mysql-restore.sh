#!/bin/bash
read -p "This will overwite the production Wordpress database. Are you sure? (y/n) " -n 1 -r
echo    # (optional) move to a new line
echo "note: Make sure your IP address is in the appropriate AWS security group"
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sed -i '' 's|http://localhost:8000|https://wordpress.genmaverick.com|g' ./data/wordpress.sql
    sed -i '' 's|localhost:8000|wordpress.genmaverick.com|g' ./data/wordpress.sql
    sed -i '' 's|http://bemav-appli-1uxy9d14nn52c-663342170.us-east-1.elb.amazonaws.com|https://wordpress.genmaverick.com|g' ./data/wordpress.sql
    sed -i '' 's|bemav-appli-1uxy9d14nn52c-663342170.us-east-1.elb.amazonaws.com|wordpress.genmaverick.com|g' ./data/wordpress.sql
    cat ./data/wordpress.sql | mysql -hbd1qe6ymp4gtehw.c7uo3aw7m46s.us-east-1.rds.amazonaws.com -uwordpress -poCoAcDbWRJNGMh8vnwRNFqU3 wordpress
fi
