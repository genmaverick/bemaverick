#!/bin/bash
typeset -i VERSION=$(cat ./scripts/aws/launch_config_version.txt)
VERSION=$VERSION+1
echo $VERSION > ./scripts/aws/launch_config_version.txt
echo "Increment to VERSION = $VERSION"