const aws = require('aws-sdk');
const uuidv4 = require('uuid/v4');
const { createErrorResponse, createJsonResponse } = require('../lib/utils');

const options = {
  bucket: 'S3_BUCKET_NAME',
  region: 'S3_REGION',
  signatureVersion: 'v4',
  ACL: 'public-read',
};

const s3 = new aws.S3(options);

// eslint-disable-next-line no-unused-vars
module.exports = async (event, context) => {
  try {
    console.log('event', event);

    const originalFilename = event.query.objectName;

    // custom filename using random uuid + file extension
    const fileExtension = originalFilename.split('.').pop();
    const filename = `${uuidv4()}.${fileExtension}`;

    const params = {
      Bucket: options.bucket,
      Key: filename,
      Expires: 60,
      ContentType: event.query.contentType,
      ACL: options.ACL,
    };

    const signedUrl = s3.getSignedUrl('putObject', params);

    if (signedUrl) {
      // you may also simply return the signed url, i.e. `return { signedUrl }`
      return createJsonResponse({
        body: {
          signedUrl,
          filename,
          originalFilename,
          publicUrl: signedUrl.split('?').shift(),
        },
      });
    }
    throw Error('Cannot create S3 signed URL');
  } catch (error) {
    // Log the error
    console.log('error', error.body || error);

    // Return an error message to the client
    return createErrorResponse(
      error.statusCode || 500,
      error.message || (error.body && error.body.errors[0].message) || 'Unknown error',
    );
  }
};
