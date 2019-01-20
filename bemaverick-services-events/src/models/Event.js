const mongoose = require("mongoose");

const { Schema } = mongoose;

const EventSchema = new Schema({
  eventType: {
    type: String,
    required: true
  },
  contentType: {
    type: String
  },
  contentId: {
    type: String
  },
  userId: {
    type: String
  },
  data: {
    type: Schema.Types.Mixed
  },
  created: {
    type: Date,
    required: true,
    default: Date.now
  }
}); // , { safe: { w: 'majority', wtimeout: 10000 } },

EventSchema.index({ userId: 1 });
// EventSchema.index({ userId: 1, contentType: 1, contentId: 1 });

let model;
try {
  model = mongoose.model("Event");
} catch (error) {
  model = mongoose.model("Event", EventSchema);
}

module.exports = model;
