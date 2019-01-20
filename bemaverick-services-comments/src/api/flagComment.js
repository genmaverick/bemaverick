const mongoose = require('mongoose');
const bluebird = require('bluebird');
const log = require('lambda-log');
const { mongoString, cleanspeak } = require('../config');
const CommentModel = require('../model/Comment');
const { createErrorResponse, isJSON } = require('../lib/utils');
const { getUser } = require('../lib/maverick');
const cleanspeakApi = require('../lib/cleanspeak');

mongoose.Promise = bluebird;

/**
 * Handler Responsible for  sending comments flagged by users to Cleanspeak for approval/rejection
 * @param comment
 * @returns {Promise<void>}
 */
const moderateContent = async (content, uuid) => {
  log.debug('createComment.moderateComment ...');
  try {
    const modContent = await cleanspeakApi.moderateContent(
      {
        content,
        moderation: 'requiresApproval',
      },
      uuid,
      'PUT',
    );
    // return the replacement text
    if (modContent) return modContent;
    // { body: modContent };
    return false;
  } catch (error) {
    // log.error("moderateComment.onMessageSendHandler:Error response...");
    log.error(error);
    // return a success on error so that the comments go through.
    // todo add this comment to the approval queue for post moderation
    return false;
  }
};

module.exports = async (event, context) => { // eslint-disable-line
  // Declare variables
  let db = {};

  try {
    // Open database connection
    db = mongoose.connect(mongoString).connection;

    // Validate user data format
    if (!isJSON(event.body)) {
      return createErrorResponse(400, 'Invalid JSON format');
    }

    const token = event.headers.Token || event.headers.Authorization || null;
    const id = event.pathParameters.id; // eslint-disable-line
    const data = JSON.parse(event.body);

    const { loginUser: user } = await getUser(token); // TODO: load user from Headers.Token
    const comment = await CommentModel.find({ _id: id });
    let cleanspeakUuid = '';

    if (comment[0].meta && comment[0].meta.cleanspeak && comment[0].meta.cleanspeak.uuid) {
      cleanspeakUuid = comment[0].meta.cleanspeak.uuid;
    }

    const content = {
      applicationId: cleanspeak.commentsAppId,
      createInstant: Date.now(comment[0].created),
      location: `${comment.parentType}_${comment.parentId}`,
      parts: [
        {
          content: comment[0].body,
          name: 'body',
          type: 'text',
        },
      ],
      senderDisplayName: comment[0].meta.user.username,
      senderId: user.userUUID,
    };

    moderateContent(content, cleanspeakUuid); // eslint-disable-line

    await db;
    const result = await new Promise((resolve, reject) => {
      CommentModel.findOneAndUpdate(
        { _id: id },
        {
          $set: { flagged: true },
          $push: {
            'meta.flags': {
              user,
              timestamp: Date.now(),
              ...data,
            },
          },
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
    return {
      statusCode: 200,
      body: JSON.stringify(result),
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
