FROM node:8.11.1
# FROM node:carbon

# setup Supervisor
RUN apt-get update && apt-get install -y supervisor

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . .

# NextJS Build
RUN npm run build

# Start the app
EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# CMD [ "npm", "run", "dev" ]
# CMD [ "npm", "start" ]