//+------------------------------------------------------------------+
//|                                                     Position.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict

#include <DoEasy/Engine.mqh>
class CPosition :public CMarketPosition
  {
private:
CMarketPosition Position;
public:
                     CPosition();
                    ~CPosition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::CPosition()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::~CPosition()
  {
  }
//+------------------------------------------------------------------+
