//+------------------------------------------------------------------+
//|                                                      message.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Object.mqh>


#include <DiscordTelegram/entities.mqh>
#include <DiscordTelegram/from.mqh>

#include <DiscordTelegram/sender_chat.mqh>

#include <DiscordTelegram/channel_post.mqh>


#include <DiscordTelegram/Discord.mqh>
#include <DiscordTelegram/Chat.mqh>
#include <DiscordTelegram/ccustomChat.mqh>
#include <DiscordTelegram/from_chat forward_from_chat.mqh>



class Cmessage  
  {

   public: Cfrom *from; 
    Centities entities;
   private: bool ok;
  public:  Csender_chat *sender_chat;
   CCustomChat *chat;
    string author_signature;
    datetime date;


    Cforward_from_chat *forward_from_chat;
   long forward_from_message_id;
    string forward_signature;
    bool is_automatic_forward;
    datetime forward_date;
    string text;


string from_first_name;
void setFrom_first_name(string from_first_name1){this .from_first_name=from_first_name1;}
string getFrom_first_name(){return from_first_name;};
   
   




    public : Cmessage( Cfrom &from1, Centities &entities1, bool ok1, Csender_chat &sender_chat1, CCustomChat &chat1,
     string &author_signature1, datetime &date1, Cforward_from_chat &forward_from_chat1,
     int forward_from_message_id1, string forward_signature1, bool is_automatic_forward1, datetime forward_date1, string text1) {
        this.from = from1;
        this.entities = entities1;
        this.ok = ok1;
        this.sender_chat = sender_chat1;
        this.chat = chat1;
        this.author_signature = author_signature1;
        this.date = date1;
        this.forward_from_chat = forward_from_chat1;
        this.forward_from_message_id = forward_from_message_id1;
        this.forward_signature = forward_signature1;
        this.is_automatic_forward = is_automatic_forward1;
        this.forward_date = forward_date1;
        this.text = text1;
    }

 

    public :void setFrom(Cfrom &from1) {
        this.from = from1;
    }

   
    public :void setEntities(Centities &entities1) {
        this.entities = entities1;
    }

    public :bool getOk() {
        return ok;
    }

    public :void setOk(bool ok1) {
        this.ok = ok1;
    }

    public: string getSender_chat() {
        return sender_chat.toString();
    }

    public :void setSender_chat(Csender_chat &sender_chat1) {
        this.sender_chat = sender_chat1;
    }


    public :string getAuthor_signature() {
        return author_signature;
    }

    public :void setAuthor_signature(string author_signature1) {
        this.author_signature = author_signature1;
    }

    datetime getDate() {
        return date;
    }

     void setDate(datetime date1) {
        this.date = date1;
    }


    public :long getForward_from_message_id() {
        return forward_from_message_id;
    }

    public: void setForward_from_message_id(long forward_from_message_id1) {
        this.forward_from_message_id = forward_from_message_id1;
    }

    public :string getForward_signature() {
        return forward_signature;
    }

    public :void setForward_signature(string forward_signature1) {
        this.forward_signature = forward_signature1;
    }

    public: bool getIs_automatic_forward() {
        return is_automatic_forward;
    }

    
    
    public :void setIs_automatic_forward(bool is_automatic_forward1) {
        this.is_automatic_forward = is_automatic_forward1;
    }

    public: datetime getForward_date() {
        return forward_date;
    }

    public :void setForward_date(datetime forward_date1) {
        this.forward_date = forward_date1;
    }

    public :string getText() {
        return text;
    }

    public :void setText(string text1) {
        this.text = text1;
    }

Cmessage(){};~Cmessage();


};

Cmessage::~Cmessage(){}

