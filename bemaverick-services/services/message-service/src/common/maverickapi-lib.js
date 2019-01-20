import fetch from 'node-fetch';
import log from 'lambda-log';
const client_id = process.env.APP_KEY;

export const validateToken = async (token) => {

    log.debug('validateToken.api...');
    const host = process.env.API_URL;
    const headers = {
        'Content-Type' : 'application/json'
    };

    let queryParams = {
        client_id: client_id,
        token: token
    };

    let esc = encodeURIComponent;
    let query = Object.keys(queryParams)
        .map(k => esc(k) + '=' + esc(queryParams[k]))
        .join('&');

    const url = `${host}/v1/oauth/validate?${query}`;
    const params = {
        method: 'POST',
        headers: headers,
    };

    log.debug(`validateToken.request url...${url}`);
    const response = await fetch(url, params);
    const jsonResp = await response.json();
    log.debug(`validateToken.response...`);
    log.debug(jsonResp);
    if(response.status === 200) return;
    else throw response;
};

