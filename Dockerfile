# Using "Big" base image for Docker-in-Docker commands:
FROM ubuntu:bionic-20210512

LABEL maintainer="Matthias Weyerhaeuser <public@weyerhaeuser.de>"

# monit environment variables
ENV MONIT_VERSION=5.33.0 \
    MONIT_HOME=/opt/monit \
    MONIT_URL=https://mmonit.com/monit/dist \
    PATH=$PATH:/opt/monit/bin

COPY slack /bin/slack
COPY pushover /bin/pushover
COPY telegram /bin/telegram
COPY teams /bin/teams
COPY mqtt /bin/mqtt

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install wget curl

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
# Compile and install monit
RUN \
    apt-get -y install gcc musl-dev make bash python3 curl libssl-dev file zlib1g-dev ca-certificates && \
    mkdir -p /opt/src; cd /opt/src && \
    wget -qO- ${MONIT_URL}/monit-${MONIT_VERSION}.tar.gz | tar xz && \
    cd /opt/src/monit-${MONIT_VERSION} && \
    ./configure --prefix=${MONIT_HOME} --without-pam && \
    make && make install

EXPOSE 2812

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["/entrypoint.sh"]

CMD ["monit", "-I", "-B", "-c", "/etc/monitrc_root"]
