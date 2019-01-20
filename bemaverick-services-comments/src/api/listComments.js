const mongoose = require('mongoose');
const bluebird = require('bluebird');
const aqp = require('api-query-params');
const CommentModel = require('../model/Comment');
const { createErrorResponse } = require('../lib/utils');
const { mongoString } = require('../config');
const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => { // eslint-disable-line
  try {
    // Validate key
    const token = event.headers.Token || event.headers.token || event.headers.Authorization || null;
    await validateToken(token);

    const db = await mongoose.connect(mongoString).connection;
    let {
      filter, skip, limit, sort /* , projection */ } = aqp(event.queryStringParameters || {}); // eslint-disable-line
    sort = sort || { created: -1 }; // default sort to most recent
    limit = limit || 50;
    skip = skip || 0;
    filter = {
      active: { $ne: false },
      flagged: { $ne: true },
      ...filter,
    };
    // TODO: make find and count run asynchronously
    const count = await CommentModel.find(filter).count();
    const comments = await CommentModel.find(filter)
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
      },
      data: comments,
    };
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(body),
    };
  } catch (error) {
    console.log('error', error.body || error);
    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
