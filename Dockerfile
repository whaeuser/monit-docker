FROM alpine:3.13.5

LABEL maintainer="Dmitrijs Zaharovs <dima@zaharov.info>"

# monit environment variables
ENV MONIT_VERSION=5.28.0 \
    MONIT_HOME=/opt/monit \
    MONIT_URL=https://mmonit.com/monit/dist \
    PATH=$PATH:/opt/monit/bin

COPY slack /bin/slack
COPY pushover /bin/pushover
COPY telegram /bin/telegram
COPY checkmssql /bin/checkmssql
COPY checkmssqlad /bin/checkmssqlad

# Support for MSSQL requests: Installing mssql-tools #########
ARG MSSODBCSQL_VERSION=17.7.2.1-1
ARG MSSQLTOOLS_VERSION=17.7.1.1-1

USER root

RUN set -x \
  && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
  && apk update \
  && apk add --update curl \
   && tempDir="$(mktemp -d)" \
  && chown nobody:nobody $tempDir \
  && cd $tempDir \
  && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSODBCSQL_VERSION}_amd64.apk" \
  && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQLTOOLS_VERSION}_amd64.apk" \
  && apk add --allow-untrusted msodbcsql17_${MSSODBCSQL_VERSION}_amd64.apk \
  && apk add --allow-untrusted mssql-tools_${MSSQLTOOLS_VERSION}_amd64.apk \
  && rm -rf $tempDir \
  && rm -rf /var/cache/apk/*
#############################################################


# Compile and install monit
RUN \
    apk add --update gcc musl-dev make bash python3 curl libressl-dev file zlib-dev ca-certificates && \
    mkdir -p /opt/src; cd /opt/src && \
    wget -qO- ${MONIT_URL}/monit-${MONIT_VERSION}.tar.gz | tar xz && \
    cd /opt/src/monit-${MONIT_VERSION} && \
    ./configure --prefix=${MONIT_HOME} --without-pam && \
    make && make install && \
    apk del gcc musl-dev make file zlib-dev && \
    rm -rf /var/cache/apk/* /opt/src

EXPOSE 2812

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["/entrypoint.sh"]

CMD ["monit", "-I", "-B", "-c", "/etc/monitrc_root"]
