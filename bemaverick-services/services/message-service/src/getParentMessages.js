import * as dynamoDbLib from "./common/dynamodb-lib";
import { success, failure } from "./common/response-lib";
import * as maverickapi from "./common/maverickapi-lib";
import log from 'lambda-log';

export async function main(event, context, callback) {
    // Enable debug messages
    if(process.env.DEBUG_ENABLED) {
        log.config.debug = true;
    }
    try {
        log.debug('getParentMessages.main...');
        const tableName = process.env.DYNAMO_DB_TABLE_NAME;
        log.debug(`getParentMessages.tablename=${tableName}`)
        const dbparams = {
            TableName: tableName,
            IndexName: "targetUserId-index",
            KeyConditionExpression: "targetUserId = :targetUserId",
            ExpressionAttributeValues: {
                ":targetUserId" : event.pathParameters.id
            }
        };

        const params = event.queryStringParameters;
        log.config.meta.params = event.pathParameters;
        log.debug(`getParentMessages.params=`);
        log.debug(params);
        if( params && params.apiKey === process.env.AWS_LAMBDA_API_KEY) {
            const result = await dynamoDbLib.call("query", dbparams);
            if (result.Items) {
                // Return the retrieved items
                callback(null, success(result.Items));
            } else {
                callback(null, failure({ status: false, error: "No messages." }));
            }
        }else {
            callback(null, failure({ status: false, error: "Invalid Authorization header" }));
        }
    } catch (error) {
        log.error('Error processing getParentMessages...');
        log.error(error);
        callback(null, failure({ status: false }));
    }
}
