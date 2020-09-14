FROM node:latest

RUN mkdir -p /usr/src/app
RUN mkdir -p /usr/src/app/appinsights-statsd
COPY . /usr/src/app/appinsights-statsd

WORKDIR /usr/src/app

# Install python
# RUN apk add --no-cache --update g++ gcc libgcc libstdc++ linux-headers make python

# Install dependencies
# COPY package.json /usr/src/app/
# clone statsd repo to folder "statsd", in statsd to npm install appinsights-statsd from up-level folder
RUN git clone https://github.com/statsd/statsd.git
RUN cd statsd\
    && npm install /usr/src/app/appinsights-statsd\
    && npm install && npm cache clean --force\
    && echo "\
    {\n\
        backends: ['appinsights-statsd'], \n\
        aiInstrumentationKey: process.env.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY,\n\ 
        aiPrefix: 'airflow2', \n\
        aiTrackStatsDMetrics: true,\n\
        log:{\n\
            backend: 'syslog'\n\
        }\n\
    } "\
    >> ./config.js

# Expose required ports
EXPOSE 8125/udp
EXPOSE 8126

# Start statsd with application insights backend
ENTRYPOINT [ "node", "statsd/stats.js", "statsd/config.js" ]
