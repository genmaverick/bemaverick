const AWS = require('aws-sdk');
require('dotenv').config();

// actions = ['CREATE', 'UPDATE', 'DELETE'];
const region = process.env.AWS_REGION || 'us-east-1';
// const accountId = process.env.AWS_ACCOUNT_ID || '415196061258';
const accessKeyId = process.env.AWS_SNS_ACCESS_KEY_ID;
const secretAccessKey = process.env.AWS_SNS_ACCESS_KEY_SECRET;
const awsConfig = {
  region,
  accessKeyId,
  secretAccessKey,
};

AWS.config.update(awsConfig);

const publishComment = (comment, action, topicArn = process.env.AWS_SNS_TOPIC_CHANGE_CONTENT) => {
  let message;

  if (['CREATE_COMMENT', 'MENTION_USER'].includes(action)) {
    message = {
      eventType: action,
      userId: comment.userId,
      contentType: 'comment',
      contentId: comment._id,
      data: {
        comment,
      },
    };
  } else {
    message = {
      contentType: 'comment',
      contentId: comment._id,
      action,
      data: comment,
    };
  }

  const params = {
    TopicArn: topicArn,
    Message: JSON.stringify(message) /* required */,
  };
  // console.log('publishComment.message', message);
  // console.log('publishComment.params', params);
  return new AWS.SNS().publish(params).promise();
};

module.exports = publishComment;
