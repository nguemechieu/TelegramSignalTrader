FROM ubuntu:latest
RUN echo "INSTALLATION OF wine"
RUN apt-get update
RUN apt-get  upgrade -y

RUN apt-get install -y build-essential

RUN apt-get install -y wget

RUN  wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4ubuntu.sh
RUN    chmod +x mt4ubuntu.sh
RUN    ./mt4ubuntu.sh



#Default directory as follows
#Home directory\.mt4\drive_c\Program Files\MetaTrader 4