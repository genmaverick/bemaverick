const mongoose = require('mongoose');

const { Schema } = mongoose;

const ProjectSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  requirementDescription: {
    type: String,
  },
  achievedDescription: {
    type: String,
  },
  achievedDescriptionSecondary: {
    type: String,
  },
  task: {
    type: Schema.Types.ObjectId,
    ref: 'Task',
    required: true,
  },
  tasksRequired: {
    type: Number,
    required: true,
    default: 1,
  },
  recommendedLevel: {
    type: Schema.Types.ObjectId,
    ref: 'Level',
  },
  projectPrerequisite: {
    type: Schema.Types.ObjectId,
  },
  projectGroup: {
    type: String,
  },
  pointsAwarded: {
    type: Number,
    required: true,
    default: 0,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  color: {
    type: String,
    default: '#AFEEEE',
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
  model = mongoose.model('Project');
} catch (error) {
  model = mongoose.model('Project', ProjectSchema);
}

module.exports = model;
