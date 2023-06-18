# Run MetaTrader in a container.
#
# Copyright (c) 2023 tick <nguemechieu@live.com>
#
# SPDX-License-Identifier:     Apache2  license
#
# docker run \
#	--net host \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY \
#	-v $METATRADER_HOST_PATH:/MetaTrader \
#	--name mt \
#	tickelton/mt

# Base docker image.
FROM ubuntu:focal
RUN apt-get update
RUN      apt-get -y install wget
RUN apt-get upgrade -y
# Downloading meta-trader 4
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4ubuntu.sh ;
ADD https://dl.winehq.org/wine-builds/winehq.key /winehq.key

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Wine
RUN  apt-get install -y gnupg apt-utils && \
	echo "deb http://dl.winehq.org/wine-builds/ubuntu/ focal main" >> /etc/apt/sources.list && \
	apt-key add /winehq.key && \
	mv /winehq.key /usr/share/keyrings/winehq-archive.key && \
	dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install -y -q --install-recommends winehq-devel && \
	rm -rf /var/lib/apt/lists/* /winehq.key


# Add wine user.
# NOTE: You might need to change the UID/GID so the
# wine user has write access to your MetaTrader
# directory at $METATRADER_HOST_PATH.
RUN groupadd -g 1000 wine \
	&& useradd -g wine -u 1000 wine \
	&& mkdir -p /home/wine/.wine && chown -R wine:wine /home/wine

# Run MetaTrader as non privileged user.
USER wine

# MetaTrader 5 needs WINEARCH=win32.
# Not strictly necessary for MT4, but this
# way it works for both versions.
ENV WINEARCH win32
# Autorun MetaTrader Terminal.

RUN   chmod +x mt4ubuntu.sh ; ./mt4ubuntu.sh

#ENTRYPOINT [ "wine" ]
#CMD [ "/Program Files (x86)/FOREX.com US/terminal.exe", "/portable" ]
#Wine creates a separate virtual logical drive with the necessary environment for every installed program. The default path of the installed terminal data folder is as follows:
#
#Home directory\.mt4\drive_c\Program Files\MetaTrader 4
#

