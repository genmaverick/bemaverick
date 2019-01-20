// /**
//  * Levels
//  */
module.exports.createLevel = require('./api/levels/createLevel');
module.exports.listLevels = require('./api/levels/listLevels');
module.exports.getLevel = require('./api/levels/getLevel');
module.exports.updateLevel = require('./api/levels/updateLevel');
module.exports.deleteLevel = require('./api/levels/deleteLevel');

// /**
//  * Projects
//  */
module.exports.createProject = require('./api/projects/createProject');
module.exports.listProjects = require('./api/projects/listProjects');
module.exports.getProject = require('./api/projects/getProject');
module.exports.updateProject = require('./api/projects/updateProject');
module.exports.deleteProject = require('./api/projects/deleteProject');

// /**
//  * Rewards
//  */
module.exports.createReward = require('./api/rewards/createReward');
module.exports.listRewards = require('./api/rewards/listRewards');
module.exports.getReward = require('./api/rewards/getReward');
module.exports.updateReward = require('./api/rewards/updateReward');
module.exports.deleteReward = require('./api/rewards/deleteReward');

// /**
//  * Tasks
//  */
module.exports.createTask = require('./api/tasks/createTask');
module.exports.listTasks = require('./api/tasks/listTasks');
module.exports.getTask = require('./api/tasks/getTask');
module.exports.updateTask = require('./api/tasks/updateTask');
module.exports.deleteTask = require('./api/tasks/deleteTask');

/**
 * Users
 */
// module.exports.getUser = require('./api/users/getUser');
module.exports.getUser = require('./api/users/getUserNoCache');
