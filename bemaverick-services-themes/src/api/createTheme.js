const mongoose = require('mongoose');
const bluebird = require('bluebird');
const config = require('../config');
// const log = require('lambda-log');
// const uuidv4 = require('uuidv4');
const { validateToken } = require('../lib/maverick');
const { mongoString } = require('../config');
const ThemeModel = require('../model/Theme');
const { base64S3PutObject } = require('../lib/s3');
const { createErrorResponse, createJsonResponse, isJSON } = require('../lib/utils');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  // Declare variables
  let db = {};
  let data = {};
  let errs = {};
  const responseData = {};
  const awsLambdaApiKey = config.lambda.key || null;

  try {
    // Open database connection
    db = mongoose.connect(mongoString).connection;

    // Validate user data format
    if (!isJSON(event.body)) {
      return createErrorResponse(400, 'Invalid JSON format');
    }

    // Validate key and get user data
    const token = event.headers.Token || event.headers.Authorization || null;
    await validateToken(token);

    // check if user is admin
    if (token !== awsLambdaApiKey) {
      throw {
        statusCode: 403,
        message: JSON.stringify('Forbidden'),
      };
    }
    // const tokenInfo = await validateToken(token);
    // if (!tokenInfo) {
    //   return createErrorResponse(400, 'Invalid token authorization');
    // }

    // Load theme data from request
    data = JSON.parse(event.body);

    // Mange image upload
    if (data.uploadBackgroundImageFile && data.uploadBackgroundImageFile.src) {
      const uploadedImageUrl = await base64S3PutObject({
        base64string: data.uploadBackgroundImageFile.src,
        prefix: 'themes',
      });
      data.backgroundImageFile.src = uploadedImageUrl;
      data.backgroundImage = uploadedImageUrl;
    }

    // Build the theme object
    const theme = new ThemeModel({
      ...data,
    });

    console.log('createTheme.theme', theme);

    // Validate against database model
    errs = theme.validateSync();
    if (errs) {
      return createErrorResponse(400, errs.message || 'Invalid theme object');
    }

    // wait for the connection to be open before saving
    // formerly ```db.once("open", () => { ... ```
    await db;

    // Save the theme object to the database
    await theme.save();

    // Close the db connection
    db.close();

    // Send the theme response to the client
    return createJsonResponse({ body: theme });
  } catch (error) {
    // Log the error
    console.log('error', error.body || error);

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
