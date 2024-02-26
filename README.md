# Docker Image for Open Source CPAP Analysis Reporter (OSCAR)

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/rogerrum/docker-oscar)](https://hub.docker.com/r/rogerrum/docker-oscar/tags)
[![license](https://img.shields.io/github/license/rogerrum/docker-oscar)](https://github.com/rogerrum/docker-oscar/blob/main/LICENSE)
[![DockerHub pulls](https://img.shields.io/docker/pulls/rogerrum/docker-oscar.svg)](https://hub.docker.com/r/rogerrum/docker-oscar/)
[![DockerHub stars](https://img.shields.io/docker/stars/rogerrum/docker-oscar.svg)](https://hub.docker.com/r/rogerrum/docker-oscar/)
[![GitHub stars](https://img.shields.io/github/stars/rogerrum/docker-oscar.svg)](https://github.com/rogerrum/docker-oscar)
[![Contributors](https://img.shields.io/github/contributors/rogerrum/docker-oscar.svg)](https://github.com/rogerrum/docker-oscar/graphs/contributors)
[![Docker Image CI](https://github.com/rogerrum/docker-oscar/actions/workflows/docker-image.yml/badge.svg)](https://github.com/rogerrum/docker-oscar/actions/workflows/docker-image.yml)


A Docker image for **[OSCAR](https://www.sleepfiles.com/OSCAR/)** to run inside Docker container and access it remotely using web browser.


Repository name in Docker Hub: **[rogerrum/docker-oscar](https://hub.docker.com/r/rogerrum/docker-oscar/)**  
Published via **automated build** mechanism  

![img.png](https://raw.githubusercontent.com/rogerrum/docker-oscar/main/.github/demo-img.png)


## Docker Run
To simply do a quick and dirty run of the Oscar container:
```
docker run \
    -d --rm \
    --name oscar \
    -v=${pwd}/oscar-data:/config/Documents/OSCAR_Data \
    -v=${pwd}/SDCARD:/config/SDCARD \
    --publish=8080:8080 \
     rogerrum/docker-oscar
  
```
To stop the container simply run:
```
$ docker stop oscar
```
To remove the container simply run:
```
$ docker rm oscar
```

## Docker Compose
If you don't want to type out these long **Docker** commands, you could
optionally use [docker-compose](https://docs.docker.com/compose/) to set up your
image. Just download the repo and run it like so:

```yaml
version: '3.8'
services:
  oscar:
    image: rogerrum/docker-oscar:latest
    container_name: oscar
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - ./oscar-data:/config/Documents/OSCAR_Data:rw
      - ./SDCARD:/config/SDCARD:rw
    environment:
      TZ: "America/Chicago"
```

To start the container run:
```
$ docker-compose up -d
```

## Automatic configuration for downloading SD card data using ezSahre (Optional) 

The docker image contains additional cronjob that pulls files from an [ezShare](https://www.aliexpress.us/item/3256805687404143.html) wifi SD card adpater.

### Steps for EZShare data cron

- [ezShare](https://www.aliexpress.us/item/3256805687404143.html) wifi SD adapter and an SD card, be sure to chose the combo for around $24! Configured and installed in your CPAP machine
- USB wifi adapter or Raspberry PI connected with wired and wifi (I use raspberry pi 3 which is connected using wired and using wifi to connect to ezShare)

### Steps for configuring Wifi if connected using Wired for network and wifi for ezshare
edit file `sudo vi /etc/netplan/50-cloud-init.yaml` 

Add following lines under `network`

```
    wifis:
        wlan0:
            optional: true
            access-points:
                "ezShareSSD":
                    password: "ezShare-PASSORD"
            dhcp4: true
```
Save and then
```
sudo netplan --debug try
sudo netplan --debug generate
sudo netplan --debug apply
```

and finally reboot

```
$ sudo reboot
```
When its back up you should be able to SSH in and ping 192.168.4.1 which is the ezShare card.


```yaml
version: '3.8'
services:
  oscar:
    image: rogerrum/docker-oscar:latest
    container_name: oscar
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - ./oscar-data:/config/Documents/OSCAR_Data:rw
      - ./SDCARD:/config/SDCARD:rw
    environment:
      TZ: "America/Chicago"
      CRON_HOUR: 11
      CRON_MIN: 00
```

To start the container run:
```
$ docker-compose up -d
```
cron job is created only when env CRON_HOUR and CRON_MIN are passed.

### Additional Docker image for transferring data (Used as Kube Cron Job)

Repository name in Docker Hub: **[rogerrum/docker-oscar-cron](https://hub.docker.com/r/rogerrum/docker-oscar-cron/)**

Repository name in ghcr.io: **[rogerrum/docker-oscar-cron](https://ghcr.io/rogerrum/docker-oscar-cron)**

## Issues
https://github.com/rogerrum/docker-oscar/issues

## Contribute
* I am happy for any feedback! Create issues, discussions, ... feel free and involve!
* Send me a PR

## Contributors
EzShare-SdcardWifi-Downloader script by [Biorn1950](https://github.com/Biorn1950) --- https://github.com/Biorn1950/EzShare-SdcardWifi-Downloader

Software Licensing Information
------------------------------
DOCKER-OSCAR is released under the GNU GPL v3 License. Please see below for a note on giving correct attribution
in redistribution of derivatives.

It is built using Qt SDK (Open Source Edition), available from http://qt.io.

Redistribution of derivatives ( a note added by Mark Watins )
-----------------------------
Mark Watkins created this software to help lessen the exploitation of others. Seeing his work being used to exploit others
is incredibly un-motivational, and incredibly disrespectful of all the work he put into this project.

If you plan on reselling any derivatives of SleepyHead, I specifically request that you give due credit and
link back, mentioning clearly in your advertising material, software installer and about screens that your
derivative "is based on the free and open-source software SleepyHead available from http://sleepyhead.jedimark.net,
developed and copyright by Mark Watkins (C) 2011-2018."

It is not enough to reference that your derivative "is based on GPL software".
