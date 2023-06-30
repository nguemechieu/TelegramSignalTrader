//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

  
enum TRADE_STRATEGY { LONG, SHORT,LONG_AND_SHORT,NONE};


enum PLATFORM {TELEGRAM,DISCORD, TWITTER,FACEBOOK ,WHATSAPP};

enum TRADE_MODE{AUTO_TRADE, MANUAL,MIXED,ALERT_ONLY};

enum MARKET_SELECTION {CRYPTO_MARKET,FOREX_MARKET, STOCKS,INDICES};

  
  
#include  <Arrays/List.mqh>

class COrder


  {
private:

public:
  
  
  
  
  
  







int LotDigits;
CList OrderList;

double price,sl,tp;

datetime expiration;

double Order_StopLoss, Order_TakeProfit;//set sl an d tp

double Order_Trailing_Stop_Loss;//set order trail stop loss

double Order_Trailing_Take_Profit;//set order trailing take profit
		
double Order_Lot;// set Order lot
		
datetime Order_Open_Time, Order_Close_Time;
	
double Order_Loss,Order_Profit;
	
string  Order_Symbol;
		
		 
int Order_Ticket;


double Order_ClosePrice;
double Order_CloseBy;


datetime Order_CloseTime;


int Order_MagicNumber;

color clr;


double Order_Commission;

datetime Order_Expiration_Time;

double Order_OpenPrice;

double Order_CurrentPrice,profit,losses;
string Order_Comment ;
int Order_Type; datetime Order_Close_Times;
int NextOpenTradeAfterHours ;//next open trade after time
 int NextOpenTradeAfterTOD_Hour;  //next open trade after time of the day
int NextOpenTradeAfterTOD_Min; //next open trade after time of the day
datetime NextTradeTime ;
int TOD_From_Hour ; //time of the day (from hour)
int TOD_From_Min ; //time of the day (from min)
int TOD_To_Hour ; //time of the day (to hour)
int TOD_To_Min ; //time of the day (to min)
int MaxTradeDurationBars ; //maximum trade duration
int PendingOrderExpirationHours ; //pending order expiration
 double DeleteOrderAtDistance ; //delete order when too far from current price
 int MinTradeDurationBars ; //minimum trade duration
double MM_PositionSizing ;
 double MaxSpread ;
 int MaxSlippage ; //adjusted in OnInit
 bool TradeMonday ;
 bool TradeTuesday ;
bool TradeWednesday ;
bool TradeThursday ;
bool TradeFriday ;
bool TradeSaturday;
bool TradeSunday;
double MaxSL ;
 double MinSL ;
 double MaxTP ;
 double MinTP ;
 bool Send_Email;
 bool Audible_Alerts ;
 bool Push_Notifications ;
 int MaxOpenTrades ;
int MaxLongTrades ;
int MaxShortTrades;
 int MaxPendingOrders ;
 double MaxLot;
 
 
double MM_Martingale_Start ;
double MM_Martingale_ProfitFactor;
 double MM_Martingale_LossFactor ;
 bool MM_Martingale_RestartProfit ;
 bool MM_Martingale_RestartLoss ;
 int  MM_Martingale_RestartLosses ;
int MM_Martingale_RestartProfits ;
public:

void setMM_Martingale_ProfitFactor(double ProfitFactor){MM_Martingale_ProfitFactor=ProfitFactor;};
double getMM_Martingale_ProfitFactor(){return MM_Martingale_ProfitFactor;};


void  setMM_Martingale_Start(double Lot){ MM_Martingale_Start=Lot;}
double getMartingale_Start(){return MM_Martingale_Start ;};


void setMM_Martingale_RestartLoss (double restartlot){MM_Martingale_RestartLoss=restartlot;};
double getMM_Martingale_RestartLoss(){return MM_Martingale_RestartLoss ;};


void setMM_Martingale_LossFactor (double LossFactor ){ MM_Martingale_LossFactor=LossFactor;};
double getMM_Martingale_LossFactor(){return  MM_Martingale_LossFactor ;} ;

void setMM_Martingale_RestartProfit(int RestartProfit){MM_Martingale_RestartProfit=RestartProfit;};
double getMM_Martingale_RestartProfit(){return MM_Martingale_RestartProfit;};

void setMM_Martingale_RestartLosses(int Restart_Losses){MM_Martingale_RestartLosses=Restart_Losses;};
double getMM_Martingale_RestartLosses(){return MM_Martingale_RestartLosses;};




double Martingale_Trade_Size(double lots) //martingale / anti-martingale
  {
  
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
         lots = orderlots * MM_Martingale_LossFactor;
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots = MM_Martingale_Start;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }



double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(ticket)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {  double p=0,L=0;
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == getOrder_MagicNumber() &&OrderCloseTime()<TimeDay(TimeCurrent()))
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profit && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
             p+=orderprofit;
             
              if(OrderProfit()<0){L+=OrderProfit();};
           
            break;
            
           
         count++;
        }
         PrintFormat("Profit :%s, Losses:",p,L);
     }
     
   return(count >= n);
  }






