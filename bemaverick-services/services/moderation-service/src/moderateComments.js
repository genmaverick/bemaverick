import { success, failure } from "./common/response-lib";
import * as cleanSpeakApi from "./common/cleanspeakapi-lib";
import log from 'lambda-log';
import uuidv4 from 'uuid/v4';


export async function main(event, context, callback) {

    // Enable debug messages
    if(process.env.DEBUG_ENABLED) {
        log.config.debug = true;
    }
    try {
        log.debug('moderateComments.main...');
        const response = await matchHandler(event);
        log.debug(`moderateComments.main response...${response}`);
        callback(null, success(response));
    } catch (error) {
        log.error('moderateComments.main:Error processing request');
        log.error(error);
        //Even on failure return a success so that comment is shown to the client.
        callback(null, success(error));
    }
}

/**
 * Handler Responsible for moderating the comments before it's posted on the comment channel.
 * @param params
 * @returns {Promise<void>}
 */

const onMessageSendHandler = async(params) =>  {

    log.debug('moderateComment.onMessageSendHandler ...');
    try{
        const msguuid = uuidv4();
        const modContent =  await cleanSpeakApi.moderateContent(generateContentObj(params, params.Body), msguuid);
        //return the replacement text
        if (modContent) return {body:modContent};
        else return;
    }catch (error) {
        log.error('moderateComment.onMessageSendHandler:Error response...');
        log.error(error);
        //return a success on error so that the comments go through.
        //todo add this comment to the approval queue for post moderation
        return;
    }
};

/**
 * Handler Responsible for handling the reported comments
 * @param params
 * @returns {Promise<void>}
 */

const onMessageUpdateHandler = async(params) =>  {

    log.debug('moderateComment.onMessageUpdateHandler ...');
    //Return if the report attributes aren't present.
    if(!params.Attributes) return;
    let attributes = JSON.parse(params.Attributes);
    if(!attributes.report) return;

    try{
        //Add content to Cleanspeak commentqueue before flagging it
        const contentObj = generateContentObj(params, params.Body);
        contentObj.content.location = params.MessageSid;
        const msguuid = uuidv4();
        await cleanSpeakApi.moderateContent(contentObj, msguuid);

        const flagContent = {
          'flag':{
              'createInstant': new Date().getTime(),
              'reason':attributes.report,
              'reporterId':'f8e2cedc-3d59-4167-96e2-d94691b870f7'
              // reporterId:attributes.reporterUUID //todo Need to get reporter UUID from attributes
          }
        };
        await cleanSpeakApi.flagContent(flagContent, msguuid);
        return;
    }catch (error) {
        log.error('moderateComment.onMessageUpdateHandler:Error response...');
        log.error(error);
        return;
    }
};

/**
 * Handler Responsible for moderating the comments posted on the Channel attributes.
 * @param params
 * @returns {Promise<void>}
 */
const onChannelUpdateHandler = async(params) =>  {
    //return if the attributes are null
    if(!params.Attributes) return;
    let attributes = JSON.parse(params.Attributes);
    log.debug(`moderateComment.onChannelUpdateHandler ...${attributes}`);
    const firstComment = attributes.firstComment || '';
    try {
        const msguuid = uuidv4();
        const modContent = await cleanSpeakApi.moderateContent(generateContentObj(params, firstComment), msguuid);
        if (modContent) {
            attributes.firstComment = modContent;
            log.debug(`moderateComment.onChannelUpdateHandler:updatedAttributes...${attributes}`);
            return {attributes: JSON.stringify(attributes) };
        } else return;
    } catch (error) {
        log.error('moderateComment.onMessageSendHandler:Error response...');
        log.error(error);
        return;
    }
};

const generateContentObj = (params, text) => {
    //System UUID..
    let from = 'fc156962-278f-44ec-b8d5-2e4afd6b055d';
    if(params.Attributes) {
        const attr = JSON.parse(params.Attributes);
        from = attr.uuid || from;
    }
    const applicationId = process.env.COMMENT_APP_ID;
    return {
        'content': {
            'applicationId': applicationId,
            'createInstant': new Date().getTime(),
            'location': params.ChannelSid,
            'senderId': from,
            'parts': [
                {
                    'content': text,
                    "name": "comments",
                    "type": "text"
                }
            ]
        }
    };
}



/**
 * Responsible for parsing the event object passed into the lambda function, and
 * returning the appropriate handler for the given EventType.
 *
 * @param {Object} event event object passed into the lambda handler
 */
const matchHandler = (event) => {
    const params = event.queryStringParameters;
    log.config.meta.params = params;
    switch (params.EventType) {
        case 'onMessageSend':
            return onMessageSendHandler(params);
        case 'onChannelUpdate':
            return onChannelUpdateHandler(params);
        case 'onMessageUpdate':
            return onMessageUpdateHandler(params);
        default:
            throw new Error('No matching handler to run for functions inputs');
    }
};
