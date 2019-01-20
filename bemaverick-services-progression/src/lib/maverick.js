/* eslint-disable */
const config = require('../config');

const request = require('request');
// todo Setup environment variables
const appKey = config.maverick.key || null;
const awsLambdaApiKey = config.lambda.key || null;

let clientToken = null;

module.exports.validateToken = validateToken = token =>
  new Promise((resolve, reject) => {
    if (token == awsLambdaApiKey) {
      // TODO: load secret token from environment variables or use AWS custom token
      resolve({ admin: true, token });
    }
    const params = {
      client_id: appKey,
      token,
    };
    const options = {
      uri: `${config.maverick.url}/v1/oauth/validate`,
      method: 'GET',
      qs: params,
      json: true,
    };

    request(options, (error, response, body) => {
      if (response && body && response.statusCode === 200) {
        resolve(body);
      } else {
        reject(response);
      }
    });
  });

module.exports.getUser = getUser = (token, clientToken = false) =>
  new Promise(async (resolve, reject) => {
    if (token == awsLambdaApiKey) {
      // TODO: load secret token from environment variables or use AWS custom token
      resolve({ loginUser: { id: 1, username: 'admin' } });
    }

    const authorization = clientToken ? await convertClientToken(token) : token;
    console.log('authorization', authorization);

    const params = {
      appKey,
    };
    const headers = {
      Authorization: authorization,
    };
    const options = {
      uri: `${config.maverick.url}/v1/user/me`,
      method: 'GET',
      qs: params,
      json: true,
      headers,
    };

    request(options, (error, response, body) => {
      if (response && body && response.statusCode === 200) {
        resolve(body);
      } else {
        reject(response);
      }
    });
  });

module.exports.getImage = getImage = (token, imageId, clientToken = false) =>
  new Promise(async (resolve, reject) => {
    if (imageId < 1) {
      console.log(`warning: comments.lib.maverick.imageId invalid (${imageId})`);
      resolve(null);
    }

    const authorization = clientToken ? await convertClientToken(token) : token;

    const params = {
      appKey,
      imageId,
    };
    const headers = {
      Authorization: authorization,
    };
    const options = {
      uri: `${config.maverick.url}/v1/site/image`,
      method: 'GET',
      qs: params,
      json: true,
      headers,
    };

    request(options, (error, response, body) => {
      if (response && body && response.statusCode === 200) {
        resolve(body);
      } else {
        reject(response);
      }
    });
  });

module.exports.getUserMentions = getUserMentions = (token, mentions) => {
  const requests = mentions.map(
    mention =>
      new Promise((resolve, reject) => {
        const username = mention.substring(1);
        getUserDetails(token, { username })
          .then(userDetails => {
            const user = Object.values(userDetails.users).find(u => u.username == username);
            const userData = {
              userId: user.userId,
              username: user.username,
            };
            resolve(userData);
          })
          .catch(error => {
            resolve(null);
          });
      }),
  );
  return Promise.all(requests);
};

module.exports.getUserDetails = getUserDetails = async (token, query, clientToken = false) => {
  const authorization = clientToken ? await convertClientToken(token) : token;

  return new Promise((resolve, reject) => {
    const params = {
      appKey,
    };
    const headers = {
      Authorization: authorization,
    };
    const options = {
      uri: `${config.maverick.url}/v1/user/details`,
      method: 'GET',
      qs: {
        appKey,
        ...query,
      },
      json: true,
      headers,
    };

    request(options, (error, response, body) => {
      if (response && body && response.statusCode === 200) {
        resolve(body);
      } else {
        reject(response || body || error.body || error);
      }
    });
  });
};

module.exports.convertClientToken = convertClientToken = token => {
  if (clientToken !== null) {
    // console.log("getClientToken.CACHED.clientToken", clientToken);
    return clientToken;
  } else {
    return new Promise((resolve, reject) => {
      const params = {
        appKey,
      };
      const headers = {
        Authorization: token,
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      const form = {
        client_id: 'bemaverick_ios',
        client_secret: '8NFnps4makvxWcyF4qZL2Nw',
        grant_type: 'client_credentials',
      };
      const options = {
        uri: `${config.maverick.url}/v1/oauth/token`,
        method: 'POST',
        json: true,
        headers,
        form,
      };

      request(options, (error, response, body) => {
        if (response && body && response.statusCode === 200) {
          // console.log("getClientToken.success.body", body);
          clientToken = body.access_token;
          resolve(clientToken);
        } else {
          reject(response || body || error.body || error);
        }
      });
    });
  }
};

module.exports.isAdmin = isAdmin = token => {
  const awsLambdaApiKey = config.lambda.key || null;
  return token === awsLambdaApiKey;
};