bool inTimeInterval(datetime t, int From_Hour, int From_Min, int To_Hour, int To_Min)
  {
   string TOD = TimeToString(t, TIME_MINUTES);
   string TOD_From = StringFormat("%02d", From_Hour)+":"+StringFormat("%02d", From_Min);
   string TOD_To = StringFormat("%02d", To_Hour)+":"+StringFormat("%02d", To_Min);
   return((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, TOD_To) <= 0)
     || (StringCompare(TOD_From, TOD_To) > 0
       && ((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, "23:59") <= 0)
         || (StringCompare(TOD, "00:00") >= 0 && StringCompare(TOD, TOD_To) <= 0))));
  }

void CloseByDuration(int sec) //close trades opened longer than sec seconds
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() > 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      price = Bid;
      if(OrderType() == OP_SELL)
         price = Ask;
      success = OrderClose(OrderTicket(), NormalizeDouble(OrderLots(), LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, clrWhite);
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderClose failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders closed by duration: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

void DeleteByDuration(int sec) //delete pending order after time since placing the order
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders deleted by duration: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

void DeleteByDistance(double distance) //delete pending order if price went too far from it
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
    price = (OrderType() % 2 == 1) ? Ask : Bid;
      if(MathAbs(OrderOpenPrice() - price) <= distance) continue;
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders deleted by distance: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

double MM_Size() //position sizing
  {
   double maxLot=MaxLot;
   
   if( maxLot==0){ maxLot = MarketInfo(Symbol(), MODE_MAXLOT);}
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lots = AccountBalance() /10000;
   if(lots > maxLot) lots = maxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }

bool TradeDayOfWeek()
  {
   int day = DayOfWeek();
   return((TradeMonday && day == 1)
   || (TradeTuesday && day == 2)
   || (TradeWednesday && day == 3)
   || (TradeThursday && day == 4)
   || (TradeFriday && day == 5)
   || (TradeSaturday && day == 6)
   || (TradeSunday && day == 0));
  }

void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
      Print(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("OLU_TREND_BOT", type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("OLU_TREND_BOT.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "modify")
     {
      Print(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("OLU_TREND_BOT", type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("OLU_TREND_BOT.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | OLU_TREND_BOT @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

void setOrder_MagicNumber(int magicnumber ){
Order_MagicNumber=magicnumber;

}





int getOrder_MagicNumber(){

  return Order_MagicNumber;
}

void setOrder_Expiration_Time(int ticket,datetime date){
Order_Expiration_Time=date;
if(OrderSelect(ticket,SELECT_BY_POS,MODE_TRADES)==true){
Order_Ticket=OrderModify(Order_Ticket,OrderOpenPrice(),sl,OrderTakeProfit(),date,Red);     
}

}
datetime getOrder_Expiration_Time(){
return Order_Expiration_Time;
}

void setOrder_OpenPrice(string symbol,int type,double prices,double lots){
Order_OpenPrice=prices;
Order_Type=type;
Order_Symbol=symbol;
Order_Lot=lots;
if(Ask==prices|| Bid==prices){
Order_Ticket=OrderSend(getOrder_Symbol(),getOrder_Command(),getOrder_Lot(),getOrder_OpenPrice(),getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());

Order_OpenPrice=OrderOpenPrice();

}

}

double getOrder_OpenPrice(){

return Order_OpenPrice;
}

void setOrder_Type(int order_type){
Order_Type=order_type;

}
int getOrder_Type(){//return Order type;
Order_Type=OrderType();
return Order_Type;
}

color Order_Color;int Order_Command;

   void setOrder_Command(int Order_command){
   Order_Command=Order_command;
   
   }
   
   int getOrder_Command(){//return order comment
   
   return Order_Command;
   }
   
   
   
   
  void Order_Modify (double prices,double stoplosses,double takeprofits,datetime expiration_date){
   
   Order_Ticket=OrderModify(OrderTicket(),prices,stoplosses,takeprofits,expiration_date);
    
     
   }
   
   void setOrder_Comment(string commentss){
    Order_Comment=commentss;
   }
   string getOrder_Comment(){
   
   return Order_Comment;
   }
   
   
   
void setOrder_Color(color Color){//set order color

Order_Color=Color;
}

color getOrder_Color(){return Order_Color;};
//send order open a new order based on init inputs
string  SendOrder(   int type ){

double prices;   Order_Type=type;
if(type==OP_BUY||type==OP_BUYSTOP||type==OP_BUYLIMIT){prices=Ask;
Order_Ticket=OrderSend(getOrder_Symbol(),getOrder_Command(),getOrder_Lot(),prices,getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());



}else if(type==OP_SELL||type==OP_SELLSTOP||type==OP_SELLLIMIT){prices=Bid;
Order_Ticket=OrderSend(getOrder_Symbol(),getOrder_Command(),getOrder_Lot(),prices,getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());


};
return StringFormat(" Ticket :%s,Symbol :%s,Type :%s,Lot:%2.4f,Price:%2.4f,Slippage:%d,SL:%d,TP:%2.4f,Comment:%s,MagicNumber:%d,Expiration:%s,Color:%s",getOrder_Ticket(),getOrder_Symbol(),getOrder_Type(),getOrder_Lot(),prices,getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());

}

void setOrder_Symbol(string symbol){

Order_Symbol=symbol;
}

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

datetime LastOpenTradeTime()
  {
   datetime result = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderType() > 1) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == Order_MagicNumber)
        {
         result = OrderOpenTime();
         break;
        }
     } 
   return(result);
  }


bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == Order_MagicNumber)
        {
         lastOrder = i;
         if(OrderProfit()<0){Order_Loss=OrderProfit();};
         if(OrderProfit()>=0){Order_Profit=OrderProfit();}
          
         break;
        }
     } 
   return(lastOrder >= 0);
  }

datetime LastOpenTime()
  {
   datetime opentime1 = 0, opentime2 = 0;
   if(SelectLastHistoryTrade())
      opentime1 = OrderOpenTime();
   opentime2 = LastOpenTradeTime();
   if (opentime1 > opentime2)
      return opentime1;
   else
      return opentime2;
  }

double Margin_Risk_Percent;

void setOrder_Margin_Risk_Percent(double margin_Risk_Percent){
Margin_Risk_Percent=margin_Risk_Percent;

}
double getOrder_Margin_Risk_Percent(){return Margin_Risk_Percent;}



double MM_Lot(double sls) //Risk % per trade, SL = relative Stop Loss to calculate risk
  {
    MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_LOTSIZE);
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double lots = getOrder_Margin_Risk_Percent() / 100 * AccountEquity() / (sls/ ticksize * tickvalue);
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot)lots = MinLot;
   return(lots);
  }
