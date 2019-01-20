const mongoose = require('mongoose');

const { Schema } = mongoose;

const UserSchema = new Schema({
  userId: { type: String, required: true, index: true },
  progression: {
    currentLevel: { type: Schema.Types.ObjectId, ref: 'Level' },
    nextLevel: { type: Schema.Types.ObjectId, ref: 'Level' },
    previousLevel: { type: Schema.Types.ObjectId, ref: 'Level' },
    nextLevelProgress: { type: Number, default: 0 },
    currentLevelNumber: { type: Number },
    totalPoints: { type: Number, default: 0 },
    projectsProgress: [
      {
        project: { type: Schema.Types.ObjectId, ref: 'Project' },
        projectName: { type: String },
        projectPrerequisiteName: { type: String },
        taskName: { type: String },
        tasksCompleted: { type: Number, default: 0 },
        tasksRequired: { type: Number },
        progress: { type: Number, default: 0 },
        completed: { type: Boolean, default: false },
        completedDate: { type: Date },
        visibility: { type: Boolean, default: true },
      },
    ],
    levelsProgress: [
      {
        level: { type: Schema.Types.ObjectId, ref: 'Level' },
        pointsCompleted: { type: Number },
        levelNumber: { type: Number },
        progress: { type: Number, default: 0 },
        completed: { type: Boolean, default: false },
        completedDate: { type: Date },
      },
    ],
    rewardsProgress: [
      {
        reward: { type: Schema.Types.ObjectId, ref: 'Reward' },
        rewardName: { type: String },
        rewardKey: { type: String },
        levelNumber: { type: Number },
        completed: { type: Boolean, default: false },
        completedDate: { type: Date },
      },
    ],
    tasksHistory: [
      {
        task: { type: Schema.Types.ObjectId, ref: 'Task' },
        points: { type: Number },
        created: { type: Date },
        messageId: { type: String },
        message: { type: Schema.Types.Mixed },
      },
    ],
    tasksCount: [
      {
        task: { type: Schema.Types.ObjectId, ref: 'Task' },
        count: { type: Number },
        taskName: { type: String },
        taskKey: { type: String },
      },
    ],
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
  details: { type: Schema.Types.Mixed },
});

// UserSchema.index({ userId: 1 }); // schema level

let model;
try {
  model = mongoose.model('User');
} catch (error) {
  model = mongoose.model('User', UserSchema);
}

module.exports = model;

/*
  const user = {
      _id: 'iwbn-2787',
      userId,
      progression: {
        currentLevelNumber: 1,
        nextLevelNumber: 2,
        nextLevelProgress: 0.5,
        totalPoints: 250,
        projectsProgress: [
          {
            project: {
              _id: '1',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/badger.png',
              name: 'SPREAD THE LOVE',
              taskType: 'badge',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 15,
              reward: 200,
              color: 'FBD5D8',
              requirementDescription: 'Badge 15 Responses',
              projectAchievedDescription:
                "You're a super badger always supporting your fellow Mavericks by awarding their challenge responses with badges!",
              projectAchievedDescription2: 'We need more friends like you in this world!',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 15,
            progress: 1,
            completed: true,
            dateCompleted: 1536613852,
          },
          {
            project: {
              _id: '2',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/profile.png',
              name: 'ALL ABOUT ME',
              taskType: 'complete_profile',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 1,
              reward: 400,
              color: 'DECBC6',
              requirementDescription: 'Complete your profile',
              projectAchievedDescription: 'You are comfortable letting the world know about you!',
              projectAchievedDescription2: 'Way to trust others',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 0,
            progress: 0,
            completed: false,
          },
          {
            project: {
              _id: '3',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/follow.png',
              name: 'SUPER FAN',
              taskType: 'follow',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 10,
              reward: 150,
              color: 'A5D6D8',
              requirementDescription: 'Follow 10 Users',
              projectAchievedDescription: 'You are a super social butterfly',
              projectAchievedDescription2: 'Keep it up and follow everyone!',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 5,
            progress: 0.5,
            completed: false,
          },
          {
            project: {
              _id: '4',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/comment.png',
              name: 'CHEERLEADER',
              taskType: 'comment',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 20,
              reward: 300,
              color: 'FBD5D8',
              requirementDescription: 'Comment on 20 Posts',
              projectAchievedDescription: 'You love to comment and leave your opinion everywhere',
              projectAchievedDescription2:
                'Remember to finnish speaking before your audience has finnished listening',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 15,
            progress: 0.75,
            completed: false,
          },
          {
            project: {
              _id: '5',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/respond.png',
              name: 'SPEAK MY MIND',
              taskType: 'respond',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 5,
              reward: 600,
              color: 'F5D8C3',
              requirementDescription: 'Respond to 5 Challenges',
              projectAchievedDescription:
                'You love answering the call and respond to all the Challenges',
              projectAchievedDescription2: 'Have you tried a video response yet?',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 5,
            progress: 1,
            completed: true,
            dateCompleted: 1536613852,
          },
          {
            project: {
              _id: '6',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/challenger.png',
              name: 'CONVERSATION STARTER',
              taskType: 'challenge',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 7,
              reward: 700,
              color: 'BFD3E6',
              requirementDescription: 'Create 7 Challenges',
              projectAchievedDescription: 'You Challenge the rest of the world to do your bidding',
              projectAchievedDescription2: 'Try now to get some responses to those Challenges',
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 1,
            progress: 0.14,
            completed: false,
          },
          {
            project: {
              _id: '7',
              imageUrl:
                'https://s3.amazonaws.com/bemaverick-website-images/app/projects/mention.png',
              name: 'TEAM CAPTAIN',
              taskType: 'mention',
              task: {
                name: 'A Task',
                unitText: 'things',
                key: 'A_TASK',
                description: 'This is the task description',
                pointsAwarded: 1,
              },
              tasksRequired: 12,
              reward: 1000,
              color: 'FCB9B5',
              requirementDescription: 'Mention 12 different users',
              projectAchievedDescription:
                'You make sure people are noticing you by mentioning them in Challenges and comments',
              projectAchievedDescription2: "Don't worry, we're sure that isn't annoying",
              groupWeight: 0,
              group: {
                _id: 'fnks-2749',
                name: 'Responses',
              },
            },
            tasksCompeleted: 11,
            progress: 0.917,
            completed: true,
            dateCompleted: 1536613852,
          },
        ],
        levelsProgress: [
          {
            level: {
              _id: 'iueh-2765',
              levelNumber: 1,
              pointsRequired: 100,
              color: '#980000',
              name: 'Beginner',
            },
            pointsCompleted: 100,
            dateCompleted: 1536613852,
            progress: 1,
          },
          {
            level: {
              _id: 'fhdrt-2346',
              levelNumber: 2,
              pointsRequired: 500,
              color: '#ff0000',
              name: 'Trend Setter',
            },
            pointsCompleted: 250,
            dateCompleted: null,
            progress: 0.5,
          },
        ],
        rewards: [],
      },
    };
    */
