const mongoose = require('mongoose');
const bluebird = require('bluebird');
const { mongoString } = require('../../config');
const TaskModel = require('../../model/Task');
const { createErrorResponse, createJsonResponse } = require('../../lib/utils');
const { validateToken, isAdmin } = require('../../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event /* , context */) => {
  // eslint-disable-line
  // Declare variables
  let db = {};
  const taskId = event.pathParameters.id; // eslint-disable-line

  try {
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

    // Open database connection
    db = mongoose.connect(mongoString).connection;
    await db;

    const result = await new Promise((resolve, reject) => {
      TaskModel.findOneAndUpdate(
        {
          _id: taskId,
        },
        {
          $set: { active: false },
        },
        { new: true },
        (err, doc) => {
          if (err) {
            reject(err);
          }
          resolve(doc);
        },
      );
    });
    return createJsonResponse({ body: result });
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
