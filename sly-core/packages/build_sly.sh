#!/bin/sh

rm sly.tar.gz
rm Sly.zip

tar -cf sly.tar --exclude ".svn" \
    ../js \
    ../lib \
    ../modules \

gzip sly.tar

cd .. 
zip -r packages/Sly.zip * -x *.svn* -x *.tar.gz
