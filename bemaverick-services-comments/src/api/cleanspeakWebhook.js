const mongoose = require('mongoose');
const bluebird = require('bluebird');
const { mongoString } = require('../config');
const CommentModel = require('../model/Comment');

mongoose.Promise = bluebird;

module.exports = (event, context, callback) => {
  const eventBody = JSON.parse(event.body);
  const approvals = eventBody.approvals; // eslint-disable-line prefer-destructuring
  const approvalIds = Object.keys(approvals);
  const requests = [];

  const db = mongoose.connect(mongoString).connection;

  db.once('open', () => {
    approvalIds.forEach((uuid) => {
      if (approvals[uuid] === 'approved') {
        requests.push(new Promise((resolve, reject) => {
          CommentModel.findOneAndUpdate(
            { 'meta.cleanspeak.uuid': uuid },
            { flagged: false },
            (err, document) => {
              if (err) reject(err);
              resolve(document);
            },
          );
        }));
      }
    });

    Promise.all(requests)
      .then((data) => { // eslint-disable-line no-unused-vars
        db.close();
        callback(null, {
          statusCode: 200,
          body: JSON.stringify('Success'),
        });
      })
      .catch((err) => {
        if (db && typeof db.close === 'function') {
          db.close();
        }
        callback(null, {
          statusCode: 500,
          body: JSON.stringify(err),
        });
      });
  });
};
