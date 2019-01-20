import log from 'lambda-log';
import { success, failure } from './common/response-lib';
import * as maverickApi from './common/maverickapi-lib';
import * as cleanSpeakApi from './common/cleanspeakapi-lib';
import { isJSON } from './common/util';
import config from './config';

const debug = config.log.debug || null;
const awsLambdaApiKey = config.lambda.key || null;

// eslint-disable-next-line import/prefer-default-export
export async function main(event) {
    // Enable debug messages
    if (debug) {
        log.config.debug = true;
        log.config.dev = true;
    }
    try {
        log.debug('moderateSNSHandler.main');
        let message;
        if(event.Records[0].Sns.Message) {
            message = event.Records[0].Sns.Message;
        }
        // Validate request format
        if (!isJSON(message)) {
            log.error('moderateSNSHandler.main:Invalid request - invalid json format');
            return callback(null, failure({ status: 'error', error: 'Invalid JSON format' }));
        }

        // generate object for cleanspeak moderation
        const data = JSON.parse(message);
        let moderationContent;
        if (data.contentType == 'challenge') {
          moderationContent = generateChallengeModerationContent(data);
        } else {
          moderationContent = generateResponseModerationContent(data);
        }

        log.config.meta.params = moderationContent;
        const token = await maverickApi.getToken();
        try{
            const status = await cleanSpeakApi.moderateContent(moderationContent, data.contentType, token);
            await maverickApi.updateStatus(moderationContent.id, status, token, data.contentType);
        }catch(err) {
            await maverickApi.updateStatus(moderationContent.id, 'error', token, data.contentType);
        }
        return success({ status: 'success' });
    } catch (error) {
        log.error('moderateSNSHandler.main:Error processing request');
        log.error(error);
        return failure({ status: 'error', error: `Error processing request-${error}` });
    }
}

const generateResponseModerationContent = (data) => {
  return {
      id: data.id,
      uuid: data.responseUUID,
      type: data.responseType,
      mainImageUrl: data.mainImageUrl,
      videoURL: data.videoURL,
      coverImageURL: data.coverImageURL,
      description: data.description,
      transcriptionText: data.transcriptionText,
      tags: data.tags,
      userUUID: data.userUUID,
      username: data.username,
  };
};

const generateChallengeModerationContent = (data) => {
  return {
    id: data.id,
    uuid: data.challengeUUID,
    type: data.challengeType,
    imageUrl: data.imageUrl,
    title: data.title,
    description: data.description,
    tags: data.tags,
    userUUID: data.userUUID,
    username: data.username,
};
};
