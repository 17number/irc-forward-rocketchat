# irc-forward-rocketchat
Forwarding IRC messages to Rocket.Chat by hubot. Hubot is running on docker container.

## How to work
### Clone git reporitory.
```bash
$ git clone https://github.com/17number/irc-forward-rocketchat.git
```
### Edit files
Change directory.
```
$ cd irc-forward-rocketchat
```
Edit `Dockerfile` and `ircforward.coffee`.

### Build and run docker contianer.
```
$ docker build --tag=irc-forward-hubot . 
$ docker run -t -d irc-forward-hubot
```
