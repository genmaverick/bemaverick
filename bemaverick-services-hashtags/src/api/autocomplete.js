const mongoose = require('mongoose');
const bluebird = require('bluebird');
const get = require('lodash/get');
const aqp = require('api-query-params');
const HashtagModel = require('../model/Hashtag');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');
const { mongoString } = require('../config');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  let db;
  try {
    db = await mongoose.connect(mongoString).connection;
    // console.log('autocomplete -- BEGIN');

    // const { query } = event.queryStringParameters;
    let { filter, skip, limit, sort /* , projection */ } = aqp(event.queryStringParameters || {}); // eslint-disable-line

    // console.log('filter', filter);
    // console.log('skip', skip);
    // console.log('limit', limit);
    // console.log('sort', sort);

    const { query } = filter;
    if (query.length < 2) {
      return createJsonResponse({ body: [] });
    }

    // console.log('query: ', query);

    const regex = new RegExp(`^${query}`, 'g');

    // console.log('await db');
    // db = await db;
    // MyModel.distinct('name', { name: /^${}/ });
    // const hashtags = await HashtagModel.distinct('name', { name: regex }); // like 'pa%'
    // console.log('await db - DONE');

    // console.log('hashtags = await HashtagModel.aggregate(...)');
    const hashtags = await HashtagModel.aggregate([
      { $match: { name: regex } },
      {
        $group: {
          _id: '$name',
          name: { $first: '$name' },
          count: {
            $sum: 1,
          },
        },
      },
      { $match: { count: filter.count || { $gte: filter.minCount || 1 } } },
      {
        $sort: sort || {
          name: 1,
        },
      },
      { $limit: limit || 100 },
      { $project: { _id: 0, name: 1, count: 1 } },
    ]);

    db.close();
    // console.log('hashtags', hashtags);

    return createJsonResponse({ body: hashtags });
  } catch (error) {
    console.error('error', error.body || error);
    console.error('error.db', db);

    // Close db connection
    if (db && typeof db.close === 'function') {
      db.close();
    }

    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
