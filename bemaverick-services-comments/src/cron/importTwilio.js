const mongoose = require('mongoose');
const bluebird = require('bluebird');
const Bottleneck = require('bottleneck');
const CommentModel = require('../model/Comment');
const { getToken, getImage, getUserDetails } = require('../lib/maverick');
const { twilio: twilioConfig, maverick: maverickConfig } = require('../config');

mongoose.Promise = bluebird;

const { accountSid, authToken, serviceId } = twilioConfig;
const token = maverickConfig.accessToken; // = process.env.API_ACCESS_TOKEN || null;

// (async () => {
module.exports = (event, context, callback) => {
  try {
    context.callbackWaitsForEmptyEventLoop = false;
    migrateData();
  } catch (error) {
    callback(null, {
      statusCode: 500,
      body: JSON.stringify(error),
    });
  }
};

module.exports.migrateData = migrateData = async () => {
  const commentsToAdd = [];

  const client = require('twilio')(accountSid, authToken);

  const { mongoString } = require('../config');

  // console.log("mongoString", mongoString);
  const db = mongoose.connect(mongoString).connection;
  await db;
  console.log('----- MONGODB : OPEN -----');

  const services = client.chat.services(serviceId);
  console.log('----- TWILIO : CONNECTED -----');

  const channelLimit = 99999;
  const messageLimit = process.env.LIMIT || 99999;
  let channelCount = 0;
  let messageCount = 0;
  let updatedCount = 0;
  let errorCount = 0;

  // Process twilio channels
  services.channels.each((channel) => {
    // Skip if greater than our limit
    if (channelCount >= channelLimit) {
      // console.log("skip channel", channelCount);
      return false;
    }
    const limiter = new Bottleneck({
      maxConcurrent: 4,
      minTime: 2000,
    });
    const dbLimiter = new Bottleneck({
      maxConcurrent: 4,
      minTime: 1000,
    });

    // Print channel information
    const { sid: channelSid, uniqueName } = channel;
    const [parentType, parentId] = uniqueName.split('_');
    channelCount++;
    // console.log(`CHANNEL: ${channelCount} : ${uniqueName}`);

    // Process messages by channel
    return services.channels(channelSid).messages.each((message) => {
      // Skip if greater than our limit
      if (messageCount >= messageLimit) {
        // console.log("skip message", messageCount);
        return false;
      }
      messageCount++;
      let comment = null;
      const {
        sid, dateCreated, lastUpdated, from, body, attributes,
      } = message;

      limiter
        .schedule(() => getUserDetails(token, { username: from }, true))
        .then((userDetails) => {
          const { userId, username, profileImageId } = Object.values(userDetails.users).find(u => u.username === from);

          // create comment object
          comment = {
            body: body.trim(),
            userId, // loginUser.userId,
            parentType,
            parentId,
            created: dateCreated,
            flagged: false,
            active: true,
            meta: {
              user: {
                // ...getUserFromUsername,
                userId, // loginUser.userId,
                username: from, // users[loginUser.userId].username,
                profileImageId, // users[loginUser.userId].profileImageId,
                profileImage: {},
              },
              twilio: {
                sid,
                channelSid,
                uniqueName,
                dateCreated,
                from,
                body,
                attributes,
              },
            },
          };

          // TODO: cache getImage info
          // Add the profile image object
          const profileImageResponse = limiter.schedule(() =>
            getImage(token, Number.parseInt(profileImageId), true));

          return profileImageResponse;
        })
        .catch((error) => {
          // Allow INPUT_INVALID_IMAGE_ID errors to fail quietly
          console.log('ERROR: ', sid, from, body.trim(), error.body || error);
          return null;
        })
        .then((profileImageResponse) => {
          if (
            profileImageResponse !== null &&
            typeof profileImageResponse !== 'undefined'
          ) {
            comment.meta.user.profileImage =
              profileImageResponse.images[comment.meta.user.profileImageId];
          }

          if (comment) {
            const query = {
              'meta.twilio.sid': comment.meta.twilio.sid,
            };

            return dbLimiter.schedule(() =>
              new Promise((resolve, reject) => {
                CommentModel.update(
                  query,
                  comment,
                  { upsert: true, new: true },
                  (err, doc) => {
                    if (err) {
                      reject(err);
                    }
                    resolve(doc);
                  },
                );
              }));
          }
          throw 'NULL COMMENT';
        })
        .then((doc) => {
          updatedCount++;
          const action = 'UPSERT';
          console.log(
            updatedCount,
            `${action}: `,
            comment.meta.twilio.sid,
            comment.parentType,
            comment.parentId,
            comment.userId,
            comment.meta.user.username,
            comment.body,
          );
          commentsToAdd.push(doc);
        })
        .catch((error) => {
          updatedCount++;
          errorCount++;
          console.log(
            updatedCount,
            'ERROR: ',
            parentType,
            parentId,
            sid,
            from,
            body.trim(),
          );
          console.log(errorCount, 'FAILED');
          console.log(error.body || error);
        });
    });
  });
};
