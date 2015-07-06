FROM debian:wheezy
MAINTAINER Shane Starcher <shanestarcher@gmail.com>

RUN apt-get update && apt-get install -y wget ca-certificates && apt-get -y clean
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

RUN \
	apt-get update && \
    apt-get install -y sensu && \
    apt-get -y clean


ENV PATH /opt/sensu/embedded/bin:$PATH

#Nokogiri is needed by aws plugins
RUN \
	apt-get update && \
    apt-get install -y libxml2 libxml2-dev libxslt1-dev zlib1g-dev build-essential  && \
    gem install nokogiri && \
    apt-get remove -y libxml2-dev libxslt1-dev zlib1g-dev && \
    apt-get autoremove -y && \
    apt-get -y clean


RUN wget https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.0.2.tar.gz

ENV DEFAULT_PLUGINS_REPO sensu-plugins

ADD templates /etc/sensu/templates
ADD bin /bin/

#Plugins needed for handlers
RUN /bin/install slack mailer

#Plugins needed for checks and maybe handlers
RUN /bin/install docker http

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

#Client Config
ENV CLIENT_SUBSCRIPTIONS all,default

#Common Config
ENV RUNTIME_INSTALL ''
ENV LOG_LEVEL warn
ENV EMBEDDED_RUBY true
ENV CONFIG_FILE /etc/sensu/config.json
ENV CONFIG_DIR /etc/sensu/conf.d
ENV EXTENSION_DIR /etc/sensu/extensions
ENV PLUGINS_DIR /etc/sensu/plugins
ENV HANDLERS_DIR /etc/sensu/handlers

ENTRYPOINT ["/bin/start"]
