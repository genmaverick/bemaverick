const routes = require('next-routes')();

routes
  .add('/', 'Homepage/index')
  .add('/about', 'AboutPage')
  .add('/challenge/:challengeId', 'ChallengeDetailsPage')
  .add('/careers', '/Careers/index')
  .add('/community-guidelines', '/CommunityGuidelines/index')
  .add('/contact', '/ContactPage/index')
  .add('/copyright', '/CopyrightPage/index')
  .add('/faq', '/FaqPage/index')
  .add('/get-started', 'GetStartedPage/index')
  .add('/homepage', 'Homepage/index')
  .add('/pages/:slug', 'CmsPages/index')
  .add('/posts/:slug', 'CmsPosts/post')
  .add('/privacy-policy', 'PrivacyPolicy/index')
  .add('/response/:responseId', 'ResponseDetailsPage')
  .add('/shared-signin', 'NotLoggedInPage/index')
  .add('/sign-in', 'SigninPage/index')
  .add('/sign-up', 'SignupPage/index')
  .add('/support-resources', 'SupportResources/index')
  .add('/terms-of-service', 'TermsOfServicePage/index')
  .add('/third-party-operators', 'ThirdPartyOperators/index');

module.exports = routes;
