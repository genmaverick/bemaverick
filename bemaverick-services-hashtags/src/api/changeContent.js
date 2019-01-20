const mongoose = require('mongoose');
const bluebird = require('bluebird');
const get = require('lodash/get');
const HashtagModel = require('../model/Hashtag');
const { createErrorResponse, createJsonResponse, getActiveFromStatus } = require('../lib/utils');
const updateNestedDocuments = require('../lib/updateNestedDocuments');
const { mongoString } = require('../config');

mongoose.Promise = bluebird;

module.exports = async (event, context) => {
  let db;
  try {
    db = mongoose.connect(mongoString).connection;
    console.log('changeContent -- BEGIN');

    // Load the message from either SNS message or HTTP request body
    const snsMessage = get(event, 'Records[0].Sns.Message');
    const body = get(event, 'body');
    const message = JSON.parse(snsMessage || body);
    const response = {};
    console.log('event', event);
    console.log('message', message);

    // Check that the message is valid
    if (!message) {
      console.log('Invalid message');
      return createErrorResponse(400, 'Invalid message');
    }

    // Get the content information from the message
    const {
      contentType, contentId, action, data: contentData,
    } = message;
    const hashtags = get(message, ['data', 'hashtags']) || [];
    const hideFromStreams = !!+get(contentData, 'hideFromStreams', 0);
    console.log('🖼 contentType', contentType);
    console.log('🖼 contentId', contentId);
    console.log('🖼 action', action);
    console.log('🖼 data', contentData);
    console.log('🖼 hashtags', hashtags);
    console.log('🖼 hideFromStreams', hideFromStreams);

    // Calculate Active Value
    const active = getActiveFromStatus(contentType, get(contentData, 'status'));
    console.log('🖼 active', active.toString());

    // Check that the content contained hashtags
    // if (!hashtags) {
    //   console.log('No hashtags found at message.data.hashtags');
    //   return createErrorResponse(400, 'No hashtags found at message.data.hashtags');
    // }

    // Shape the hashtag objects
    const hashtagObjects = hashtags.map((name) => {
      const hashtagObject = {
        name,
        contentType,
        contentId,
        hideFromStreams,
        active,
      };
      hashtagObject[contentType] = contentData;
      return hashtagObject;
    });

    let filter;
    let operations;
    console.log('before await db');
    await db;
    console.log('after await db');
    // console.log('after await db = ', db);
    console.log('❔ action.trim() = ', action.trim());
    // Update the hashtags mongo data collection
    if (action.trim() === 'CREATE') {
      console.log('❇️ CREATE', contentType, contentId);
      response.created = await HashtagModel.insertMany(hashtagObjects);
    } else if (action.trim() === 'UPDATE') {
      console.log('🚼 UPDATE', contentType, contentId);

      // Update nested documents
      console.log('UPDATE.await updateNestedDocuments()');
      response.nested = await updateNestedDocuments({
        Model: HashtagModel,
        contentType,
        contentId,
        data: contentData,
      });
      console.log('UPDATE.response.nested', response.nested);

      // Update hashtags that already exist in the database
      filter = {
        contentType,
        contentId,
        name: { $in: hashtags },
      };
      operations = {
        $set: { hideFromStreams },
      };
      operations.$set[contentType] = contentData;
      console.log('UPDATE.filter', filter);
      console.log('UPDATE.operations', operations);
      console.log('UPDATE before await HashtagModel.updateMany(...)'); // , HashtagModel);
      response.updated = await HashtagModel.updateMany(filter, operations);
      console.log('UPDATE.response.updated', response.updated);

      // Insert new hashtags
      const foundHashtagObjects = await HashtagModel.find({
        contentType,
        contentId,
        name: { $in: hashtags },
        active: true,
      });
      const foundHashtags = foundHashtagObjects.map(hashtagObject => hashtagObject.name);
      const newHashtagObjects = hashtagObjects.filter(hashtagObject => !foundHashtags.includes(hashtagObject.name));
      console.log('🔸 newHashtagObjects', newHashtagObjects);
      response.created = await HashtagModel.insertMany(newHashtagObjects);
      console.log('UPDATE.response.created', response.created);

      // Delete hashtags that no longer exist in the data
      filter = {
        contentType,
        contentId,
        name: { $nin: hashtags },
      };
      operations = {
        $set: { active: false },
      };
      operations.$set[contentType] = contentData;
      response.deleted = await HashtagModel.updateMany(filter, operations);
    } else if (action.trim() === 'DELETE') {
      console.log('❌ DELETE', contentType, contentId);
      response.deleted = await HashtagModel.updateMany(
        {
          contentType,
          contentId,
          active: true,
        },
        {
          $set: { active: false },
        },
      );
    }

    db.close();
    console.log('📫  response', response);
    console.log('changeContent -- END');
    return createJsonResponse({ body: response });
  } catch (error) {
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
