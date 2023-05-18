//+------------------------------------------------------------------+
//|                                                customMessage.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
  

#include <DiscordTelegram/channel_post.mqh>

#include <DiscordTelegram/Message.mqh>
class CCustomMessage  :public Cmessage
{
public:
 int    chat_id;
    string            chat_first_name;
    string            chat_last_name;
    string            chat_username;
    string            chat_type;
    //---
    datetime          message_date;
    string            message_text;

   bool             done;
    int             update_id;
    int message_id;
    //---
    int             from_id;
    string            from_first_name;
    string            from_last_name;
    string            from_username;
   
 

    public: bool getDone() {
        return done;
    }

    public: void setDone(bool done1) {
        this.done = done1;
    }

    public: int getUpdate_id() {
        return update_id;
    }

    public :void setUpdate_id(int update_id1) {
        this.update_id = update_id1;
    }

    public: int getMessage_id() {
        return message_id;
    }

    public :void setMessage_id(int message_id1) {
        this.message_id = message_id1;
    }

    public: int getFrom_id() {
        return from_id;
    }

    public :void setFrom_id(int from_id1) {
        this.from_id = from_id1;
    }

    public: string getFrom_first_name() {
        return from_first_name;
    }

    public: void setFrom_first_name(string from_first_name1) {
        this.from_first_name = from_first_name1;
    }

    public: string getFrom_last_name() {
        return from_last_name;
    }

    public :void setFrom_last_name(string from_last_name1) {
        this.from_last_name = from_last_name1;
    }

    public: string getFrom_username() {
        return from_username;
    }

    public: void setFrom_username(string from_username1) {
        this.from_username = from_username1;
    }

    public :int getChat_id() {
        return chat_id;
    }

    public: void setChat_id(int chat_id1) {
        this.chat_id = chat_id1;
    }

    public: string getChat_first_name() {
        return chat_first_name;
    }

    public: void setChat_first_name(string chat_first_name1) {
        this.chat_first_name = chat_first_name1;
    }

    public: string getChat_last_name() {
        return chat_last_name;
    }

    public: void setChat_last_name(string chat_last_name1) {
        this.chat_last_name = chat_last_name1;
    }

    public :string getChat_username() {
        return chat_username;
    }

    public :void setChat_username(string chat_username1) {
        this.chat_username = chat_username1;
    }

    public :string getChat_type() {
        return chat_type;
    }

    public: void setChat_type(string chat_type1) {
        this.chat_type = chat_type1;
    }

    public: datetime getMessage_date() {
        return message_date;
    }

    public :void setMessage_date(datetime message_date1) {
        this.message_date = message_date1;
    }

    public :string getMessage_text() {
        return message_text;
    }

    public :void setMessage_text(string message_text1) {
        this.message_text = message_text1;
    }

    //---
   


CCustomMessage();~CCustomMessage(){}
};
CCustomMessage::CCustomMessage(){}
