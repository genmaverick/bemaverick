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
    'Access-Control-Allow-Headers': '*',
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

module.exports.modifyOrPush = (array, idField, id, newObject) => {
  let found = false;
  const returnArray = array.map((oldObject) => {
    // console.log(`😂 oldObject[${idField}] = ${oldObject[idField]}`);
    // console.log(`🤬 if oldObject[${idField}] == ${id}`);
    if (!get(oldObject, idField)) return false;

    // eslint-disable-next-line eqeqeq
    if (get(oldObject, idField).toString() == id) {
      // coerce mongo _id to string
      // console.log('🐸 FOUND');
      found = true;
      return newObject;
    }
    // console.log('⛑ NOT FOUND');
    return oldObject;
  });
  if (!found) {
    returnArray.push(newObject);
  }
  return returnArray;
};

module.exports.findNestedValue = (array, matchField, matchValue, returnField, defaultValue = 0) =>
  get(
    // eslint-disable-next-line eqeqeq
    array.find(record => get(record, matchField).toString() == matchValue),
    returnField,
    defaultValue,
  );
