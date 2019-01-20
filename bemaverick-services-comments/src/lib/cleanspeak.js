const fetch = require('node-fetch');
const log = require('lambda-log');
const { cleanspeak, system } = require('../config');

/**
 * Moderates content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param id cleanspeak id for persistent content
 * @returns Promise
 */

module.exports.moderateContent = async (content, id, method = 'POST') => {
  log.debug('moderateContent.api...');
  const host = cleanspeak.url;
  let url = `${host}/content/item/moderate`;
  if (id) url = `${host}/content/item/moderate/${id}`;
  const apiKey = cleanspeak.key;
  const headers = {
    'Content-Type': 'application/json',
    Authorization: apiKey,
  };
  const params = {
    method,
    body: JSON.stringify(content),
    headers,
  };

  log.debug('moderateContent.request params...', params);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug('moderateContent.response...', jsonResp);
  if (response.status === 200) {
    const action = jsonResp.contentAction;
    if (action === 'allow') {
    } else if (action === 'replace') {
      // Send the replacement text
      return jsonResp.content.parts[0].replacement ? jsonResp.content.parts[0].replacement : '';
    } else {
      // todo Need to send proper message for "queuedforapproval"/"reject" action
      return '*****';
    }
  } else {
    throw handleErrorResponses(response.status, jsonResp);
  }
};

/**
 * Flag content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param content id
 * @returns Promise
 */

module.exports.flagContent = async (content, id) => {
  log.debug('flagContent.api...');
  const host = cleanspeak.url;
  const url = `${host}/content/item/flag/${id}`;
  const apiKey = cleanspeak.key;
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

module.exports.generateContentObj = generateContentObj = (params, text) => {
  // System UUID..
  const from = system.uuid; // What is this
  // if (params.Attributes) {
  //   const attr = JSON.parse(params.Attributes);
  //   from = attr.uuid || from;
  // }
  const { location } = params;
  const applicationId = cleanspeak.commentsAppId;
  return {
    content: {
      // TODO: make applicationId unique to location in app (uuid of response or challenge)?
      applicationId,
      createInstant: new Date().getTime(),
      location,
      senderId: from,
      parts: [
        {
          content: text,
          name: 'comments',
          type: 'text',
        },
      ],
    },
  };
};

const handleErrorResponses = (status, jsonResp) => {
  let err;
  if (status === 401) {
    err =
      'Moderation Error:You did not supply a valid Authorization header. The header was omitted or your API key was not valid.';
  } else if (status === 402) {
    err = 'Moderation Error:Your license has expired.';
  } else if (status === 500) {
    err = 'Moderation Error:CleanSpeak internal server error.';
  } else {
    err = jsonResp;
  }
  return err;
};
