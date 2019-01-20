const mongoose = require('mongoose');

const { Schema } = mongoose;

const LevelSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  levelNumber: {
    type: Number,
    required: true,
    unique: true,
    index: true,
  },
  description: {
    type: String,
  },
  pointsRequired: {
    type: Number,
    required: true,
  },
  nextLevel: {
    type: Schema.Types.ObjectId,
  },
  levelProgressionSuggestion: {
    type: String,
    required: false,
  },
  levelRewards: {
    type: String,
    required: false,
  },
  active: {
    type: Boolean,
    required: true,
    default: true,
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
});

let model;
try {
  model = mongoose.model('Level');
} catch (error) {
  model = mongoose.model('Level', LevelSchema);
}

module.exports = model;

/**
    id: 'iueh-2765',
    levelNumber: 1,
    pointsRequired: 100,
    color: '#980000',
    name: 'Beginner',
 */
