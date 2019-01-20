/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

const nodeEnv = process.env.ENV || 'dev';
let envPath = path.resolve(process.cwd(), '.env');
const customPath = path.resolve(process.cwd(), `./.env/.${nodeEnv}.env`);
console.log('customPath', customPath);
if (fs.existsSync(customPath)) {
  envPath = customPath;
}
const dotenvConfig = { path: envPath };
console.log('dotenvConfig', dotenvConfig);
require('dotenv').config(dotenvConfig);

const {
  DEBUG_ENABLED,
  API_URL,
  API_KEY,
  API_SECRET,
  AWS_LAMBDA_API_KEY,
  CLEANSPEAK_API_URL,
  CLEANSPEAK_API_KEY,
  CLEANSPEAK_CHALLENGE_APP_ID,
  CLEANSPEAK_RESPONSE_APP_ID,
  CLEANSPEAK_TEXT_APP_ID,
} = process.env;

// Maverick V1 API
module.exports.log = {
  debug: DEBUG_ENABLED || false,
};

// Maverick V1 API
module.exports.maverick = {
  url: API_URL || null,
  key: API_KEY || null,
  secret: API_SECRET || null,
};

// Maverick Lambda API
module.exports.lambda = {
  key: AWS_LAMBDA_API_KEY || null,
};

// CleanSpeak
module.exports.cleanspeak = {
  host: CLEANSPEAK_API_URL || null,
  key: CLEANSPEAK_API_KEY || null,
  challengeAppId: CLEANSPEAK_CHALLENGE_APP_ID || null,
  responseAppId: CLEANSPEAK_RESPONSE_APP_ID || null,
  textAppId: CLEANSPEAK_TEXT_APP_ID || null,
};
