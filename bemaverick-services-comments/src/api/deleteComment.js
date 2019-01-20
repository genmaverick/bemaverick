const mongoose = require('mongoose');
const bluebird = require('bluebird');
const config = require('../config');
const { mongoString } = require('../config');
const CommentModel = require('../model/Comment');
const { createErrorResponse } = require('../lib/utils');
const { getUser } = require('../lib/maverick');
const { validateToken } = require('../lib/maverick');
const publishComment = require('../lib/publishComment');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  // eslint-disable-line
  // Declare variables
  let db = {};
  const awsLambdaApiKey = config.lambda.key || null;
  const commentId = event.pathParameters.id; // eslint-disable-line

  try {
    // Validate key
    const token = event.headers.Token || event.headers.token || event.headers.Authorization || null;
    await validateToken(token);

    const { loginUser: user } = await getUser(token);
    const loginUserId = Number(user.userId);

    // Open database connection
    db = mongoose.connect(mongoString).connection;
    await db;

    // get comment userId
    const comment = await CommentModel.find({ _id: commentId });
    const commentUserId = comment[0].userId;

    // check if user is owner of comment or admin
    if (loginUserId === commentUserId || token == awsLambdaApiKey) {
      const result = await new Promise((resolve, reject) => {
        CommentModel.findOneAndUpdate(
          {
            _id: commentId,
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

      // Publish the comment for other microservice consumption
      await publishComment(comment, 'DELETE'); // TODO: remove await

      return {
        statusCode: 200,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify(result),
      };
    }
    return {
      statusCode: 403,
      body: JSON.stringify('Forbidden'),
    };
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
