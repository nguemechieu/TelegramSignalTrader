FROM ubuntu:latest

RUN apt-get  update

RUN apt-get install -y  wget
COPY TelegramSignalTrader.sh   TelegramSignalTrader.sh
RUN  chmod +x TelegramSignalTrader.sh
RUN ./TelegramSignalTrader.sh
#Default directory as follows
#Home directory\.mt4\drive_c\Program Files\MetaTrader 4