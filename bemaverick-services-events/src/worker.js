const get = require("lodash/get");
const mongoose = require("mongoose");
// const decode = require("jwt-decode");
const { mongoString } = require("./config");
const EventModel = require("./models/Event");

exports.handler = (event, context, callback) => {
  // console.log("mongoString", mongoString);
  mongoose.connect(mongoString)
    .catch((err) => {
      console.log('🐝 Mongo Catch');
      process.exit(1);
    });
  const db = mongoose.connection;
  // console.log("db", db);

  // console.log("event: ", JSON.stringify(event));

  var body = JSON.parse(get(event, "Records.0.body"));
  // console.log("body", body);
  const message = JSON.parse(body.Message);
  console.log("message", message);

  // Create the Event object
  const userEvent = {
    snsMessageId: get(body, "MessageId"), // unique, from AWS SQS
    eventType: get(message, "eventType"), // e.g. CREATE_CHALLENGE
    created: new Date(),
    userId: get(message, "userId"),
    contentType: get(message, "contentType"),
    contentId: get(message, "contentId"),
    data: get(message, "data")
  };
  console.log("event: ", userEvent);

  if (!userEvent.eventType) {
    console.log('🙅🏻‍ No Event Type');
    return null;
  }

  // TODO: Parse and store `userId` from JWT

  // Save it to Mongo
  const eventDocument = new EventModel({
    ...userEvent
  });
  errs = eventDocument.validateSync();
  if (errs) {
    console.log("ERROR: ", errs);
    return callback(errs.message || "Invalid event object");
  }

  // wait for the connection to be open before saving
  // formerly ```db.once("open", () => { ... ```
  db.once("open", () => {
    eventDocument.save().then(saved => {
      console.log("saved", saved);
      const response = {
        statusCode: 200,
        body: JSON.stringify({
          message: "SQS event processed.",
          event: userEvent,
          saved
        })
      };
      db.close();
      callback(null, response);
    });
  });

};
