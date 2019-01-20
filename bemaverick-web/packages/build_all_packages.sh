#!/bin/sh

a=`git describe --always`

php build_package.php --code sly
php build_package.php --code common
php build_package.php --code api
php build_package.php --code admin
php build_package.php --code website
php build_package.php --code database
php build_package.php --code vendor
php build_package.php --code scripts

b=`git describe --always`

if [ "$a" != "$b" ]
then
   echo "WARNING: GITHUB was updated in the middle of building. Please re-build packages again!"
else
   echo $a
fi


