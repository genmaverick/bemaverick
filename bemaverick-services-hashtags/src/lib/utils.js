const get = require('lodash/get');

module.exports.createErrorResponse = (statusCode, message) => ({
  statusCode: statusCode || 501,
  headers: {
    'Content-Type': 'text/plain',
    'Access-Control-Allow-Origin': '*',
  },
  body: message || 'Unknown error',
});

module.exports.createJsonResponse = ({ statusCode, body }) => ({
  statusCode: statusCode || 200,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  },
  body: JSON.stringify(body),
});

module.exports.isJSON = (str) => {
  try {
    return JSON.parse(str) && !!str;
  } catch (e) {
    return false;
  }
};

module.exports.parseMentions = (str) => {
  const pattern = /\B@[a-z0-9_-]+/gi;
  return str.match(pattern) || [];
};

module.exports.removeWhitespace = (str) => {
  const pattern = /\n\s*\n/g;
  return str
    .trim()
    .replace(pattern, '\n')
    .trim();
};

module.exports.isHexColor = (str) => {
  const hexcolor = /^#?([0-9A-F]{3}|[0-9A-F]{6}|[0-9A-F]{8})$/i;
  return hexcolor.test(str);
};

module.exports.getActiveFromStatus = (contentType, status) => {
  const activeStatus = {
    challenge: 'published',
    response: 'active',
  };
  return status === get(activeStatus, contentType, false);
};
