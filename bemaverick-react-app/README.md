# Maverick Company Website

## Download & Run
```sh
git clone https://github.com/BeMaverickCo/maverick-company-website/
npm install
npm run dev
```
## Production Build
```sh
npm install
npm run build
npm start
```

## Docker
```sh
docker-compose build
docker-compose up # -d
```

## Deployment
```sh
npm run deploy
```
\* Requires the following environment variables set in the command line or `.env` file
  * DEPLOY_DIR
  * DEPLOY_HOST
  * DEPLOY_USERNAME
  * DEPLOY_PRIVATE_KEY (path to file)

\** Requires an existing copy of this git repo checkout out in the `DEPLOY_DIR`

\*** Requires `docker-engine` and `docker-compose` installed on the remote machine
> https://docs.docker.com/install/linux/docker-ce/debian/#prerequisites

## References
* Next.js: [next.js](https://github.com/zeit/next.js/), [new in next.js 5](https://zeit.co/blog/next5), [plugins](https://github.com/zeit/next-plugins), [next-redux-wrapper](https://github.com/zeit/next.js/tree/canary/examples/with-redux-wrapper)
* React Flexbox Grid: [react-flexbox-grid](https://github.com/roylee0704/react-flexbox-grid), [example](http://roylee0704.github.io/react-flexbox-grid/), [grid reference](https://stackoverflow.com/questions/43445592/what-is-the-meaning-of-xs-md-lg-in-css-flexbox-system)
* React-Responsive: [react-responsive](https://github.com/contra/react-responsive)
* Material-Ui: [material-ui](http://www.material-ui.com/#/): 
* Moment.js: [documentation](http://momentjs.com/docs/#/parsing/string-format/)
