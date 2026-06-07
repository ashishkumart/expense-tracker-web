FROM node:20-alpine

WORKDIR /usr/src/app

# Install nodemon globally for hot-reloading code changes
RUN npm install -g nodemon

COPY package*.json ./
RUN npm install

# In development, we don't COPY the rest of the code here.
# Docker Compose will mount your local folder dynamically instead.

EXPOSE 5000

CMD ["nodemon", "server.js"]