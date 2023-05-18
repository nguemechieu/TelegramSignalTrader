//+------------------------------------------------------------------+
//|                                                 channel_post.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <DiscordTelegram/Entities.mqh>
#include <DiscordTelegram/Sender_chat.mqh>

#include <DiscordTelegram/Chat.mqh>

#include <DiscordTelegram/ccustomChat.mqh>
class Cchannel_post 
   {
public:
long message_id;
string author_signature;
Csender_chat sender_chat;
  //sender_chat params
Centities entities;
Cchat chat;




          Cchannel_post();~Cchannel_post();
                     
                     
                
                 
                    
                    
                    
  };


Cchannel_post::Cchannel_post(){}
Cchannel_post::~Cchannel_post(){}