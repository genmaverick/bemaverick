/* eslint-disable no-use-before-define,consistent-return */
import fetch from 'node-fetch';
import log from 'lambda-log';
import config from '../config';

const host = config.cleanspeak.host || null;
const apiKey = config.cleanspeak.key || null;
const responseAppId = config.cleanspeak.responseAppId || null;
const challengeAppId = config.cleanspeak.challengeAppId || null;
/**
 * Moderates content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param item id for persistent content
 * @returns Promise
 */

export const moderateText = async (content, id) => {
  log.debug('moderateText.api...');
  let url = `${host}/content/item/moderate`;
  if (id) url = `${host}/content/item/moderate/${id}`;
  const headers = {
    'Content-Type': 'application/json',
    Authorization: apiKey,
  };
  const params = {
    method: 'POST',
    body: JSON.stringify(content),
    headers,
  };

  log.debug('moderateText.request params...', params);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug('moderateText.response...', jsonResp);
  if (response.status === 200) {
    const action = jsonResp.contentAction;
    if (action === 'allow') {
      return;
    }
    if (action === 'replace') {
      // Send the replacement text
      return jsonResp.content.parts[0].replacement
        ? jsonResp.content.parts[0].replacement
        : '';
    }
    // todo Need to send proper message for "queuedforapproval"/"reject" action
    return '*****';
  }
  throw handleErrorResponses(response.status, jsonResp);
};

/**
 * Flag content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param content id
 * @returns Promise
 */

export const flagContent = async (content, id) => {
  log.debug('flagContent.api...');
  const url = `${host}/content/item/flag/${id}`;
  const headers = {
    'Content-Type': 'application/json',
    Authorization: apiKey,
  };
  const params = {
    method: 'POST',
    body: JSON.stringify(content),
    headers,
  };

  log.debug('flagContent.request params...', params);
  const response = await fetch(url, params);
  if (response.status === 200) return;
  throw handleErrorResponses(response.status, await response.json());
};

const handleErrorResponses = (status, jsonResp) => {
  let err;
  if (status === 401) {
    err = 'Moderation Error:You did not supply a valid Authorization header. The header was omitted or your API key was not valid.';
  } else if (status === 402) {
    err = 'Moderation Error:Your license has expired.';
  } else if (status === 500) {
    err = 'Moderation Error:CleanSpeak internal server error.';
  } else {
    err = jsonResp;
  }
  return err;
};

/**
 * Moderate a response
 * @param content of the response object
 * @param item id for persistent content
 * @returns Promise
 */

export const moderateContent = async (content, contentType) => {
  log.debug('moderateContent.api...');
  const url = `${host}/content/item/moderate/${content.uuid}`;
  const headers = {
    'Content-Type': 'application/json',
    Authorization: apiKey,
  };

  // generate object to send to cleanspeak (response or challenge)
  let cleanspeakContent;
  if (contentType == 'challenge') {
    cleanspeakContent = generateChallengeContentObject(content);
  } else {
    cleanspeakContent = generateResponseContentObject(content);
  }
  log.debug('moderateContent.cleanspeakContent object...', cleanspeakContent);

  // params
  const params = {
    method: 'POST',
    body: JSON.stringify(cleanspeakContent),
    headers,
  };
  log.debug('moderateContent.request params...', params);

  // response from cleanspeak
  const cleanspeakResponse = await fetch(url, params);
  const jsonResp = await cleanspeakResponse.json();
  log.debug('moderateContent.response...', jsonResp);

  if (cleanspeakResponse.status === 200) {
    const action = jsonResp.contentAction;
    return action;
  } else if( 
    jsonResp
    && jsonResp.fieldErrors
    && jsonResp.fieldErrors.id
    && jsonResp.fieldErrors.id[0]
    && jsonResp.fieldErrors.id[0].code
    && jsonResp.fieldErrors.id[0].code === '[duplicate]id') {
    log.debug('moderateContent.response - duplicate content Id');
    
    // if content uuid already exists in cleanspeak, try again with PUT instead of POST
    params.method = 'PUT';

    // response from cleanspeak
    const secondCleanspeakResponse = await fetch(url, params);
    const secondJsonResp = await secondCleanspeakResponse.json();

    if (secondCleanspeakResponse.status === 200) {
      const secondAction = secondJsonResp.contentAction;
      return secondAction;
    } else {
      log.debug('moderateContent.response - Error');
      throw handleErrorResponses(secondCleanspeakResponse.status, secondJsonResp);
    }
  } else {
    log.debug('moderateContent.response - Error');
    throw handleErrorResponses(cleanspeakResponse.status, jsonResp);
  }
};

