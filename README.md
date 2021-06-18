
[![Build Status](https://img.shields.io/docker/cloud/build/emergn/monit)](https://hub.docker.com/r/emergn/monit)
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/emergn/monit)](https://hub.docker.com/r/emergn/monit)
[![Docker Image Size](https://img.shields.io/docker/image-size/emergn/monit/latest)](https://hub.docker.com/r/emergn/monit)


# Monit - Docker/Kubernetes - UNIX Systems Management

Run Monit inside Docker. **"Monit. Barking at daemons"**

[![Monit](https://mmonit.com/monit/img/logo.png)](https://mmonit.com/monit/)

[Monit](https://mmonit.com/monit/) is a free open source utility for managing and monitoring, processes, programs, files, directories and filesystems on a UNIX system. Monit conducts automatic maintenance and repair and can execute meaningful causal actions in error situations.

## Supported architectures

- amd64
- [arm32v6 (Raspberry Pi)](https://hub.docker.com/r/diogopms/monit-docker-kubernetes/tags?page=1&name=arm)

## Docker setup

Install docker: https://docs.docker.com/engine/installation/
Install docker compose: https://docs.docker.com/compose/install/
Docker documentation: https://docs.docker.com/

### Build-in docker image

- build docker image `docker build -t monit .`
- start monit: `docker run -ti -p 2812:2812 -v $(pwd)/monitrc:/etc/monitrc monit`

## ENV VARS


| ENVs            	| Description                                              	|
|-----------------	|----------------------------------------------------------	|
| TELEGRAM_BOT_TOKEN| Token for Telegram Bot messaging                         	|
| TELEGRAM_CHAT_ID  | Telegram chat id to send messages to                      |
| TEAMS_WEBHOOK_URL | MS Teams webhook url                                      |
| SLACK_URL       	| Webhook url for slack notifications (required for slack) 	|
| SLACK_URL       	| Webhook url for slack notifications (required for slack) 	|
| PUSH_OVER_TOKEN 	| Push over api token (required for pushover)              	|
| PUSH_OVER_USER  	| Push over api user (requiredfor pushover)                	|
| DEBUG           	| If set with 1 it will put monit in verbose mode          	|

### Docker Hub image

- pull docker image from docker hub: `docker pull emergn/monit`
- start monit: `docker run -ti -p 2812:2812 -v $(pwd)/monitrc:/etc/monitrc emergn/monit`
- create a docker container:

```
#Normal mode (with telegram messaging)
docker run -it \
  -p 2812:2812 \
  -v $(pwd)/monitrc:/etc/monitrc \
  -e "TELEGRAM_BOT_TOKEN=187255489:AAKllsbl22h-x8kkdsgokgsyJJLfhjdKJHY" \
  -e "TELEGRAM_CHAT_ID=882675873" \
  emergn/monit

#Debug mode
docker run -it \
  -p 2812:2812 \
  -v $(pwd)/monitrc:/etc/monitrc \
  -e "TELEGRAM_BOT_TOKEN=187255489:AAKllsbl22h-x8kkdsgokgsyJJLfhjdKJHY" \
  -e "TELEGRAM_CHAT_ID=882675873" \
  -e "DEBUG=1" \
  emergn/monit
```
*TELEGRAM_BOT_TOKEN* and *TELEGRAM_CHAT_ID* are fakes here, of course ;-)

### Example monitrc (Teams and Telegram)

```
set daemon 20
set log syslog
# Web interface
# set httpd port 2812 and allow admin:monit

check host www.google.com with address www.google.com
  if failed
      port 443 protocol https
      request /
      status = 200
      for 2 cycles
  then exec "/bin/bash -c 'teams ALERT! Google is not responding! && telegram ALERT! This is the end of the world!'" repeat every 2 cycles
EOF
```


### Example monitrc (Slack)

```
set daemon 20
set log syslog
# Web interface
# set httpd port 2812 and allow admin:monit

check host www.google.com with address www.google.com
  if failed
      port 443 protocol https
      request /
      status = 200
      for 2 cycles
  then exec "/bin/slack"
    else if succeeded then exec "/bin/slack"
EOF
```



### Supported notifications

- [Telegram](https://core.telegram.org/bots/api)
- [MS Teams](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using)
- [Slack](https://www.slack.com)
- [Pushover](https://pushover.net)

### Troubleshooting

If when starting Monit returns the following message: `The control file '/etc/monitrc' permission 0755 is wrong, maximum 0700 allowed`, simply give the appropriate permissions to _monitrc_: `chmod 700 monitrc`.
