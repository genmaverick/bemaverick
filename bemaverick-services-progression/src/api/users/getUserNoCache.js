const mongoose = require('mongoose');
const bluebird = require('bluebird');
const get = require('lodash/get');
const set = require('lodash/set');
const UserModel = require('../../model/User');
const { createErrorResponse, createJsonResponse } = require('../../lib/utils');
const { mongoString, maverick: maverickApi } = require('../../config');
const {
  // validateToken,
  convertClientToken,
  getUserDetails: maverickGetUserDetails,
} = require('../../lib/maverick');
const { getDefaultLevels, getDefaultProjectsProgress } = require('../../lib/progression');

const clientAccessToken = maverickApi.accessToken;

// Configure mongoose client
mongoose.Promise = bluebird;
// mongoose.Logger.setLevel('error');
let clientDb = null;

// eslint-disable-next-line no-unused-vars
module.exports = async (event, context) => {
  // set(context, 'callbackWaitsForEmptyEventLoop', false);

  // Validate key
  // const token = event.headers.Token || event.headers.Authorization || null;
  // validateToken(token);

  try {
    // Open database connection
    console.log('🐲  creating new clientDb connection');
    clientDb = await mongoose.connect(
      mongoString,
      { useMongoClient: true },
    );
    // console.log('🐲  clientDb', clientDb);

    // const filter = { _id: event.pathParameters.id };
    const filter = { userId: event.pathParameters.id };
    console.log('🦋  filter', filter);
    const tasksHistory = get(event, 'queryStringParameters.tasksHistory', 0) ? 1 : 0;
    const projection = { 'progression.tasksHistory': tasksHistory };
    const users = await UserModel.find(filter, projection)
      .populate('progression.previousLevel')
      .populate('progression.currentLevel')
      .populate('progression.nextLevel')
      .populate('progression.tasksCount.task')
      .populate('progression.levelsProgress.level')
      .populate('progression.projectsProgress.project')
      .populate('progression.rewardsProgress.reward');

    if (!users || users.length < 1) {
      // Save user before populating

      console.log('🦋  user not found');
      // lookup v1 user, build progression user, populate projects
      const clientToken = await convertClientToken(clientAccessToken);
      const userId = event.pathParameters.id;
      console.log('🦋  userId', userId);
      const userDetailsV1Response = await maverickGetUserDetails(clientToken, {
        userId,
        basic: '1',
      });
      // console.log('🦋  userDetailsV1Response', userDetailsV1Response);
      const userDetailsV1 = get(userDetailsV1Response, ['users', userId], null);
      // console.log('🦋  userDetailsV1', userDetailsV1);
      if (!userDetailsV1) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      // create the new user object
      let user = new UserModel({ userId });
      user = await user.save(); // Save early to prevent multiple creations

      // populate v1 api user details and progression defaults
      user.details = userDetailsV1;
      const defaultLevels = await getDefaultLevels();
      const defaultProjectsProgress = await getDefaultProjectsProgress();
      user.progression = {
        currentLevelNumber: get(defaultLevels, 'currentLevel.levelNumber', 0),
        ...defaultLevels,
        projectsProgress: defaultProjectsProgress,
      };
      user = await user.save();
      user = await user
        .populate('progression.previousLevel')
        .populate('progression.currentLevel')
        .populate('progression.nextLevel')
        .populate('progression.projectsProgress.project');

      console.log('🦋  new user', user);
      mongoose.connection.close();
      return createJsonResponse({ body: user });
    }

    console.log('🦋  found users[0]', users[0]);
    mongoose.connection.close();
    return createJsonResponse({ body: users[0] }); // return the first matching user
  } catch (error) {
    // Log the error
    console.error('error', error.body || error);

    // Return an error message to the client
    mongoose.connection.close();
    return createErrorResponse(
      error.statusCode || 500,
      error.message || (error.body && error.body.errors[0].message) || 'Unknown error',
    );
  }
};
