import fetch from 'node-fetch';
import log from 'lambda-log';


/**
 * Update video after it completes encoding or failure
 * @param string jobId
 * @param string jobStatus
 * @param string playlistname
 * @returns Promise
 */

export const updateVideo = async (jobId, jobStatus, playlistName) => {

    log.debug('updateVideo.api...');
    const host = process.env.API_URL;
    const accessToken = process.env.ACCESS_TOKEN
    const headers = {
        'Content-Type' : 'application/json',
        'Authorization' : `Bearer ${accessToken}`
    };

    let queryParams = {
        appKey : process.env.APP_KEY,
        jobId,
        jobStatus
    };

    if(playlistName) queryParams.playlistname = playlistName;

    let esc = encodeURIComponent;
    let query = Object.keys(queryParams)
        .map(k => esc(k) + '=' + esc(queryParams[k]))
        .join('&');

    let url = `${host}/v1/site/updatevideostatus?${query}`;
    const params = {
        method: 'POST',
        headers: headers,
    };

    log.debug(`updateVideo.request url...${url}`);
    const response = await fetch(url, params);
    const jsonResp = await response.json();
    log.debug(`updateVideo.response...`);
    log.debug(jsonResp);
    if(response.status === 200) return;
    else throw response;
}

