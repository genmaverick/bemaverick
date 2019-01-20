const mongoose = require('mongoose');
const bluebird = require('bluebird');
const log = require('lambda-log');
const uuidv4 = require('uuidv4');
const { mongoString, sns } = require('../config');
const CommentModel = require('../model/Comment');
require('dotenv').config();
const {
  createErrorResponse,
  createResponse,
  isJSON,
  parseMentions,
  removeWhitespace,
} = require('../lib/utils');
const {
  getUser, getUserMentions, getImage, publishChange,
} = require('../lib/maverick');
const findHashtags = require('../lib/findHashtags');
const cleanspeakApi = require('../lib/cleanspeak');
const publishComment = require('../lib/publishComment');

mongoose.Promise = bluebird;

module.exports = async (event, context, callback) => {
  // eslint-disable-line
  // Declare variables
  let db = {};
  let data = {};
  let errs = {};
  let comment = {};
  const mongooseId = '_id'; // eslint-disable-line
  let responseData = {};

  try {
    // Log the body for traceability
    console.log('createComment.event.body', event.body || 'NULL');

    // Open database connection
    db = mongoose.connect(mongoString).connection;

    // Validate user data format
    if (!isJSON(event.body)) {
      return createErrorResponse(400, 'Invalid JSON format');
    }

    // Validate key and get user data
    const token = event.headers.Token || event.headers.Authorization || null;
    const { users, loginUser } = await getUser(token);
    const uuid = uuidv4();

    // Log the user for traceability
    console.log('createComment.loginUser', loginUser || 'NULL');

    // Build the comment object
    data = JSON.parse(event.body);
    const { body } = data;
    comment = new CommentModel({
      body: removeWhitespace(body),
      ...data,
      userId: loginUser.userId,
      meta: {
        user: {
          // ...loginUser,
          userId: loginUser.userId,
          username: users[loginUser.userId].username,
          profileImageId: users[loginUser.userId].profileImageId,
          profileImage: {},
        },
        cleanspeak: {
          uuid,
        },
      },
    });

    /**
     * Add hashtags
     */
    comment.hashtags = findHashtags(comment.body);

    /**
     * Start Async requests
     */
    // Add the profile image object
    const profileImageId = comment.meta.user.profileImageId; // eslint-disable-line
    console.log('profileImageId', profileImageId);
    let profileImageResponse = getImage(token, profileImageId);

    // Add mention metadata
    const parsedMentions = parseMentions(comment.body);
    console.log('parsedMentions', parsedMentions);
    let mentions = getUserMentions(token, parsedMentions);

    // Moderate with CleanSpeak
    comment.originalBody = comment.body;
    console.log('comment.body', comment.body);
    let moderatedBody = moderateContent(comment, uuid);

    // Validate against database model
    errs = comment.validateSync();
    if (errs) {
      return createErrorResponse(400, errs.message || 'Invalid comment data');
    }

    /**
     * Process Async requests
     */
    // User Profile Image
    profileImageResponse = await profileImageResponse;
    console.log('profileImageResponse', profileImageResponse);
    if (profileImageResponse !== null) {
      comment.meta.user.profileImage = await profileImageResponse.images[profileImageId];
    }

    // Mentions
    mentions = await mentions;
    console.log('mentions', mentions);
    comment.meta.mentions = mentions.filter(user => user !== null);

    // CleanSpeak
    moderatedBody = await moderatedBody;
    console.log('moderatedBody', moderatedBody);
    comment.body = moderatedBody || comment.body; // eslint-disable-line

    // wait for the connection to be open before saving
    // formerly ```db.once("open", () => { ... ```
    await db;

    // Save the comment object to the database
    await comment.save();

    // Publish the comment for other microservice consumption
    const changeContentTopicArn = process.env.AWS_SNS_TOPIC_CHANGE_CONTENT;
    const changeContentSnsResult = await publishComment(comment, 'CREATE', changeContentTopicArn); // TODO: remove await
    console.log('changeContentSnsResult', changeContentSnsResult);
    const publishParentChangeResult = await publishChange({
      token,
      contentType: data.parentType,
      contentId: data.parentId,
      action: 'UPDATE',
    }); // TODO: remove await
    console.log('publishParentChangeResult', publishParentChangeResult);

    // Publish CREATE_COMMENT to the events sns
    const eventsTopicArn = process.env.AWS_EVENTS_TOPIC_ARN;
    const createCommentResult = await publishComment(comment, 'CREATE_COMMENT', eventsTopicArn); // TODO: remove await
    console.log('createCommentResult', createCommentResult);

    // if comment mentions a user, publish MENTION_USER to event sns
    if (mentions.length > 0) {
      const mentionUserResult = await publishComment(comment, 'MENTION_USER', eventsTopicArn); // TODO: remove await
      console.log('mentionUserResult', mentionUserResult);
    }

    // Close the db connection
    db.close();

    // Send the comment response to the client
    responseData = {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(comment),
    };

    return responseData;
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

/**
 * Handler Responsible for moderating the comments before it's posted on the comment channel.
 * @param comment
 * @returns {Promise<void>}
 */
const moderateContent = async (comment, uuid) => {
  log.debug('createComment.moderateComment ...');
  try {
    const modContent = await cleanspeakApi.moderateContent(
      cleanspeakApi.generateContentObj(
        {
          location: `${comment.parentType}_${comment.parentId}`,
        },
        comment.body,
      ),
      uuid || uuidv4(),
    );
    // return the replacement text
    if (modContent) return modContent;
    // { body: modContent };
    return false;
  } catch (error) {
    log.error('moderateComment.onMessageSendHandler:Error response...');
    log.error(error);
    // return a success on error so that the comments go through.
    // todo add this comment to the approval queue for post moderation
    return false;
  }
};
