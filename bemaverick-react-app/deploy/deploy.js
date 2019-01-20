/* eslint-disable no-console */
/* eslint-disable import/no-extraneous-dependencies */
const remoteExec = require('remote-exec');
const fs = require('fs');

require('dotenv').config();

const settings = {
  deploy: {
    host: process.env.DEPLOY_HOST.split(',') || [],
    dir: process.env.DEPLOY_DIR || '/home/bemaverick/files/maverick-company-website',
  },
};

// see documentation for the ssh2 npm package for a list of all options
const options = {
  port: 22,
  username: process.env.DEPLOY_USERNAME || null,
  promptForPass: false,
};
if (process.env.DEPLOY_PRIVATE_KEY) {
  options.privateKey = fs.readFileSync(process.env.DEPLOY_PRIVATE_KEY);
}

const { host } = settings.deploy;

const commands = [
  `cd ${settings.deploy.dir}`,
  'pwd',
  'git status',
  'git reset --hard origin/master',
  'sudo docker-compose build',
  'sudo docker-compose up --force-recreate -d',
].join(';');

console.log('----- DEPLOY -----');
console.log('host: ', host);
console.log('options: ', { ...options, privateKey: '***********' });
console.log('commands: ', commands);
console.log('');

remoteExec(host, commands, options, (err) => {
  if (err) {
    console.log('Deployment error:');
    console.log(err);
    process.exit(1);
  } else {
    console.log('Deployed successful!!');
  }
});
