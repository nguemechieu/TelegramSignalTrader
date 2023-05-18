//+------------------------------------------------------------------+
//|                                                   TRADE_DATA.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class CTRADE_DATA  
{


public:
datetime order_open_time;//open time
datetime order_close_time ;//close time
double price;//price
datetime expiration ;//expiration
string comment;//comments
int magic_number;//magic number
color order_color;// color
string symbol;//order symbol
 double stoploss;//order stop loss
 double takeprofit;;//order take profit
 double volume;
 //order lot size
 int slippage;;//order slippage
 int spread;;//order spread
 ENUM_ORDER_TYPE type;//order type
 double profit;
 double losses;
 double drawDown;
    
    public: string toString() {
        return "TRADE_DATA{" +
                "order_open_time=" + (string)order_open_time +
                ", order_close_time=" + (string)order_close_time +
                ", price=" +(string )price +
                ", expiration=" + (string)expiration +
                ", comment=" + comment +
                ", magic_number=" +(string )magic_number +
                ", order_color=" + (string)order_color +
                ", symbol=" + symbol +
                ", stoploss=" +(string) stoploss +
                ", takeprofit=" + (string)takeprofit +
                ", lot_size=" +(string )volume +
                ", slippage=" +(string )slippage +
                ", spread=" +(string) spread +
                ", type=" + (string)type +
                ", profit=" + (string)profit +
                ", losses=" + (string)losses +
                ", drawDown=" + (string)drawDown +
                (string)'}';
    }
    double lot_size;
    
   public: CTRADE_DATA(datetime order_open_time1, datetime order_close_time1, double price1, datetime expiration1, string comment1, int magic_number1, color order_color1, string symbol1, double stoploss1,
    double takeprofit1, double &volume1, int slippage1, int spread1, ENUM_ORDER_TYPE type1, double profit1, double losses1, double drawDown1) {
        this.order_open_time = order_open_time1;
        this.order_close_time = order_close_time1;
        this.price = price1;
        this.expiration = expiration1;
        this.comment = comment;
        this.magic_number = magic_number1;
        this.order_color = order_color1;
        this.symbol = symbol1;
        this.stoploss = stoploss1;
        this.takeprofit = takeprofit1;
        this.lot_size = volume=volume1;
        this.slippage = slippage1;
        this.spread = spread1;
        this.type = type1;
        this.profit = profit1;
        this.losses = losses1;
        this.drawDown = drawDown1;
    }

    public :datetime getOrder_open_time() {
        return order_open_time;
    };

  void setOrder_open_time(datetime order_open_time1) {
        this.order_open_time = order_open_time1;
    }

    datetime getOrder_close_time() {
        return order_close_time;
    }

  void setOrder_close_time(datetime order_close_time1) {
        this.order_close_time = order_close_time1;
    }

   double getPrice() {
        return price;
    }
    
    string getComment(){return comment;};
    
   void setComment(string comment1){this. comment=comment1;
    
    };

  void setPrice(double price1) {
        this.price = price1;
    }

     datetime getExpiration() {
        return expiration;
    }

    void setExpiration(datetime expiration1) {
        this.expiration = expiration1;
    }

   
   void setComment(string &comment1) {
        this.comment=comment1;
    }

   int getMagic_number() {
        return magic_number;
    }

  void setMagic_number(int magic_number1) {
        this.magic_number = magic_number1;
    }

    color getOrder_color() {
        return order_color;
    }

  void setOrder_color(ENUM_ORDER_TYPE order_TYPE) {
          if(order_TYPE==ORDER_TYPE_BUY){
            
        this.order_color = clrGreen;
          
          }else   if(order_TYPE==ORDER_TYPE_BUY_LIMIT){
            
        this.order_color = clrYellow;
        
          
          } else if(order_TYPE==ORDER_TYPE_BUY_STOP){
            
        this.order_color = clrWhite;
          
          }else   if(order_TYPE==ORDER_TYPE_SELL){
            
        this.order_color = clrRed;
          
          }
          else   if(order_TYPE==ORDER_TYPE_SELL_LIMIT){
            
        this.order_color = clrBlue;
          
          }else   if(order_TYPE==ORDER_TYPE_SELL_STOP){
            
        this.order_color = clrAzure;
          
          }
          
          
      
    }

   string getSymbol() {
        return symbol;
    }

    void setSymbol(string symbol1) {
        this.symbol = symbol1;
    }

    double getStoploss() {
        return stoploss;
    }

   void setStoploss(double stoploss1) {
        this.stoploss = stoploss1;
    }

   double getTakeprofit() {
        return takeprofit;
    }

    void setTakeprofit(double takeprofit1) {
        this.takeprofit = takeprofit1;
    }

    double getLot_size() {
        return lot_size;
    }

  void setLot_size(double lot_size1) {
        this.lot_size = lot_size1;
    }

    int getSlippage() {
        return slippage;
    }

    void setSlippage(int slippage1) {
        this.slippage = slippage1;
    }

   int getSpread() {
        return spread;
    }

   void setSpread(int spread1) {
        this.spread = spread1;
    }

   ENUM_ORDER_TYPE getType() {
        return type;
    }

   void setType(ENUM_ORDER_TYPE type1) {
        this.type = type1;
    }

    double getProfit() {
        return profit;
    }
 void setProfit(double &profit1) {
        this.profit = profit1;
    }

     double getLosses() {
        return losses;
    }

    void setLosses(double &losses1) {
        this.losses = losses1;
    }

    double getDrawDown() {
        return drawDown;
    }

    void setDrawDown(double drawDown1) {
        this.drawDown = drawDown1;
    }

 CTRADE_DATA();
 ~CTRADE_DATA();

};

CTRADE_DATA::CTRADE_DATA(){



order_open_time=0;//open time
 order_close_time=0 ;//close time
price=0;//price
expiration =0;//expiration
 comment=NULL;//comments
magic_number=0;//magic number
 order_color=clrNONE;// color
symbol=_Symbol;//order symbol
 stoploss=0;//order stop loss
 takeprofit=0;//order take profit
  lot_size=0;//order lot size
 slippage=0;//order slippage
  spread=0;//order spread
  type=ORDER_TYPE_BUY;//order type
  profit=0;
 losses=0;
  drawDown=0;


}
CTRADE_DATA ::~CTRADE_DATA(){}










