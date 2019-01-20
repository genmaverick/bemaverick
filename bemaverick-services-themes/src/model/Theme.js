const mongoose = require('mongoose');
const fontsEnabled = require('./fontsEnabled');
const { isHexColor } = require('../lib/utils');

const { Schema } = mongoose;

const ThemeSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  backgroundImage: {
    type: String,
    required: true,
  },
  fontName: {
    type: String,
    required: true,
    enum: fontsEnabled,
    default: fontsEnabled[0],
  },
  backgroundColor: {
    type: String,
    required: true,
    validate: {
      validator(color) {
        return isHexColor(color);
      },
    },
  },
  fontColor: {
    type: String,
    required: true,
    validate: {
      validator(color) {
        return isHexColor(color);
      },
    },
  },
  textTransform: {
    type: String,
    required: false,
    enum: ['uppercase', 'lowercase', 'none'],
    default: 'none',
  },
  allowAlpha: {
    type: Boolean,
    required: false,
    default: true,
  },
  hasShadow: {
    type: Boolean,
    required: false,
    default: false,
  },
  availability: {
    premium: {
      type: Boolean,
      default: false,
    },
    minPosts: {
      type: Number,
      default: 0,
    },
    minBadges: {
      type: Number,
      default: 0,
    },
  },
  reward: {
    type: Schema.Types.ObjectId,
    ref: 'Reward',
  },
  sortOrder: {
    type: Number,
    required: false,
    default: 0,
  },
  active: {
    type: Boolean,
    default: true,
    index: true,
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
  backgroundImageFile: {
    type: Schema.Types.Mixed,
  },
  paddingTop: {
    type: Number,
    required: true,
    default: 12,
  },
  paddingRight: {
    type: Number,
    required: true,
    default: 12,
  },
  paddingBottom: {
    type: Number,
    required: true,
    default: 12,
  },
  paddingLeft: {
    type: Number,
    required: true,
    default: 12,
  },
  maxCharacters: {
    type: Number,
    required: true,
    default: 0,
  },
  maxFontSize: {
    type: Number,
    required: true,
    default: 38,
  },
  justification: {
    type: String,
    required: false,
    enum: ['left', 'center', 'right', 'justified'],
    default: 'center',
  },
});

// dynamic var maxCharacters : Int = 0
// dynamic var maxFontSize : Int = 38

let model;
try {
  model = mongoose.model('Theme');
} catch (error) {
  model = mongoose.model('Theme', ThemeSchema);
}

module.exports = model;
