# Run MetaTrader in a container.
#
# Copyright (c) 2022 tick <tickelton@gmail.com>
#
# SPDX-License-Identifier:     ISC
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

ADD https://dl.winehq.org/wine-builds/winehq.key /winehq.key

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Wine
RUN apt-get update && \
	apt-get install -y gnupg apt-utils && \
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

# Autorun MetaTrader Terminal.
ENTRYPOINT [ "wine" ]
CMD [ "/MetaTrader/terminal64.exe", "/portable" ]