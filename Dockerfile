FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ikifar"

# package versions
ARG UNIFI_VER="5.12.72"
ARG UNIFI_BRANCH="stable"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** add mongo repository ****" && \
 apt-get update && apt-get install -y gnupg2 wget && \
 wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add - && \
 echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	binutils \
	jsvc \
	mongodb-org-server \
	curl \
	libcap2 \
	apt-transport-https \
	openjdk-8-jre-headless && \
	
 echo "**** install unifi ****" && \
 if [ -z ${UNIFI_VER+x} ]; then \
 	UNIFI_VER=$(curl -sX GET http://dl-origin.ubnt.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages \
	|grep -A 7 -m 1 'Package: unifi' \
	| awk -F ': ' '/Version/{print $2;exit}' \
	| awk -F '-' '{print $1}'); \
 fi && \
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
