const mongoose = require('mongoose');
const bluebird = require('bluebird');
const RewardsModel = require('../../model/Reward');
const { createErrorResponse, createJsonResponse } = require('../../lib/utils');
const { mongoString } = require('../../config');
const { validateToken } = require('../../lib/maverick');

mongoose.Promise = bluebird;

// eslint-disable-next-line no-unused-vars
module.exports = async (event, context) => {
  let db = {};

  // Validate key
  // const token = event.headers.Token || event.headers.Authorization || null;
  // validateToken(token);

  try {
    // Open database connection
    db = mongoose.connect(mongoString).connection;
    await db;

    const filter = { _id: event.pathParameters.id };
    const rewards = await RewardsModel.find(filter).populate('level');

    if (!rewards || rewards.length < 1) {
      const error = new Error('Rewards not found');
      error.statusCode = 404;
      throw error;
    }

    return createJsonResponse({ body: rewards[0] });
  } catch (error) {
    // Log the error
    console.error('error', error.body || error);

    // Close db connection
    if (db && typeof db.close === 'function') {
      db.close();
    }
    // Return an error message to the client
    return createErrorResponse(
      error.statusCode || 500,
      error.message || (error.body && error.body.errors[0].message) || 'Unknown error',
    );
  }
};
