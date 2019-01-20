const mongoose = require('mongoose');
const validator = require('validator');

const Schema = mongoose.Schema;

const CommentSchema = new Schema({
  body: {
    type: String,
    required: true,
  },
  originalBody: {
    type: String,
    required: false,
  },
  hashtags: [
    {
      type: String,
    },
  ],
  userId: {
    type: Number,
    required: true,
    validate: {
      validator(userId) {
        return Number.isInteger(userId);
      },
    },
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
  status: {
    type: String,
    required: true,
    enum: ['active', 'reported', 'deleted'],
    default: 'active',
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
  flagged: {
    type: Boolean,
    default: false,
  },
  active: {
    type: Boolean,
    default: true,
  },
  meta: {
    mentions: [
      {
        userId: {
          type: String,
          required: true,
          validate: {
            validator(userId) {
              return validator.isAlphanumeric(userId);
            },
          },
        },
        username: {
          type: String,
          required: true,
          validate: {
            validator(username) {
              // eslint-disable-line no-unused-vars
              // return validator.isAlphanumeric(username);
              return true; // TODO: check for is alphanumeric AND allow underscores/dashes
            },
          },
        },
      },
    ],
    user: {
      type: mongoose.Schema.Types.Mixed,
    },
    twilio: {
      type: mongoose.Schema.Types.Mixed,
    },
    cleanspeak: {
      type: mongoose.Schema.Types.Mixed,
    },
    flags: {
      type: mongoose.Schema.Types.Mixed,
    },
  },
});

CommentSchema.index({ parentType: 1, parentId: 1 }, { unique: false });

let model;
try {
  model = mongoose.model('Comment');
} catch (error) {
  model = mongoose.model('Comment', CommentSchema);
}

module.exports = model;
