import { success, failure } from "./common/response-lib";
import log from 'lambda-log';


export async function main(event, context, callback) {

    // Enable debug messages
    if(process.env.DEBUG_ENABLED) {
        log.config.debug = true;
    }
    try {
        log.debug('moderationNotification.main...');
        const response = await matchHandler(event);
        log.debug(`moderationNotification.main response...${response}`);
        callback(null, success(response));
    } catch (error) {
        log.error('moderationNotification.main:Error processing request');
        log.error(error);
        //Even on failure return a success so that comment is shown to the client.
        callback(null, failure(error));
    }
}

/**
 * Handler Responsible for content approvals.
 * @param req
 * @returns {Promise<void>}
 */

const contentApprovalHandler = async(req) =>  {

    log.debug(`moderationNotification.contentApprovalHandler...${JSON.stringify(req)}`);
    try{
        //todo act on the contentapprovals
        return;
    }catch (error) {
        log.error('moderationNotification.contentApprovalHandler:Error response...');
        throw error;
    }
};

/**
 * Handler Responsible for user actions.
 * @param req
 * @returns {Promise<void>}
 */

const userActionHandler = async(req) =>  {

    log.debug(`moderationNotification.userActionHandler...${JSON.stringify(req)}`);
    try{
        //todo act on the userActions
        return;
    }catch (error) {
        log.error('moderationNotification.userActionHandler:Error response...');
        throw error;
    }
};
/**
 * Responsible for parsing the request body and returning the appropriate handler to moderation notifications.
 *
 * @param {Object} event event object passed into the lambda handler
 */
const matchHandler = (event) => {
    const reqBody = event.body;
    const jsonReq = JSON.parse(event.body);

    switch (jsonReq.type) {
        case 'contentApproval':
            return contentApprovalHandler(jsonReq);
        case 'userAction':
            return userActionHandler(jsonReq);
        default:
            throw new Error('No matching handler to run for functions inputs');
    }
};
