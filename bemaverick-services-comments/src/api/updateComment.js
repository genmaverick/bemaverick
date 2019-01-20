const mongoose = require('mongoose');
const bluebird = require('bluebird');
const validator = require('validator');
const CommentModel = require('../model/Comment');
const { createErrorResponse } = require('../lib/utils');
const { mongoString } = require('../config');
const findHashtags = require('../lib/findHashtags');
const publishComment = require('../lib/publishComment');

mongoose.Promise = bluebird;

module.exports = (event, context, callback) => {
  const db = mongoose.connect(mongoString).connection;
  const data = JSON.parse(event.body);
  const id = event.pathParameters.id; // eslint-disable-line
  let errs = {};
  let comment = {};

  if (!validator.isAlphanumeric(id)) {
    callback(null, createErrorResponse(400, 'Incorrect id'));
    db.close();
    return;
  }

  comment = new CommentModel({
    _id: id,
    ...data,
  });

  /**
   * Add hashtags
   */
  comment.hashtags = findHashtags(comment.body);

  errs = comment.validateSync();

  if (errs) {
    callback(null, createErrorResponse(400, 'Incorrect parameter'));
    db.close();
    return;
  }

  db.once('open', () => {
    // CommentModel.save() could be used too
    CommentModel.findByIdAndUpdate(id, comment)
      .then(() => {
        // Publish the comment for other microservice consumption
        publishComment(comment, 'UPDATE');

        callback(null, {
          statusCode: 200,
          headers: {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
          },
          body: JSON.stringify('Ok'),
        });
      })
      .catch((err) => {
        callback(err, createErrorResponse(err.statusCode, err.message));
      })
      .finally(() => {
        db.close();
      });
  });
};
