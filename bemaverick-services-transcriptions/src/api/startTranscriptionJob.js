const log = require('lambda-log');
const mongoose = require('mongoose');
const AWS = require('aws-sdk');
const { validateToken } = require('../lib/maverick');
const { mongoString } = require('../config');
const TranscriptionModel = require('../model/Transcription');
const {
  createErrorResponse,
  isJSON,
} = require('../lib/utils');


module.exports = async (event, context) => {
  log.debug('startTranscriptionJob:start');
  // Declare variables
  let db = {};
  let data = {};
  let errs = {};
  let transcription = {};
  const mongooseId = "_id"; // eslint-disable-line
  const contentUuid = event.pathParameters.uuid; // response or challenge uuid

  try {
    // Open database connection
    db = mongoose.connect(mongoString).connection;

    // Validate user data format
    if (!isJSON(event.body)) {
      return createErrorResponse(400, 'Invalid JSON format');
    }

    // validate key
    const token = event.headers.Token || event.headers.Authorization || null;
    await validateToken(token);

    // start aws transcribe service
    AWS.config.loadFromPath('./src/lib/awsConfig.json');
    const transcribeservice = new AWS.TranscribeService();

    // create transcribe param object
    // todo: create and send data to mongodb
    data = JSON.parse(event.body);
    const transcribeParams =
    {
      TranscriptionJobName: `${data.env}_${data.contentType}_${data.id}`,
      LanguageCode: 'en-US',
      MediaFormat: data.videoFormat,
      Media: {
        MediaFileUri: data.videoUrl,
      },
    };

    // start transcription job
    const transcribeResponse = await new Promise((resolve, reject) => {
      transcribeservice.startTranscriptionJob(transcribeParams, (err, res) => {
        if (err) reject(err);
        resolve(res);
      });
    });

    // Build the mongo transcription object
    if (transcribeResponse.TranscriptionJob) {
      transcription = new TranscriptionModel({
        body: null,
        user: {
          username: data.username,
          cleanspeakUuid: data.userUuid,
        },
        transcriptionName: transcribeResponse.TranscriptionJob.TranscriptionJobName,
        transcriptionStatus: 'IN_PROGRESS',
        parentType: data.contentType,
        parentId: data.id,
        contentUuid,
      });
    }

    // Validate against database model
    errs = transcription.validateSync();
    if (errs) {
      return createErrorResponse(400, errs.message || 'Invalid comment data');
    }

    // Save the transcription object to the database
    await db;
    await transcription.save();

    // return transcription response
    return {
      statusCode: 200,
      body: JSON.stringify(transcription),
    };
  } catch (error) {
    // Log the error
    log.error('startTranscriptionJob:Error processing request');
    log.error(error);

    // Return an error message to the client
    return createErrorResponse(
      error.statusCode || 500,
      error.message ||
        (error.body && error.body.errors[0].message) ||
        'Unknown error',
    );
  }
};
