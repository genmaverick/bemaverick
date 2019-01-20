const fs = require('fs');
const path = require('path');

const nodeEnv = process.env.NODE_ENV || 'dev';
let envPath = path.resolve(process.cwd(), '.env');
const customPath = path.resolve(process.cwd(), `./.env/.${nodeEnv}.env`);
if (fs.existsSync(customPath)) {
  envPath = customPath;
}
const dotenvConfig = { path: envPath };
require('dotenv').config(dotenvConfig);

const {
  MONGO_USERNAME,
  MONGO_PASSWORD,
  MONGO_HOST,
  MONGO_DB_NAME,
  MONGO_REPLICA_SET,
  MONGO_CONNECTION_STRING,
  API_URL,
  API_KEY,
  API_ACCESS_TOKEN,
  AWS_SNS_TOPIC_EVENTS,
  AWS_LAMBDA_API_KEY,
  CLEANSPEAK_API_URL,
  CLEANSPEAK_API_KEY,
  CLEANSPEAK_COMMENTS_APP_ID,
  SYSTEM_UUID,
  TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN,
  TWILIO_SERVICE_ID,
} = process.env;

// MongoDB Connection String
const mongoString =
  MONGO_CONNECTION_STRING ||
  `mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOST}/${MONGO_DB_NAME}?ssl=true&replicaSet=${MONGO_REPLICA_SET}&authSource=admin`; // MongoDB Url
module.exports.mongoString = mongoString;

// Maverick V1 API
module.exports.maverick = {
  url: API_URL || null,
  key: API_KEY || null,
  accessToken: API_ACCESS_TOKEN || null,
};

// Maverick Lambda API
module.exports.lambda = {
  key: AWS_LAMBDA_API_KEY || null,
};

// Maverick Lambda API
module.exports.sns = {
  topicARN: AWS_SNS_TOPIC_EVENTS || null,
};

// CleanSpeak
module.exports.cleanspeak = {
  url: CLEANSPEAK_API_URL || null,
  key: CLEANSPEAK_API_KEY || null,
  commentsAppId: CLEANSPEAK_COMMENTS_APP_ID || null,
};

// System
module.exports.system = {
  uuid: SYSTEM_UUID || null,
};

// Twilio
module.exports.twilio = {
  accountSid: TWILIO_ACCOUNT_SID,
  authToken: TWILIO_AUTH_TOKEN,
  serviceId: TWILIO_SERVICE_ID,
};
