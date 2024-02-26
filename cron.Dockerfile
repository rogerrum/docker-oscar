FROM ubuntu

#RUN apk add --no-cache bash

RUN  apt-get update \
  && apt-get install -y grep sed wget \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir app && mkdir -p /config/SDCARD/

WORKDIR app


COPY root/etc/s6-overlay/s6-rc.d/ez-share-cron/ezShareDownloader.sh .
RUN chmod +x ezShareDownloader.sh

ENTRYPOINT ./ezShareDownloader.sh
