#!/bin/bash
rm -rf prod
mkdir prod
cp -R build/built/* prod

if [ -f prod/images/favicon.ico ];
then
	mv prod/images/favicon.ico prod
fi
