const mongoose = require('mongoose');
const bluebird = require('bluebird');
const CommentModel = require('../model/Comment');
const { createErrorResponse } = require('../lib/utils');
const { mongoString } = require('../config');
const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = (event, context, callback) => {
  const id = event.pathParameters.id; // eslint-disable-line

  // Validate key
  const token = event.headers.Token || event.headers.token || event.headers.Authorization || null;
  // TODO: Rewrite using async/await

  validateToken(token)
    .then((response) => { // eslint-disable-line
      const db = mongoose.connect(mongoString).connection;
      db.once('open', () => {
        CommentModel.find({ _id: event.pathParameters.id })
          .then((comment) => {
            callback(null, {
              statusCode: 200,
              headers: {
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Origin': '*',
              },
              body: JSON.stringify(comment[0]),
            });
          })
          .catch((err) => {
            callback(null, createErrorResponse(err.statusCode, err.message));
          })
          .finally(() => {
            // Close db connection or node event loop won't exit , and lambda will timeout
            db.close();
          });
      });
    })
    .catch((error) => {
      callback(
        null,
        createErrorResponse(
          error.statusCode || 500,
          error.body.errors[0].message || 'Unknown error',
        ),
      );
      db.close(); // eslint-disable-line
    });
};