void myOrderDelete(int type, string ordername) //delete pending orders of "type"
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
        Alert("error", "OrderDelete"+ordername_+" failed; error #"+IntegerToString(err)+" ");
        }
     }}

string getOrder_Symbol(){
return Order_Symbol;
}

int Order_Slippage ;

void setOrder_Slippage(int slippages){
Order_Slippage =slippages;


}


int  getOrder_Slippage(){
return Order_Slippage ;
}

void setOrder_Ticket(int ticket) {
Order_Ticket=ticket;


	};//set order ticket number

int getOrder_Ticket() {
 return Order_Ticket;
	}
	
	
void setOrderLoss(){
for(int j=OrdersTotal()-1;j>0;j--){
  if( OrderSelect( Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==true){
    if(OrderProfit()<=0)losses=OrderProfit();
  }
}
}
double geOrderLoss(){
return losses;
}


void setOrder_StopLoss(double sls) {
  Order_StopLoss=sls;
 
 
	}

double getOrder_StopLoss() {
		return Order_StopLoss ;
		};

void setOrder_TakeProfit(double tps) {
	Order_TakeProfit=tps;
};//set sl an d tp


double  getOrder_TakeProfit() {
		return Order_TakeProfit;
	};
	
	
	

void setOrder_Trailing_Stop_Loss(int sls) {


Order_Trailing_Stop_Loss=sls;

};//set order trail stop loss




double getOrder_Trailing_Stop_Loss(){
return Order_Trailing_Stop_Loss;


}





void setOrder_Trailing_Take_Profit(double traillingPips) {
   Order_Trailing_Take_Profit=traillingPips;
};//set order trailing take profit
 
 double  getOrder_Trailing_Take_Profit() {
return tp;
};

void setOrder_Lot(double Lot) { Order_Lot=Lot;};// set Order lot
double  getOrder_Lot() {
	return Order_Lot;
};// Get Order lot


void setOrder_Open_Time(datetime date_time) {
	Order_Open_Time = date_time;
};

datetime getOrder_Open_Time() {
 
for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect(Order_Ticket,SELECT_BY_TICKET,MODE_HISTORY)){
   return Order_Open_Time= OrderOpenTime();
  
  }
}

return	Order_Open_Time=0;
};


datetime getOrder_Close_Time() {

 for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect(  Order_Ticket,SELECT_BY_TICKET,MODE_HISTORY)){
   return Order_Close_Times=OrderOpenTime();}
  };
 return Order_Close_Times;
}



double TotalOpenProfit(int type,string symbol,datetime date)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)   
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != Order_MagicNumber) continue;
      if((type < 0 && OrderType() == OP_BUY) || (type > 0 && OrderType() == OP_SELL)) continue;
      result += OrderProfit();
     }
   return(result);
  }
  



};
