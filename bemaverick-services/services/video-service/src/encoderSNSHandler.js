import { success, failure } from "./common/response-lib";
import log from 'lambda-log';
import * as maverickapi from "./common/maverickapi-lib";

/**
 * Handler Responsible for processing SNS notifications from video encoder.
 * @param event
 * @param context
 * @param callback
 * @returns {Promise<void>}
 */
export async function main(event, context, callback) {

    // Enable debug messages
    if(process.env.DEBUG_ENABLED) {
        log.config.debug = true;
    }
    try {
        log.debug(`videoService.main...`);
        log.debug(`SNS Message received. Message is:`);
        log.debug(event.Records[0].Sns);
        let message, response;
        if(event.Records[0].Sns.Message) {
            let message = JSON.parse(event.Records[0].Sns.Message);
            if(message.state === 'COMPLETED' || message.state === 'ERROR' ) {
                const playlists = message.playlists;
                if( playlists && (playlists[0].status === "Complete" || playlists[0].status === 'Error')) {
                    response = await maverickapi.updateVideo(message.jobId,playlists[0].status,playlists[0].name+'.m3u8') ;
                }else {
                    response = await maverickapi.updateVideo(message.jobId,message.state,null) ;
                }
            }
        }
        callback(null, success(response));
    } catch (error) {
        log.error('videoService.main:Error processing request');
        log.error(error);
        //Even on failure return a success so that comment is shown to the client.
        callback(null, failure(error));
    }
}
