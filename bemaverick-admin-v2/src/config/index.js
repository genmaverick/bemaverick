const config = {
  nodeEnv: process.env.NODE_ENV || "unknown",
  v1AdminBaseUrl: process.env.V1_ADMIN_BASE_URL,
  lambdaApiUrl: process.env.LAMBDA_API_URL,
  awsLambdaApiKey: process.env.AWS_LAMBDA_API_KEY,
  webAppUrl: process.env.WEB_APP_URL,
};
module.exports = config;
