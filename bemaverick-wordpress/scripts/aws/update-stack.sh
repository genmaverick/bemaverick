#!/bin/bash
# ./scripts/aws/launch_config_increment.sh
# typeset -i VERSION=$(cat ./scripts/aws/launch_config_version.txt)
VERSION=$CIRCLE_BUILD_NUM

aws cloudformation update-stack \
    --stack-name bemaverick-wordpress-stack \
    --template-body file://$PWD/scripts/aws/bemaverick-wordpress-stack.yml \
    --parameters \
    ParameterKey=VpcId,ParameterValue=vpc-9bd678e0 \
    ParameterKey=Subnets,ParameterValue=\"subnet-16595472,subnet-253f1e0a,subnet-328da96f,subnet-6a21c920,subnet-db4811e4,subnet-e4815eeb\" \
    ParameterKey=KeyName,ParameterValue=bemaverick-aws-chrisfitkin \
    ParameterKey=InstanceType,ParameterValue=t2.medium \
    ParameterKey=DBClass,ParameterValue=db.t2.small \
    ParameterKey=DBName,ParameterValue=wordpress \
    ParameterKey=DBUser,ParameterValue=wordpress \
    ParameterKey=DBPassword,ParameterValue=oCoAcDbWRJNGMh8vnwRNFqU3 \
    ParameterKey=MultiAZDatabase,ParameterValue=false \
    ParameterKey=WebServerCapacity,ParameterValue=2 \
    ParameterKey=DBAllocatedStorage,ParameterValue=5 \
    ParameterKey=LCVersion,ParameterValue=$VERSION \
    --region us-east-1
