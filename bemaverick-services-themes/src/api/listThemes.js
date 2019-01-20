const mongoose = require('mongoose');
const bluebird = require('bluebird');
const aqp = require('api-query-params');
const ThemeModel = require('../model/Theme');
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
    sort = sort || { sortOrder: 1 }; // default sort to most recent
    limit = limit || 50;
    skip = skip || 0;
    filter = {
      active: true,
      ...filter,
    };

    // if query param populate = 0, populate = false and reward data will not populate
    const populate = filter.populate != '0';

    delete filter.populate;

    const themesQuery = ThemeModel.find(filter)
      .skip(skip)
      .limit(limit)
      .sort(sort);

    if (populate) {
      themesQuery.populate('reward');
    }

    const [data, count] = await Promise.all([themesQuery.exec(), ThemeModel.find(filter).count()]);

    db.close();

    const body = {
      meta: {
        skip,
        limit,
        sort,
        count,
        filter,
      },
      data,
    };
    return createJsonResponse({ body });
  } catch (error) {
    console.log('error', error.body || error);
    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
