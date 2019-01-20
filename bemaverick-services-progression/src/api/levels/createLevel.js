const mongoose = require('mongoose');
const bluebird = require('bluebird');
const { validateToken, isAdmin } = require('../../lib/maverick');
const { mongoString } = require('../../config');
const LevelModel = require('../../model/Level');
const { createErrorResponse, createJsonResponse, isJSON } = require('../../lib/utils');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  // Declare variables
  let db = {};
  let data = {};
  let errs = {};

  try {
    // Open database connection
    db = mongoose.connect(mongoString).connection;

    // Validate user data format
    if (!isJSON(event.body)) {
      return createErrorResponse(400, 'Invalid JSON format');
    }

    // Validate key and get user data
    const token = event.headers.Token || event.headers.Authorization || null;
    const tokenInfo = await validateToken(token);
    if (!tokenInfo) {
      return createErrorResponse(400, 'Invalid token authorization');
    }

    // Check for admin permissions
    if (!isAdmin(token)) {
      throw Error({
        statusCode: 403,
        message: JSON.stringify('Forbidden'),
      });
    }

    // Load data from request
    data = JSON.parse(event.body);

    // Build the database object
    const level = new LevelModel({
      ...data,
    });

    // Validate against database model
    errs = level.validateSync();
    if (errs) {
      return createErrorResponse(400, errs.message || 'Invalid object');
    }

    // wait for the connection to be open before saving
    // formerly ```db.once("open", () => { ... ```
    await db;

    // Save the hashtag object to the database
    await level.save();

    // Close the db connection
    db.close();

    // Send the hashtag response to the client
    return createJsonResponse({ body: level });
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
