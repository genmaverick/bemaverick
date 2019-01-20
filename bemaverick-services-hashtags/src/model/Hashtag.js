const mongoose = require('mongoose');

const { Schema } = mongoose;

const HashtagSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  contentType: {
    type: String,
    required: true,
    enum: ['user', 'challenge', 'response', 'comment'],
  },
  contentId: {
    type: String,
    required: true,
  },
  contentField: {
    type: String,
    required: false,
  },
  challenge: {
    type: Schema.Types.Mixed,
    required: false,
  },
  user: {
    type: Schema.Types.Mixed,
    required: false,
  },
  response: {
    type: Schema.Types.Mixed,
    required: false,
  },
  comment: {
    type: Schema.Types.Mixed,
    required: false,
  },
  active: {
    type: Boolean,
    default: true,
  },
  hideFromStreams: {
    type: Boolean,
    default: false,
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
}); // , { safe: { w: 'majority', wtimeout: 10000 } },

HashtagSchema.index({ contentType: 1, contentId: 1 });
HashtagSchema.index({ contentType: 1, contentId: 1, name: 1 });

let model;
try {
  model = mongoose.model('Hashtag');
} catch (error) {
  model = mongoose.model('Hashtag', HashtagSchema);
}

module.exports = model;
