const axios = require('axios');
const queryString = require('query-string');
const formatDate = require('./formatDate');
const config = require('./config').default;
const Leanplum = require('./leanplum').default;

// console.log('config', config);

const defaultHeaders = {
  'Cache-Control': 'no-cache',
  'Content-Type': 'application/x-www-form-urlencoded',
};
// Reject only if the status code is greater than or equal to 500
const validateStatus = status => status < 500;

class Maverick {
  constructor() {
    this.api = config.maverickApi;
    this.accessToken = false;
    this.authenticated = false;
    this.user = false;
  }

  async refreshToken() {
    const { url: baseUrl, clientId, clientSecret } = this.api;
    const options = {
      method: 'post',
      url: `${baseUrl}/oauth/token`,
      headers: defaultHeaders,
      data: queryString.stringify({
        client_id: clientId,
        client_secret: clientSecret,
        grant_type: 'client_credentials',
      }),
      validateStatus,
    };

    const response = await axios.request(options);
    this.accessToken = response.data.access_token;
    return response.data;
  }

  async getAccessToken() {
    if (this.accessToken) {
      return this.accessToken;
    }
    await this.refreshToken();
    return this.accessToken;
  }

  async signin(username, password) {
    // grant_type=password&username=selina-test-kid&password=testpass
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, clientId, clientSecret } = this.api;
    const options = {
      method: 'post',
      url: `${baseUrl}/oauth/token`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      data: queryString.stringify({
        authorization: accessToken,
        client_id: clientId,
        client_secret: clientSecret,
        grant_type: 'password',
        username,
        password,
      }),
      validateStatus,
    };

    const response = await axios.request(options);
    this.authenticated = response.data;
    await this.constructor.setTokenCookie(response.data.access_token);

    // identify user through leanplum
    Leanplum.setUserId();

    return response;
  }

  async zendesk(values) {
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, clientId, clientSecret } = this.api;

    const {
      name, email, username, message,
    } = values;
    const options = {
      method: 'post',
      url: `${baseUrl}/site/zendesk`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      data: queryString.stringify({
        client_id: clientId,
        client_secret: clientSecret,
        name,
        email,
        username,
        message,
      }),
      validateStatus,
    };

    const response = await axios.request(options);
    return response;
  }

  async validateUsername(username) {
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, /* clientId, clientSecret, */ appKey } = this.api;
    const options = {
      method: 'post',
      url: `${baseUrl}/auth/validateusername`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      data: queryString.stringify({
        // authorization: accessToken,
        // client_id: clientId,
        // client_secret: clientSecret,
        appKey,
        username,
      }),
      validateStatus,
    };

    const response = await axios.request(options);
    return response;
  }

  async registerKid(values) {
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, /* clientId, clientSecret, */ appKey } = this.api;
    const {
      username, password, birthdate, emailAddress, parentEmailAddress,
    } = values;
    const options = {
      method: 'post',
      url: `${baseUrl}/auth/registerkid`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      data: queryString.stringify({
        // authorization: accessToken,
        // client_id: clientId,
        // client_secret: clientSecret,
        appKey,
        username,
        password,
        birthdate: formatDate(birthdate),
        emailAddress,
        parentEmailAddress,
      }),
      validateStatus,
    };

    const response = await axios.request(options);
    this.authenticated = response.data;
    // console.log('registerKid.response', response);
    if (response.data.access_token) {
      await this.constructor.setTokenCookie(response.data.access_token);
      // identify user through leanplum and set attributes
      Leanplum.setUserAttributes();
    }
    return response;
  }

  async getChallenge({ challengeId }) {
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, appKey } = this.api;
    const options = {
      method: 'get',
      url: `${baseUrl}/challenge/details`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      params: {
        appKey,
        challengeId,
      },
      validateStatus,
    };

    const response = await axios.request(options);
    return response;
  }

  async getResponse({ responseId }) {
    const accessToken = await this.getAccessToken();
    const { url: baseUrl, appKey } = this.api;
    const options = {
      method: 'get',
      url: `${baseUrl}/response/details`,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      params: {
        appKey,
        responseId,
      },
      validateStatus,
    };

    const response = await axios.request(options);
    return response;
  }

  static async setTokenCookie(accessToken) {
    const url = '/auth/token';
    const options = {
      method: 'get',
      url,
      headers: {
        ...defaultHeaders,
        authorization: accessToken,
      },
      validateStatus,
    };

    const response = await axios.request(options);
    return response;
  }

  async getCookieUser() {
    const url = '/auth/user';
    const options = {
      method: 'get',
      url,
      headers: {
        ...defaultHeaders,
      },
      validateStatus,
    };

    const response = await axios.request(options);
    this.user = response;
    return response;
  }
}

// export const oauthToken = () =>

export default new Maverick();
