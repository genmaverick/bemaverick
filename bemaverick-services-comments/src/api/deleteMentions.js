const mongoose = require('mongoose');
const bluebird = require('bluebird');
const CommentModel = require('../model/Comment');
const { createErrorResponse } = require('../lib/utils');
const { mongoString } = require('../config');
const { validateToken } = require('../lib/maverick');

mongoose.Promise = bluebird;

module.exports = async (event, context) => { // eslint-disable-line
  try {
    // Validate key
    const token = event.headers.Token || event.headers.Authorization || null;
    await validateToken(token);

    const db = await mongoose.connect(mongoString).connection;
    let { userId, active } = event.queryStringParameters;
    // todo: utilize true/false active for mentions when we add a mention status
    if (active === 'true') {
      active = true;
    } else {
      active = false;
    }

    const comments = await CommentModel.find({ 'meta.mentions': { $elemMatch: { userId } } });

    // for each comment returned
    const requests = comments.reduce((accumulator, comment) => {
      if (comment.meta) {
        // create new mentions array
        const newMentionsArr = [];

        // go through mentions array and only push mentions that don't match userId
        for (let x = 0; x < comment.meta.mentions.length; x += 1) {
          if (comment.meta.mentions[x].userId !== userId) {
            newMentionsArr.push(comment.meta.mentions[x]);
          }
        }

        // update comment with new mentions array
        accumulator.push(CommentModel.findOneAndUpdate(
          { _id: comment._id },
          { 'meta.mentions': newMentionsArr },
          { new: true },
        ));
      }
      return accumulator;
    }, []);

    const data = await Promise.all(requests);

    return { statusCode: 200, body: JSON.stringify(data) };
  } catch (error) {
    console.log('error', error.body || error);
    return createErrorResponse(
      error.statusCode || 500,
      error.message || error.body.errors[0].message || 'Unknown error',
    );
  }
};
