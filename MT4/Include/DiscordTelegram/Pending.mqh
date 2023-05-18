//+------------------------------------------------------------------+
//|                                                      Pending.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
class COrder
  {
private:
int groupTotal;
datetime time;
public:
double GroupTotal(){ 

return groupTotal;}
void setTimeSetUp(datetime timex){this.time=timex;}
datetime GetTimeSetUp(){return time;

}
                     CPending();
                    ~CPending();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPending::CPending()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPending::~CPending()
  {
  }
//+------------------------------------------------------------------+
