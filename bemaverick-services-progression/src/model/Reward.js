const mongoose = require('mongoose');

const { Schema } = mongoose;

// Reward model is also in bemaverick-services-themes - update both if editing
// todo: put models in a shared project
const RewardSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  key: { // FEATURE_COVER_PHOTO_EDITOR
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  level: {
    type: Schema.Types.ObjectId,
    ref: 'Level',
    required: true,
    default: '5ba5592380c2072fbfd70aec',
  },
  // trigger: {
  //   type: String,
  //   enum: ['manual', 'level', 'project', 'any'],
  //   required: true,
  //   default: 'level',
  // },
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
  model = mongoose.model('Reward');
} catch (error) {
  model = mongoose.model('Reward', RewardSchema);
}

module.exports = model;
