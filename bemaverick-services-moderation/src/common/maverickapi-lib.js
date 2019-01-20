import fetch from 'node-fetch';
import log from 'lambda-log';
import FormData from 'form-data';
import config from '../config';

const appKey = config.maverick.key || null;
const appSecret = config.maverick.secret || null;

export const validateToken = async (token) => {
  const queryParams = {
    client_id: appKey,
    token,
  };
  const esc = encodeURIComponent;
  const query = Object.keys(queryParams)
    .map(k => `${esc(k)}=${esc(queryParams[k])}`)
    .join('&');
  const url = `${config.maverick.url}/v1/oauth/validate?${query}`;
  const headers = {
    'Content-Type': 'application/json',
  };
  const params = {
    method: 'GET',
    headers,
  };
  log.debug(`moderateContent.validateToken request url...${url}`);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug('moderateContent.validateToken.response...');
  log.debug(jsonResp);
  if (response.status === 200) return true;
  throw jsonResp;
};

export const getToken = async () => {
  const url = `${config.maverick.url}/v1/oauth/token`;

  const form = new FormData();
  form.append('client_id', appKey);
  form.append('client_secret', appSecret);
  form.append('grant_type', 'client_credentials');


  const params = {
    method: 'POST',
    body: form,
  };
  log.debug('moderateContent.getToken.request...');
  log.debug(params);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug('moderateContent.getToken.response...');
  log.debug(jsonResp);
  if (response.status === 200) return jsonResp.access_token;
  throw jsonResp;
};

export const updateStatus = async (contentId, status, token, contentType) => {
  const queryParams = {
    appKey,
    moderationStatus: status,
  };

  if (contentType == 'response') {
    queryParams.responseId = contentId;
  } else {
    queryParams.challengeId = contentId;
  }

  const esc = encodeURIComponent;
  const query = Object.keys(queryParams)
    .map(k => `${esc(k)}=${esc(queryParams[k])}`)
    .join('&');
  const url = `${config.maverick.url}/v1/${contentType}/updatestatus?${query}`;
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };
  const params = {
    method: 'GET',
    headers,
  };
  log.debug(`moderateContent.updateStatus request url...${url}`);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug('moderateContent.updateStatus.response...');
  log.debug(jsonResp);
  if (response.status === 200) return true;
  throw response;
};
