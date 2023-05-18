//+------------------------------------------------------------------+
//|                                              HistoryPosition.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
#include <DoEasy/Engine.mqh>
class CHistoryPosition : public CEngine
  {
private:

public: string history(){return NULL;}


                     CHistoryPosition();
                    ~CHistoryPosition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryPosition::CHistoryPosition(void){





}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistoryPosition::~CHistoryPosition()
  {
  }
//+------------------------------------------------------------------+
