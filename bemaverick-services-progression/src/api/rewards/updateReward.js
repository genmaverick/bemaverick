const mongoose = require('mongoose');
const bluebird = require('bluebird');
const validator = require('validator');
const RewardsModel = require('../../model/Reward');
const { createErrorResponse, createJsonResponse } = require('../../lib/utils');
const { mongoString } = require('../../config');
const { validateToken, isAdmin } = require('../../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  const db = mongoose.connect(mongoString).connection;
  const data = JSON.parse(event.body);
  const id = event.pathParameters.id; // eslint-disable-line
  let errs = {};

  // Validate key
  const token = event.headers.Token || event.headers.Authorization || null;
  await validateToken(token);

  // Check for admin permissions
  if (!isAdmin(token)) {
    throw Error({
      statusCode: 403,
      message: JSON.stringify('Forbidden'),
    });
  }

  if (!validator.isAlphanumeric(id)) {
    // db.close();
    return createErrorResponse(400, 'Incorrect id');
  }

  const reward = new RewardsModel({
    _id: id,
    ...data,
  });

  errs = reward.validateSync();

  if (errs) {
    // db.close();
    return createErrorResponse(400, 'Incorrect parameter');
  }

  await db;
  try {
    const updatedRewards = await RewardsModel.findByIdAndUpdate(id, reward, { new: true }).populate('level');
    return createJsonResponse({ body: updatedRewards });

    // return { statusCode: 200, body: JSON.stringify('Ok') };
  } catch (err) {
    db.close();
    return createErrorResponse(err.statusCode, err.message);
  }
};
