FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ikifar"

# package versions
ARG UNIFI_VER="5.10.20"

# environment settings
# ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** add mongo repository ****" && \
#  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 68818C72E52529D4 && \
 echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
 apt-get update && \
 apt install gnupg -y \
 apt-get install -y \
	binutils \
	jsvc \
	mongodb-org \
	openjdk-8-jre-headless \
	wget && \
 echo "**** install unifi ****" && \
 curl -o \
 /tmp/unifi.deb -L \
	"http://dl.ubnt.com/unifi/${UNIFI_VER}/unifi_sysvinit_all.deb" && \
 dpkg -i /tmp/unifi.deb && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
