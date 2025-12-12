FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT

ARG OSCAR_VERSION=1.7.0

RUN printf '%s' "Building for TARGETPLATFORM=${TARGETPLATFORM}" \
    && printf '%s' ", TARGETARCH=${TARGETARCH}" \
    && printf '%s' ", TARGETVARIANT=${TARGETVARIANT} \n"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget cron

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
        wget -q -O /tmp/oscar.deb https://www.apneaboard.com/OSCAR/${OSCAR_VERSION}/oscar_${OSCAR_VERSION}-RasPiOS-12_arm64.deb; \
    else \
        wget -q -O /tmp/oscar.deb https://www.apneaboard.com/OSCAR/${OSCAR_VERSION}/oscar_${OSCAR_VERSION}-Debian12_amd64.deb; \
    fi

RUN apt install -y /tmp/oscar.deb && \
    rm /tmp/oscar.deb && \
    rm -rf /var/lib/apt/lists

#RUN apk add --no-cache firefox
COPY /root /

# ports and volumes
EXPOSE 3000
