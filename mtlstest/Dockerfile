FROM centos:latest
RUN yum clean all
RUN yum install net-tools which yum-utils yum-plugin-priorities sudo wget policycoreutils selinux-policy-targeted -y
RUN yum install epel-release -y
RUN yum install -y openssl
# adding nodejs just in case you want to write a quick app
RUN curl --silent --location https://rpm.nodesource.com/setup_9.x | sudo bash -
RUN yum install -y nodejs
RUN echo "var express = require('express');var app = express();app.get('/', function (req, res) {res.send('Hello World!');});app.listen(8080, function () {});" >> index.js
RUN echo "{\"name\": \"mtlstest\",\"version\": \"1.0.0\",\"main\": \"index.js\",\"scripts\": {\"start\": \"node index.js\"},\"dependencies\": {\"express\": \"^4.16.1\"}}" >> package.json
RUN npm install --save express
EXPOSE 8080
CMD [ "npm", "start" ]