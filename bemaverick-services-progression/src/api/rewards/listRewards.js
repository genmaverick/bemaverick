const mongoose = require('mongoose');
const bluebird = require('bluebird');
const aqp = require('api-query-params');
const RewardsModel = require('../../model/Reward');
const { createErrorResponse, createJsonResponse } = require('../../lib/utils');
const { mongoString } = require('../../config');
// const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  // eslint-disable-line
  try {
    const db = await mongoose.connect(mongoString).connection;
    let { filter, skip, limit, sort /* , projection */ } = aqp(event.queryStringParameters || {}); // eslint-disable-line
    sort = sort || { created: -1 }; // default sort to most recent
    limit = limit || 50;
    skip = skip || 0;
    filter = {
      active: true,
      ...filter,
    };

    const count = await RewardsModel.find(filter).count();
    const rewards = await RewardsModel.find(filter)
      .skip(skip)
      .limit(limit)
      .sort(sort)
      .populate('level');
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
      data: rewards,
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
