"use strict";

/*
  This was adapted from https://gist.github.com/Nath-P/899e5e021b9a19b3e601ccae083606fb
*/

const response = require("cfn-response");
const aws = require("aws-sdk");

module.exports.subscription = (event, context) => {
  console.log("REQUEST RECEIVED:\n", JSON.stringify(event));
  let responseData = {};

  if (event.RequestType === "Delete") {
    let subscriptionArn = event.PhysicalResourceId;
    let region = subscriptionArn.split(":")[3];

    aws.config.update({ region: region });

    let sns = new aws.SNS();
    sns.unsubscribe({ SubscriptionArn: subscriptionArn }, function(err, data) {
      if (err) {
        responseData = { Error: "Failed to unsubscribe from SNS Topic" };
        response.send(event, context, response.FAILED, responseData);
      } else {
        response.send(
          event,
          context,
          response.SUCCESS,
          data,
          data.SubscriptionArn
        );
      }
    });
  } else if (event.RequestType === "Create" || event.RequestType === "Update") {
    let topicArn = event.ResourceProperties.TopicArn;
    let endpoint = event.ResourceProperties.Endpoint;
    let protocol = event.ResourceProperties.Protocol;
    let region = topicArn.split(":")[3];

    if (topicArn && endpoint && protocol) {
      aws.config.update({ region: region });

      let sns = new aws.SNS();
      sns.subscribe(
        {
          TopicArn: topicArn,
          Endpoint: endpoint,
          Protocol: protocol
        },
        function(err, data) {
          if (err) {
            responseData = { Error: "Failed to subscribe to SNS Topic" };
            console.log(responseData.Error + ":\n", err);
            response.send(event, context, response.FAILED, responseData);
          } else {
            response.send(
              event,
              context,
              response.SUCCESS,
              data,
              data.SubscriptionArn
            );
          }
        }
      );
    } else {
      responseData = { Error: "Missing one of required arguments" };
      console.log(responseData.Error);
      response.send(event, context, response.FAILED, responseData);
    }
  }
};
