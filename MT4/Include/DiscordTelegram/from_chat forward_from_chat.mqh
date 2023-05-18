//+------------------------------------------------------------------+
//|                                            forward_from_chat.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
class Cforward_from_chat
  {
public:
int id; 
string title;
string username;
string type;

                     Cforward_from_chat();
                    ~Cforward_from_chat();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Cforward_from_chat::Cforward_from_chat()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Cforward_from_chat::~Cforward_from_chat()
  {
  }
//+------------------------------------------------------------------+
