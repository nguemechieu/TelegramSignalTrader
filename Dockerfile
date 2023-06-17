FROM ubuntu:latest


RUN dpkg --add-architecture i386
RUN mkdir -pm755 /etc/apt/keyrings
RUN  apt-get update \
    && apt-get install wget unzip zip -y
RUN wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/kinetic/winehq-kinetic.sources
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-staging
RUN wine /path/to/application.exe

CMD ["run","wine.exe"]
EXPOSE 8080

#Default directory as follows
#Home directory\.mt4\drive_c\Program Files\MetaTrader 4