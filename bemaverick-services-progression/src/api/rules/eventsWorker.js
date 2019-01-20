const get = require('lodash/get');
const set = require('lodash/set');
const mongoose = require('mongoose');
const bluebird = require('bluebird');
const User = require('../../model/User');
const Task = require('../../model/Task');
const Project = require('../../model/Project');
const Level = require('../../model/Level');
const Reward = require('../../model/Reward');
const {
  getUserDetails: maverickGetUserDetails,
  convertClientToken,
} = require('../../lib/maverick');
const { maverick: maverickApi, lambda, mongoString } = require('../../config');
const { modifyOrPush, findNestedValue } = require('../../lib/utils');

const lambdaToken = lambda.key;
const clientAccessToken = maverickApi.accessToken;

// Configure mongoose client
mongoose.Promise = bluebird;
let clientDb = null;

exports.handler = async (event, context) => {
  set(context, 'callbackWaitsForEmptyEventLoop', false);
  // console.log("event: ", JSON.stringify(event));

  const body = JSON.parse(get(event, 'Records.0.body'));
  // console.log('body.Message', body.Message);

  // Open database connection
  console.log('🐲  get(clientDb, readyState)', get(clientDb, 'readyState'));
  if (!clientDb || get(clientDb, 'readyState') !== 1) {
    console.log('🐲  creating new clientDb connection');
    clientDb = await mongoose.connect(
      mongoString,
      { useMongoClient: true },
    );
  } else {
    console.log('🐲  loading clientDb from cache');
  }

  let message;
  try {
    message = JSON.parse(body.Message);
  } catch (e) {
    console.log('Error parsing json at body.Message', body.Message);
    return e;
  }
  console.log('🍌  message', message);

  /**
   * Load the v1 user details
   */
  let userDetailsV1 = get(message, 'data.user', null);
  if (!userDetailsV1) {
    try {
      const clientToken = await convertClientToken(clientAccessToken);
      const userId = get(message, 'userId');
      const userDetailsV1Response = await maverickGetUserDetails(clientToken, {
        userId,
        basic: 1,
      });
      userDetailsV1 = get(userDetailsV1Response, ['users', userId], null);
      // console.log('userDetailsV1', userDetailsV1);
    } catch (error) {
      console.log('⚽️  message', message);
      console.log('⚽️  Error loading v1 user details', get(error, 'body.errors', error));
      return null;
    }
  }

  /**
   * Create or Update the mongoose User object
   */
  const userId = get(message, 'userId');
  let user = await User.findOne({ userId });
  if (!user) {
    user = new User({ userId });
  }
  user.details = userDetailsV1;

  /**
   * Tasks: Load task
   */
  const eventType = get(message, 'eventType');
  const task = await Task.findOne({ key: eventType });
  if (task) {
    console.log('🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 ');
    console.log('🎏 task', task);
    console.log('🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 🎏 ');
  }

  /**
   * Tasks: Apply custom task rules
   */
  if (task) {
    const repeatable = get(task, 'repeatable', true);
    const tasksHistory = get(user, 'progression.tasksHistory', []);
    // Do not award any points for non-repeatable tasks
    if (
      !repeatable &&
      tasksHistory.some(taskHistory => get(task, '_id').toString() === get(taskHistory, 'task').toString())
    ) {
      console.log('🤺  non-repeatable task, return null');
      return null;
    }

    // Some tasks only get credit the first time
    console.log('🤺  task.key', task.key);
    if (['BADGE_RESPONSE', 'FOLLOW_USER'].includes(task.key)) {
      const { contentType, contentId } = message; // contentId undefined
      console.log('🤺  contentType', contentType);
      console.log('🤺  contentId', contentId);
      if (
        tasksHistory.some((taskHistory) => {
          const taskHistoryEventType = get(taskHistory, 'message.eventType');
          const taskHistoryContentType = get(taskHistory, 'message.contentType');
          const taskHistoryContentId = get(taskHistory, 'message.contentId');
          // console.log('🤺  taskHistoryContentId', taskHistoryContentId);
          return (
            eventType == taskHistoryEventType && // eslint-disable-line eqeqeq
            contentType == taskHistoryContentType && // eslint-disable-line eqeqeq
            contentId == taskHistoryContentId // eslint-disable-line eqeqeq
          );
        })
      ) {
        console.log(`🤺  cannot ${task.key} the same ${contentType} multiple times, return null`);
        return null;
      }
    }
  }

  /**
   * Tasks: Award points to user
   */
  const awards = [];
  if (task) {
    const points = get(task, 'pointsAwarded', 0);
    user.progression.totalPoints += points;
  }

  /**
   * Tasks: Update task count
   */
  if (task) {
    const tasksCount = get(user, 'progression.tasksCount', []);
    // console.log('BEFORE user.progression.tasksCount', user.progression.tasksCount);
    const count = get(
      // eslint-disable-next-line eqeqeq
      tasksCount.find(record => get(record, 'task').toString() == get(task, '_id').toString()),
      'count',
      0,
    );
    // console.log('💯 count', count);
    const newCount = {
      task: get(task, '_id'),
      taskName: get(task, 'name', null),
      taskKey: get(task, 'key', null),
      count: count + 1,
    };
    // TODO: debug duplicate entries... _id doesn't match,
    // probably because it is type ObjectId and not string
    user.progression.tasksCount = modifyOrPush(
      tasksCount,
      'task',
      get(task, '_id').toString(),
      newCount,
    );
    console.log('💯 newCount', newCount);
    // console.log('AFTER user.progression.tasksCount', user.progression.tasksCount);
  }

  /**
   * Add event task to User.tasksHistory history
   */
  if (task) {
    const taskHistory = {
      task: get(task, '_id', null),
      points: get(task, 'pointsAwarded', 0),
      // created: new Date(),
      messageId: get(body, 'MessageId'),
      message,
    };
    console.log('📝 taskHistory', taskHistory);
    user.progression.tasksHistory = user.progression.tasksHistory.concat([taskHistory]); // https://github.com/Automattic/mongoose/issues/4455#issuecomment-250404913
  }

  /**
   * Projects: Update progress
   */
  if (task) {
    const tasksCount = get(user, 'progression.tasksCount', []);
    const taskId = get(task, '_id', null);
    const projects = await Project.find({ task: taskId });
    let projectsProgress = get(user, 'progression.projectsProgress');
    // console.log('🗂 projects', projects);
    if (projects) {
      projects.forEach((project) => {
        const projectId = get(project, '_id').toString();
        const previousCompleted = findNestedValue(
          projectsProgress,
          'project',
          projectId,
          'completed',
          false,
        );
        const previousCompletedDate = findNestedValue(
          projectsProgress,
          'project',
          projectId,
          'completedDate',
          null,
        );
        const tasksRequired = get(project, 'tasksRequired', null);
        const tasksCompleted = Math.min(
          findNestedValue(tasksCount, 'task', taskId, 'count', 0),
          tasksRequired,
        );
        const progress = Math.max(0, (tasksCompleted / tasksRequired).toFixed(2));
        const completed = tasksCompleted >= tasksRequired;
        let completedDate = previousCompletedDate || null;
        console.log('🎾  project.name', project.name);
        console.log('🦒  completed', completed);
        console.log('🦒  previousCompleted', previousCompleted);
        console.log('🦒  completedDate', completedDate);
        console.log('🦒  previousCompletedDate', previousCompletedDate);
        if (completed && (!previousCompleted || !previousCompletedDate)) {
          /**
           * Project completed, add award and points
           */
          completedDate = new Date();
          // add project to awards array
          awards.push({
            type: 'project',
            project,
          });
          // add user points
          const pointsAwarded = get(project, 'pointsAwarded', 0);
          user.progression.totalPoints += pointsAwarded;
        }
        const projectProgress = {
          project: get(project, '_id'),
          projectName: get(project, 'name'),
          taskName: get(task, 'name'),
          tasksCompleted,
          tasksRequired,
          progress,
          completed,
          completedDate,
        };

        projectsProgress = modifyOrPush(
          projectsProgress,
          'project',
          get(project, '_id').toString(),
          projectProgress,
        );
        // console.log('📈 projectProgress', projectProgress);
      });
      // Add the updated projectsProgress back to the user object
      user.progression.projectsProgress = projectsProgress;
      // console.log('🗂  user.progression.projectsProgress', user.progression.projectsProgress);
    }
  }

  /**
   * Projects: Update all other projects
   */
  {
    const projects = await Project.find()
      .populate('task')
      .populate('recommendedLevel')
      .populate('projectPrerequisite');
    // console.log('🎾  projects', projects);
    let projectsProgress = get(user, 'progression.projectsProgress');
    // console.log('🎾  projectsProgress', projectsProgress);
    // console.log('🗂 projects', projects);
    if (projects) {
      projects.forEach((project) => {
        // const projectId = get(project, '_id').toString();

        let visibility = true;
        if (project.projectPrerequisite) {
          const prerequisiteCompleted = findNestedValue(
            projectsProgress,
            'project',
            get(project, 'projectPrerequisite._id'),
            'completed',
            false,
          );
          visibility = prerequisiteCompleted;
        }

        const defaultProjectProgress = {
          project: get(project, '_id'),
          projectName: get(project, 'name'),
          taskName: get(project, 'task.name'),
          tasksCompleted: 0,
          tasksRequired: get(project, 'tasksRequired'),
          progress: 0,
          completed: false,
          completedDate: null,
          visibility,
        };

        const projectProgress =
          projectsProgress.find(projectsProgressRecord =>
            get(projectsProgressRecord, 'project').toString() === get(project, '_id').toString()) || defaultProjectProgress;

        // Update fields
        projectProgress.visibility = visibility;
        projectProgress.projectPrerequisiteName = get(project, 'projectPrerequisite.name', null);

        projectsProgress = modifyOrPush(
          projectsProgress,
          'project',
          get(project, '_id').toString(),
          projectProgress,
        );
      });

      user.progression.projectsProgress = projectsProgress;
      // console.log('🎾  projectsProgress', projectsProgress);
    }
  }

  /**
   * Projects: Award completed
   */
  // TODO: test for awards.filter(award => award.type == 'project').length > 0
  // TODO: publish event via sockets

  /**
   * Levels: Update progress
   */
  const totalPoints = get(user, 'progression.totalPoints', 0);
  console.log('🛁 totalPoints', totalPoints);
  const levels = await Level.find().sort([['levelNumber', 1]]);
  // console.log('🛁 levels', levels);
  const currentLevelIndex =
    levels.length -
    levels
      .slice()
      .reverse()
      .findIndex(level => totalPoints > level.pointsRequired) -
    1;
  const currentLevel = levels[currentLevelIndex];
  // console.log('🛁 currentLevelIndex', currentLevelIndex);
  console.log('🛁 currentLevel', currentLevel);
  // console.log('🛁 minLevelNumber', minLevelNumber);
  // console.log('🛁 maxLevelNumber', maxLevelNumber);
  const currentLevelId = get(currentLevel, '_id', 'currentLevelString').toString();
  const userCurrentLevelId = get(
    user,
    'progression.currentLevel',
    'user.progression.currentLevel',
  ).toString();
  // console.log('🛁 currentLevelId', currentLevelId);
  // console.log('🛁 userCurrentLevelId', userCurrentLevelId);
  const previousLevel = currentLevelIndex > 0 ? get(levels, [currentLevelIndex - 1], null) : null;
  const nextLevel =
    currentLevelIndex < levels.length ? get(levels, [currentLevelIndex + 1], null) : null;

  // console.log('🛁 previousLevel', previousLevel);
  // console.log('🛁 currentLevel', currentLevel);
  // console.log('🛁 nextLevel', nextLevel);
  if (currentLevelId !== userCurrentLevelId) {
    // Update the current, previous, and next levels
    user.progression.currentLevel = get(currentLevel, '_id');
    user.progression.previousLevel = get(previousLevel, '_id');
    user.progression.nextLevel = get(nextLevel, '_id');
    // Add completed level to levelsProgress
    user.progression.levelsProgress = user.progression.levelsProgress.concat([
      {
        level: get(currentLevel, '_id'),
        levelNumber: get(currentLevel, 'levelNumber'),
        progress: 1,
        completed: true,
        completedDate: new Date(),
        pointsCompleted: totalPoints,
      },
    ]);
  }
  // Set the next level progress float
  const nextLevelProgress = nextLevel
    ? (
      (totalPoints - get(currentLevel, 'pointsRequired')) /
        (get(nextLevel, 'pointsRequired') - get(currentLevel, 'pointsRequired'))
    ).toFixed(2)
    : 1;
  user.progression.nextLevelProgress = nextLevelProgress;
  // Set the currentLevelNumber
  user.progression.currentLevelNumber = get(currentLevel, 'levelNumber');
  console.log('🛎  totalPoints', totalPoints);
  // console.log("🛎  get(currentLevel, 'pointsRequired')", get(currentLevel, 'pointsRequired'));
  // console.log("🛎  get(nextLevel, 'pointsRequired')", get(nextLevel, 'pointsRequired'));
  console.log('🛎  nextLevelProgress', nextLevelProgress);

  /**
   * Levels: Award completed
   */
  // TODO

  /**
   * Rewards: Award completed rewards based on level completed
   */
  // TODO
  const rewards = await Reward.find().populate({
    path: 'level',
    match: { levelNumber: { $lte: get(currentLevel, 'levelNumber', 0) } },
  });
  // console.log('🎀 rewards :: BEFORE', rewards);
  let rewardsProgress = get(user, 'progression.rewardsProgress');
  // console.log('🎀 rewardsProgress :: BEFORE', rewardsProgress);
  rewards.filter(reward => reward.level !== null).forEach((reward) => {
    const rewardProgress = {
      reward: get(reward, '_id'),
      rewardName: get(reward, 'name', null),
      rewardKey: get(reward, 'key', null),
      levelNumber: get(reward, 'level.levelNumber', null),
      completed: true,
      completedDate: new Date(),
    };
    // console.log('---- 🎀 rewardProgress', rewardProgress);
    rewardsProgress = modifyOrPush(
      rewardsProgress,
      'reward',
      get(reward, '_id').toString(),
      rewardProgress,
    );
  });
  console.log('🎀 rewardsProgress', rewardsProgress);
  user.progression.rewardsProgress = rewardsProgress;

  /**
   * Save the user object, log, and return
   */
  await user.save();
  const debugUser = user;
  debugUser.progression.tasksHistory = null;
  console.log('🛍  awards', awards);
  console.log('🐣  user.save()', debugUser);
  return null;
};
