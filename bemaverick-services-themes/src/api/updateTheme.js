const mongoose = require('mongoose');
const bluebird = require('bluebird');
const validator = require('validator');
const ThemeModel = require('../model/Theme');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');
const { base64S3PutObject } = require('../lib/s3');
const { mongoString } = require('../config');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  const db = mongoose.connect(mongoString).connection;
  const data = JSON.parse(event.body);
  const id = event.pathParameters.id; // eslint-disable-line
  let errs = {};
  let theme = {};

  if (!validator.isAlphanumeric(id)) {
    // db.close();
    return createErrorResponse(400, 'Incorrect id');
  }

  // Mange image upload
  if (data.uploadBackgroundImageFile && data.uploadBackgroundImageFile.src) {
    const uploadedImageUrl = await base64S3PutObject({
      base64string: data.uploadBackgroundImageFile.src,
      prefix: 'themes',
    });
    data.backgroundImageFile.src = uploadedImageUrl;
    data.backgroundImage = uploadedImageUrl;
  }

  theme = new ThemeModel({
    _id: id,
    ...data,
  });

  errs = theme.validateSync();

  if (errs) {
    // db.close();
    return createErrorResponse(400, 'Incorrect parameter');
  }

  await db;
  try {
    const updatedTheme = await ThemeModel.findByIdAndUpdate(id, theme);
    return createJsonResponse({ body: updatedTheme });

    // return { statusCode: 200, body: JSON.stringify('Ok') };
  } catch (err) {
    db.close();
    return createErrorResponse(err.statusCode, err.message);
  }
};
