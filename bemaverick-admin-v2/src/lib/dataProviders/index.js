const defaultDataProvider = require('./defaultDataProvider').default;
const themesDataProvider = require('./themesDataProvider').default;
const commentsDataProvider = require('./commentsDataProvider').default;
const rewardsDataProvider = require('./rewardsDataProvider').default;

const dataProvider = (type, resource, params) => {
  // console.log('Default Provider', defaultDataProvider);
  console.log("-- Data Provider --");
  console.log("type:", type);
  console.log("resource:", resource);
  console.log("params:", params);

  switch (resource) {
    case 'themes': {
      console.log("themes provider");
      return themesDataProvider(type, resource, params);
    }
    case 'comments': {
      console.log("comments provider");
      return commentsDataProvider(type, resource, params);
    }
    case 'rewards': {
      console.log("rewards provider");
      return rewardsDataProvider(type, resource, params);
    }
    default:
    console.log("default provider");
      return defaultDataProvider(type, resource, params);
  }
}

export default dataProvider;
