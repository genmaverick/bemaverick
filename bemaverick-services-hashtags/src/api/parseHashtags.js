const mongoose = require('mongoose');
const bluebird = require('bluebird');
const aqp = require('api-query-params');
const HashtagModel = require('../model/Hashtag');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');
const { mongoString } = require('../config');
// const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  try {
    const data = JSON.parse(event.body);

    console.log('data', data);

    return createJsonResponse({ body: data });
  } catch (error) {
    console.error('error', error.body || error);
    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
