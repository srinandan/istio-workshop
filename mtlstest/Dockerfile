FROM ubuntu:bionic

RUN apt-get update && apt-get install -y gnupg curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Upgrade npm
RUN npm i npm@latest -g

# Create a sample app
RUN echo "var express = require('express');var app = express();app.get('/', function (req, res) {res.send('Hello World!');});app.listen(8080, function () {});" >> index.js
RUN echo "{\"name\": \"mtlstest\",\"version\": \"1.0.0\",\"main\": \"index.js\",\"scripts\": {\"start\": \"node index.js\"},\"dependencies\": {\"express\": \"^4.16.1\"}}" >> package.json
RUN npm install --save express
EXPOSE 8080
CMD [ "npm", "start" ]