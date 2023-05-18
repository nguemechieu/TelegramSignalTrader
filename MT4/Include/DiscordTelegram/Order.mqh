//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <DiscordTelegram/Comment.mqh>
class COrder
  {

  //public constructor
    public: COrder( double orderDistance1, datetime expiration1, double volume1, ENUM_ORDER_TYPE signal1 ,
    double stoploss1, double takeprofit1, int spread1, color clr1, int ticket1, string symbol1, int slippage1, int magic1, double askstop1,
     double bitstop1, double bidlimit1, double asklimit1) {
       
        OrderDistance = orderDistance1;
        this.expiration = expiration1;
        this.volume = volume1;
        this.signal = signal1;
     
        this.stoploss = stoploss1;
        this.takeprofit = takeprofit1;
        this.spread = spread1;
        this.clr = clr1;
        this.comment = comment;
        this.ticket = ticket1;
        this.symbol = symbol1;
        this.slippage = slippage1;
        magic = magic1;
        this.askstop = askstop1;
        this.bitstop = bitstop1;
        this.bidlimit = bidlimit1;
        this.asklimit = asklimit1;
    }
       public:
 double OrderDistance;
 datetime expiration;
 double volume;
 int digits;
 int points;
 ENUM_ORDER_TYPE signal;
 MqlTick tick;
 double stoploss,takeprofit;
 int spread;
 color clr;
 TComment comment;
  int ticket;
  string symbol;
  int slippage;
  int magic;
  double askstop,bitstop,bidlimit,asklimit;        
      
               
     
               COrder();
                    ~COrder();//default constructor
  };

  COrder::COrder()
  {
  
  
  
 OrderDistance=0;
expiration=0;
  volume=0;
 digits=0;
  points=0;
 signal=NULL;
 tick.ask=0;
 tick.bid=0;
 tick.time=0;
 tick.volume=0;
 tick.last=0;
 tick.flags=0;
 
 
stoploss=0;
takeprofit=0;
 spread=0;
 clr=clrWheat;
  comment.text=NULL;
  comment.colour=clrNONE;
  
  ticket=0;
 symbol=NULL;
   slippage=0;
  magic=0;
 askstop=0;bitstop=0;bidlimit=0;asklimit=0;        
  
  
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrder::~COrder()
  {
  }
//+------------------------------------------------------------------+
