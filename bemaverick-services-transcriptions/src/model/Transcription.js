const mongoose = require('mongoose');
const validator = require('validator');

const Schema = mongoose.Schema; // eslint-disable-line

const TranscriptionSchema = new Schema({
  body: {
    type: String,
    required: false,
    default: null,
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
  transcriptionName: {
    type: String,
    required: false,
  },
  transcriptionStatus: {
    type: String,
    required: true,
    enum: ['IN_PROGRESS', 'COMPLETED', 'NO_TEXT', 'FAILED', 'FAILED_AWS', 'FAILED_SQL'],
  },
  transcriptionText: {
    type: String,
    default: null,
  },
  parentType: {
    type: String,
    required: true,
    validate: {
      validator(parentType) {
        return validator.isAlphanumeric(parentType);
      },
    },
  },
  parentId: {
    type: String,
    required: true,
    validate: {
      validator(parentId) {
        return validator.isAlphanumeric(parentId);
      },
    },
  },
  user: {
    username: {
      type: String,
      required: true,
    },
    cleanspeakUuid: {
      type: mongoose.Schema.Types.Mixed,
    },
  },
  contentUuid: {
    type: mongoose.Schema.Types.Mixed,
  },
}, { collection: 'transcriptions' });

TranscriptionSchema.index({ parentType: 1, parentId: 1 }, { unique: false });

let model;
try {
  model = mongoose.model('Transcription');
} catch (error) {
  model = mongoose.model('Transcription', TranscriptionSchema);
}

module.exports = model;
