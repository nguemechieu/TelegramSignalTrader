//+------------------------------------------------------------------+
//|                                                    Indicator.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict

#include <DiscordTelegram/Object.mqh>
class CIndicator : public CObject
  {
             private:

    public :ENUMS_TIMEFRAMES getTimeFrame() {
        return timeFrame;
    }

    public :void setTimeFrame(ENUMS_TIMEFRAMES timeFrame) {
        this.timeFrame = timeFrame;
    }

    public :string getSymbol() {
        return symbol;
    }

    public: void setSymbol(string symbol) {
        this.symbol = symbol;
    }

    public :int getShift() {
        return shift;
    }

    public :void setShift(int shift) {
        this.shift = shift;
    }

    public : string getIndicatorName() {
        return indicatorName;
    }

    public :void setIndicatorName(string indicatorName) {
        this.indicatorName = indicatorName;
    }

    public :int getSignal() {
        return signal;
    }

    public: void setSignal(int signal) {
        this.signal = signal;
    }

    ENUMS_TIMEFRAMES timeFrame;
    string symbol;
    int shift;
    string indicatorName;
    int signal;        ~CIndicator();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicator::CIndicator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicator::~CIndicator()
  {
  }
//+------------------------------------------------------------------+
