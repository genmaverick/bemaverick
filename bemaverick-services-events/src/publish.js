const AWS = require("aws-sdk");

// Set region
AWS.config.update({ region: "us-east-1" });

exports.handler = function(event, context, callback) {
  var accountId = context.invokedFunctionArn.split(":")[4];
  var topicARN = process.env.EVENTS_TOPIC_ARN;

  // console.log("accountId", accountId);
  // console.log("topicARN", topicARN);

  // response and status of HTTP endpoint
  var responseBody = {
    message: ""
  };
  var responseCode = 200;

  // SQS message parameters

  // Create publish parameters
  var params = {
    Message: event.body /* required */,
    TopicArn: topicARN
  };

  // Create promise and SNS service object
  var publishTextPromise = new AWS.SNS({ apiVersion: "2010-03-31" })
    .publish(params)
    .promise();

  // Handle promise's fulfilled/rejected states
  publishTextPromise
    .then(function(data) {
      console.log(
        `Message ${params.Message} send sent to the topic ${params.TopicArn}`
      );
      console.log("MessageID is " + data.MessageId);
      responseBody.message = data;
      const response = {
        statusCode: responseCode,
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(responseBody)
      };
      callback(null, response);
    })
    .catch(function(err) {
      console.error(err, err.stack);
      callback(err);
    });
};
