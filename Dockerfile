FROM goldeneggg/hubot-irc

MAINTAINER 17number

# set hubot irc environment
# HUBOT_IRC_SERVER and HUBOT_IRC_ROOMS must be indicated by `docker run -e ...`
ENV HUBOT_IRC_NICK relaybot
ENV HUBOT_IRC_UNFLOOD true
ENV HUBOT_IRC_SERVER=<IRC SERVER IP ADDR>
ENV HUBOT_IRC_ROOMS="#ircroom1,#ircroom2"
# ENV http_proxy=http://proxyuser:proxypw@your.proxy.com:<proxyport>/
# ENV no_proxy="localhost,127.0.0.1,172.17.0.1"


# install pkgs
WORKDIR /root/mybot
RUN set -x && \
    npm install request --save && \
    npm install iconv --save && \
    npm install

# HTTP Listener listen port 9980
ENV PORT 9980
EXPOSE 9980

ADD ircforward.coffee /root/mybot/scripts/ircforward.coffee

# run redis-server and hubot("-a irc")
EXPOSE 6379
RUN /etc/init.d/redis-server start
ENTRYPOINT ["bin/hubot", "-a", "irc"]
CMD ["--name", "ircbot"]

