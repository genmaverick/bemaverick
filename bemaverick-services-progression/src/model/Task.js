const mongoose = require('mongoose');

const { Schema } = mongoose;

const TaskSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  key: {
    type: String,
    required: true,
  },
  labelText: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  pointsAwarded: {
    type: Number,
    required: true,
    default: 0,
  },
  repeatable: {
    type: Boolean,
    required: true,
    default: true,
  },
  // cooldownMax: {
  //   type: Number,
  //   required: false,
  //   default: 0,
  // },
  // cooldownSeconds: {
  //   type: Number,
  //   required: false,
  //   default: 0,
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
  model = mongoose.model('Task');
} catch (error) {
  model = mongoose.model('Task', TaskSchema);
}

module.exports = model;
