const AWS = require('aws-sdk');
const uuidv4 = require('uuid/v4');
const mime = require('mime-types');
// AWS.config.loadFromPath('./s3_config.json');
AWS.config.update({
  accessKeyId: 'AKIAJ6SLMFWA5V3ZO57A',
  secretAccessKey: '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',
  region: 'us-east-1',
});

const defaultBucket = 'dev-bemaverick-images';
const defaultPrefix = 'uploads';
const defaultExtension = 'jpg';
const defaultCdnBaseUrl = null;

const base64S3PutObject = ({
  base64string,
  bucket = defaultBucket,
  prefix = defaultPrefix,
  filename,
}) =>
  new Promise((resolve, reject) => {
    const s3Bucket = new AWS.S3({ params: { Bucket: bucket } });
    // const s3 = new AWS.S3();
    const uuid = uuidv4();
    const mimeType = base64string.substring('data:'.length, base64string.indexOf(';base64'));
    const extension = mime.extension(mimeType) || defaultExtension;
    const newFilename = filename || `${uuid}.${extension}`;
    const key = prefix ? `${prefix}/${newFilename}` : newFilename;
    const cdnBaseUrl = defaultCdnBaseUrl || `https://s3.amazonaws.com/${bucket}`;

    const buf = Buffer.from(base64string.replace(/^data:image\/\w+;base64,/, ''), 'base64');
    const data = {
      Key: key,
      Body: buf,
      ContentEncoding: 'base64',
      ContentType: 'image/jpeg',
    };
    s3Bucket.putObject(data, (err, s3Data) => {
      // s3.getSignedUrl('putObject', { Bucket: bucket, ...data }, (err, s3Data) => {
      if (err) {
        console.log(err);
        console.log('Error uploading data: ', data);
        reject(err);
      } else {
        console.log('succesfully uploaded the image!');
        console.log(s3Data, s3Data);
        // resolve(s3Data);
        resolve(`${cdnBaseUrl}/${key}`);
      }
    });
  });

module.exports = { base64S3PutObject };
