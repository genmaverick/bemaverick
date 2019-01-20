const fs = require("fs");
const path = require("path");

const nodeEnv = process.env.NODE_ENV || "dev";
let envPath = path.resolve(process.cwd(), ".env");
const customPath = path.resolve(process.cwd(), `./.env/.${nodeEnv}.env`);
console.log("customPath", customPath);
if (fs.existsSync(customPath)) {
  envPath = customPath;
}
dotenvConfig = { path: envPath };
console.log("dotenvConfig", dotenvConfig);
require("dotenv").config(dotenvConfig);

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
  AWS_LAMBDA_API_KEY
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
  accessToken: API_ACCESS_TOKEN || null
};

// Maverick Lambda API
module.exports.lambda = {
  key: AWS_LAMBDA_API_KEY || null
};
