const get = require('lodash/get');
const Level = require('../model/Level');
const Project = require('../model/Project');

module.exports.getDefaultLevels = async () => {
  const levels = await Level.find().sort([['levelNumber', 1]]);
  return { currentLevel: levels[0], nextLevel: levels[1] };
};

module.exports.getDefaultProjectsProgress = async () => {
  const projects = await Project.find()
    .populate('task')
    .populate('recommendedLevel')
    .populate('projectPrerequisite');

  // console.log('🐙  getDefaultProjectsProgress.projects', projects);

  return projects.map(project => ({
    project: get(project, '_id'),
    projectName: get(project, 'name'),
    taskName: get(project, 'task.name'),
    tasksCompleted: 0,
    tasksRequired: get(project, 'tasksRequired'),
    progress: 0,
    completed: false,
    completedDate: null,
    visibility: !get(project, 'projectPrerequisite'),
  }));
};
