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
    if (active === 'true') {
      active = true;
    } else {
      active = false;
    }

    const comments = await CommentModel.find({ 'meta.user.userId': userId });

    const requests = comments.reduce((accumulator, comment) => {
      if (comment.meta && comment.meta.cleanspeak) {
        accumulator.push(CommentModel.findOneAndUpdate(
          { 'meta.cleanspeak.uuid': comment.meta.cleanspeak.uuid },
          { active },
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
