FROM alpine

RUN apk add --no-cache bash

RUN mkdir app && mkdir -p /config/SDCARD/

WORKDIR app


COPY root/etc/s6-overlay/s6-rc.d/ez-share-cron/ezShareDownloader.sh .
RUN chmod +x ezShareDownloader.sh

ENTRYPOINT ./ezShareDownloader.sh
