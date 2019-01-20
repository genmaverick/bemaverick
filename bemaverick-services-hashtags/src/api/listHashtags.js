const mongoose = require('mongoose');
const bluebird = require('bluebird');
const aqp = require('api-query-params');
const HashtagModel = require('../model/Hashtag');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');
const { mongoString } = require('../config');
// const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  // eslint-disable-line
  try {
    // Validate key
    // const token = event.headers.Token || event.headers.Authorization || null;
    // await validateToken(token);

    console.log('event.queryStringParameters', event.queryStringParameters);

    const db = await mongoose.connect(mongoString).connection;
    let { filter, skip, limit, sort /* , projection */ } = aqp(event.queryStringParameters || {}); // eslint-disable-line
    sort = sort || { created: -1 }; // default sort to most recent
    limit = limit || 100;
    skip = skip || 0;
    filter = {
      active: true,
      hideFromStreams: { $ne: true },
      ...filter,
    };

    // Filter hidden content
    // filter.challenge = filter.challenge || {};
    // filter.challenge.hideFromStreams = { $ne: 1 };
    // filter.response = filter.response || {};
    // filter.$or = [
    //   { response: { $exists: true }, 'response.hideFromStreams': { $ne: 1 } },
    //   { challenge: { $exists: true }, 'challenge.hideFromStreams': { $ne: 1 } },
    //   { response: { $exists: false }, challenge: { $exists: false } },
    // ];
    // return createJsonResponse({ body: filter });

    // TODO: make find and count run asynchronously
    const count = await HashtagModel.find(filter).count();
    const hashtags = await HashtagModel.find(filter)
      .skip(skip)
      .limit(limit)
      .sort(sort);
    // .select(projection)

    db.close();

    const body = {
      meta: {
        skip,
        limit,
        sort,
        count,
        filter,
      },
      data: hashtags,
    };
    return createJsonResponse({ body });
  } catch (error) {
    console.error('error', error.body || error);
    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
