//+------------------------------------------------------------------+
//|                                                  TradeSignal.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
#include <Object.mqh>
#include <DiscordTelegram/TradeExpert_Variables.mqh>
class CTradeSignal : public CObject
  {
private:
 string indicatorName;ENUMS_TIMEFRAMES timeframe0; string commentx;int shift;int shiftx0; string symbol;
public:        CTradeSignal(){};
  
     string getIndicatorName() {
        return indicatorName;
    }

    void setIndicatorName(string indicatorName1) {
        this.indicatorName = indicatorName1;
    }

   ENUMS_TIMEFRAMES getTimeframe() {
        return timeframe0;
    }

   void setTimeframe(ENUMS_TIMEFRAMES timeframe1) {
        this.timeframe0 = timeframe1;
    }

    string getCommentx() {
        return commentx;
    }

  void setCommentx(string comment1c) {
        this.commentx = comment1c;
    }

  int getShift() {
        return shift;
    }

    void setShift(int shift1) {
        this.shift = shift1;
    }

     int getShiftx0() {
        return shiftx0;
    }

   void setShiftx0(int shiftx1) {
        this.shiftx0 = shiftx1;
    }

    string getSymbol() {
        return symbol;
    }

   void setSymbol(string symbol1) {
        this.symbol = symbol1;
    }
                    
                          
  int TradeSignal(  string indicatorNames,ENUMS_TIMEFRAMES timeframe,  string commentx1, int shiftn,int shiftx1, string symbol1){
  bool alignx=InpAlign;
  ;int signalx=0;
  
   int buyx=(int)iCustom(symbol1,timeframe,indicatorNames,0,shiftn);
  
  int sellx=(int)iCustom(symbol1,timeframe,indicatorNames,1,shiftx1);
  
   if(alignx)
     {
      if(buyx== 1 && sellx==-1)
        {
         signalx= 1;commentx="BUY SIGNAL";
        }
        else
      if(buyx == -1 && sellx==1)
        {
       signalx= -1;commentx1="SELL SIGNAL";
        }

        

     }
   else
     {
  
     
      if(buyx == 1)
        {
         signalx= 1;commentx1="BUY SIGNAL";
        }
      if(sellx == -1)
        {
        signalx= -1;
        
        commentx="SELL SIGNAL";}
        }
   
return signalx;
}
               
                    
                    
                    
                    
                    
  };
  


//+------------------------------------------------------------------+
