/* eslint-disable no-underscore-dangle, no-undef */
export const env = typeof window !== 'undefined' ? window.__ENV__ : process.env;

export default {
  maverickApi: {
    url: env.MAVERICK_API_URL || 'https://dev-api.bemaverick.com/v1',
    clientId: env.MAVERICK_API_CLIENT_ID || 'bemaverick_ios',
    clientSecret: env.MAVERICK_API_CLIENT_SECRET || '8NFnps4makvxWcyF4qZL2Nw',
    appKey: env.MAVERICK_API_APP_KEY || 'testKey',
  },
  maverickBranch: {
    key: env.MAVERICK_BRANCH_KEY || 'key_test_lizP6vq88cyTfTeD7RUnHmeaDseBmwts',
  },
  maverickCms: {
    url: env.MAVERICK_CMS_URL || 'https://cms.genmaverick.com/wp-json/wp/v2',
  },
  maverickLeanplum: {
    appId: env.MAVERICK_LEANPLUM_APP_ID || 'app_0SPllvo97hhhTnIDUhOdGD5LSwOZQ519gBpej6zfYfs',
    clientKey:
      env.MAVERICK_LEANPLUM_CLIENT_KEY || 'dev_rXKEJHEZUA4vUVXkbntCphQ4I7pZikvinGl57IEYNc4',
  },
  maverickSegment: {
    key: env.MAVERICK_SEGMENT_KEY || '6x8BdaJK8Odj5SJR2wPhtayegTnqHctK',
  },
  maverickSiteImages: {
    url: env.MAVERICK_AWS_IMAGES_URL || 'https://cdn.genmaverick.com',
  },
};

// url: 'http://chrisfitkin-api-bemaverick.local.slytrunk.com/v1',
