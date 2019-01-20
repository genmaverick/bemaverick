/* eslint-disable no-underscore-dangle */
const log = require('lambda-log');
const mongoose = require('mongoose');
const bluebird = require('bluebird');
const Parallel = require('async-parallel');
const axios = require('axios');
const AWS = require('aws-sdk');
const { mongoString } = require('../config');
const TranscriptionModel = require('../model/Transcription');
const { createErrorResponse } = require('../lib/utils');
const { updateResponseTranscription } = require('../lib/maverick');

mongoose.Promise = bluebird;

const _getTranscriptionJob = (service, name) =>
  new Promise((resolve, reject) => {
    service.getTranscriptionJob({ TranscriptionJobName: name }, (err, data) => {
      if (err) console.log('ERR', err);
      if (err) reject(err);
      else resolve(data);
    });
  });

module.exports = async (event, context) => {
  try {
    const response = {};
    const db = mongoose.connect(mongoString).connection;

    // get 'IN_PROGRESS' transcriptions from mongodb
    const filter = {
      transcriptionStatus: { $eq: 'IN_PROGRESS' },
    };

    const mongoTranscriptions = await TranscriptionModel.find(filter);

    // start aws transcribe service
    AWS.config.loadFromPath('./src/lib/awsConfig.json');
    const transcribeService = new AWS.TranscribeService();

    // for each mongodb transcription with the status of IN_PROGRESS
    const awsTranscriptionJobs = await Parallel.map(mongoTranscriptions, async (mongoTranscription) => {
      await Parallel.sleep(500);

      // get AWS transcription job with mongo transcriptionName
      const { TranscriptionJob: job } = await _getTranscriptionJob(
        transcribeService,
        mongoTranscription.transcriptionName,
      );

      console.log('AWS JOB', job);

      // vars to update sql and mongodb with
      let transcriptionText;
      let transcriptionStatus;

      // if AWS transcription job status is COMPLETED on amazon transcribe
      // get transcription text and update sql transcription text
      if (job.TranscriptionJobStatus === 'COMPLETED') {
        const transcriptFile = await axios.get(job.Transcript.TranscriptFileUri);
        transcriptionText = transcriptFile.data.results.transcripts[0].transcript || '';

        if (!transcriptionText) {
          transcriptionStatus = 'NO_TEXT';
        }

        // update sql database via php api
        const updateResponse = await updateResponseTranscription(mongoTranscription.parentId, transcriptionText);

        // if update is sucessful, mongodb transcriptionStatus can be marked as completed
        if (updateResponse && updateResponse.status === 'success') {
          transcriptionStatus = 'COMPLETED';
        } else if (updateResponse && updateResponse.status === 'failure') {
          transcriptionStatus = 'FAILED_SQL';
        } else {
          transcriptionStatus = 'IN_PROGRESS';
        }
      }

      // if AWS transcription job status is FAILED on amazon transcribe, set mongodb transcriptionStatus
      if (job.TranscriptionJobStatus === 'FAILURE') {
        transcriptionStatus = 'FAILED_AWS';
      }

      // update mongodb if AWS transcription job status is COMPLETED or FAILED
      if (job.TranscriptionJobStatus === 'COMPLETED' || job.TranscriptionJobStatus === 'FAILED') {
        const updatedTranscription = await TranscriptionModel.findOneAndUpdate(
          { _id: mongoTranscription._id },
          {
            $set: {
              transcriptionStatus,
              transcriptionText,
            },
          },
          { new: true },
        );

        // return updated mongodb object
        return { updatedTranscription };
      }

      return null;
    }, 1);

    response.awsTranscriptionJobs = awsTranscriptionJobs;
    response.completedJobs = await Promise.all(awsTranscriptionJobs);

    // close the database
    db.close();

    // return transcribe response
    return {
      statusCode: 200,
      body: JSON.stringify(response),
    };
  } catch (error) {
    // Log the error
    log.error('transcribeCron: Error processing request', error);

    // Return an error message to the client
    return createErrorResponse(
      error.statusCode || 500,
      error.message || (error.body && error.body.errors[0].message) || 'Unknown error',
    );
  }
};
