const mongoose = require('mongoose');

const { Schema } = mongoose;

const TrophySchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  created: {
    type: Date,
    required: true,
    default: Date.now,
  },
});

let model;
try {
  model = mongoose.model('Trophy');
} catch (error) {
  model = mongoose.model('Trophy', TrophySchema);
}

module.exports = model;
