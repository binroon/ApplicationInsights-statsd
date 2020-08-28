FROM node:latest

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install python
# RUN apk add --no-cache --update g++ gcc libgcc libstdc++ linux-headers make python

# Setup node envs
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

# Install dependencies
# COPY package.json /usr/src/app/
# clone statsd repo to folder "statsd", in statsd to npm install appinsights-statsd from up-level folder
RUN git clone https://github.com/statsd/statsd.git
RUN cd statsd\
    && npm install && npm cache clean --force\
    && npm install https://github.com/binroon/ApplicationInsights-statsd.git\
    && npm install && npm cache clean --force\
    && echo "\
    {\
        backends: ['appinsights-statsd'], \
        aiInstrumentationKey: '${NODE_ENV}',\ 
        aiPrefix: 'airflow', \
        aiTrackStatsDMetrics: true \
        } "\
    >> ./config.js

# Copy required src (see .dockerignore)
# COPY ./statsd /usr/src/app

# Expose required ports
EXPOSE 8125/udp
EXPOSE 8126

# Start statsd with application insights backend
ENTRYPOINT [ "node", "statsd/stats.js", "statsd/config.js" ]
