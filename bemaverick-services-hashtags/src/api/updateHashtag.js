const mongoose = require('mongoose');
const bluebird = require('bluebird');
const validator = require('validator');
const HashtagModel = require('../model/Hashtag');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');
const { mongoString } = require('../config');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  const db = mongoose.connect(mongoString).connection;
  const data = JSON.parse(event.body);
  const id = event.pathParameters.id; // eslint-disable-line
  let errs = {};

  if (!validator.isAlphanumeric(id)) {
    // db.close();
    return createErrorResponse(400, 'Incorrect id');
  }

  const hashtag = new HashtagModel({
    _id: id,
    ...data,
  });

  errs = hashtag.validateSync();

  if (errs) {
    // db.close();
    return createErrorResponse(400, 'Incorrect parameter');
  }

  await db;
  try {
    const updatedHashtag = await HashtagModel.findByIdAndUpdate(id, hashtag, { new: true });
    return createJsonResponse({ body: updatedHashtag });

    // return { statusCode: 200, body: JSON.stringify('Ok') };
  } catch (err) {
    db.close();
    return createErrorResponse(err.statusCode, err.message);
  }
};
