module.exports.createErrorResponse = (statusCode, message) => ({
  statusCode: statusCode || 501,
  headers: {
    'Content-Type': 'text/plain',
    'Access-Control-Allow-Origin': '*',
  },
  body: message || 'Unknown error',
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