/**
 * Generate JSON response content object as specified by cleanspeak api
 * @param response data
 * @returns json object
 */
const generateResponseContentObject = (response) => {
  const RESPONSE_TYPE_VIDEO = 'video';
  const RESPONSE_TYPE_IMAGE = 'image';
  const parts = [];

  if (response.type === RESPONSE_TYPE_IMAGE) {
    if (response.mainImageUrl) {
      const imagePart = {
        content: response.mainImageUrl,
        name: 'response',
        type: RESPONSE_TYPE_IMAGE,
      };
      parts.push(imagePart);
    }
  } else if (response.type === RESPONSE_TYPE_VIDEO) {
    if (response.videoURL) {
      // eslint-disable-next-line no-unused-vars
      const videoPart = {
        content: response.videoURL,
        name: 'response',
        type: RESPONSE_TYPE_VIDEO,
      };
      // todo Video moderation
      // parts.push(videoPart);
    }
  }

  if (response.coverImageURL) {
    const coverimagePart = {
      content: response.coverImageURL,
      name: 'coverimage',
      type: RESPONSE_TYPE_IMAGE,
    };
    parts.push(coverimagePart);
  }

  if (response.description) {
    log.debug('DESCRIPTION');
    const description = {
      content: response.description,
      name: 'description',
      type: 'text',
    };
    parts.push(description);
  }

  if (response.transcriptionText) {
    const transcriptionText = {
      content: response.transcriptionText,
      name: 'transcription text',
      type: 'text',
    };
    parts.push(transcriptionText);
  }

  if (response.tags) {
    response.tags.forEach((tag) => {
      const tagContent = {
        content: tag,
        name: 'tag',
        type: 'text',
      };
      parts.push(tagContent);
    });
  }

  const contentObject = {
    content: {
      applicationId: responseAppId,
      createInstant: Date.now(),
      location: `responseId_${response.id}`,
      parts,
      senderDisplayName: response.username,
      senderId: response.userUUID,
    },
  };
  return contentObject;
};

/**
 * Generate JSON challenge content object as specified by cleanspeak api
 * @param response data
 * @returns json object
 */
const generateChallengeContentObject = (challenge) => {
  // const CHALLENGE_TYPE_VIDEO = 'video';
  const CHALLENGE_TYPE_IMAGE = 'image';
  const parts = [];

  if (challenge.type === CHALLENGE_TYPE_IMAGE) {
    if (challenge.imageUrl) {
      const imagePart = {
        content: challenge.imageUrl,
        name: 'challenge',
        type: CHALLENGE_TYPE_IMAGE,
      };
      parts.push(imagePart);
    }
  }
  // todo: eventually add video moderation here

  if (challenge.description && challenge.description !== ' ') {
    const description = {
      content: challenge.description,
      name: 'description',
      type: 'text',
    };
    parts.push(description);
  }

  if (challenge.title) {
    const title = {
      content: challenge.title,
      name: 'title',
      type: 'text',
    };
    parts.push(title);
  }

  if (challenge.tags) {
    challenge.tags.forEach((tag) => {
      const tagContent = {
        content: tag,
        name: 'tag',
        type: 'text',
      };
      parts.push(tagContent);
    });
  }

  const contentObject = {
    content: {
      applicationId: challengeAppId,
      createInstant: Date.now(),
      location: `challengeId_${challenge.id}`,
      parts,
      senderDisplayName: challenge.username,
      senderId: challenge.userUUID,
    },
  };
  return contentObject;
};
