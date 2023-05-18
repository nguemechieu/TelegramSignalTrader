//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
#include  <Arrays/List.mqh>


   struct TradeData { 
 double price;

          int digit;
          int point;
          int slippage;
          string comment;
          int MagicNumber;
          string symbol;
          double volume;
         ENUM_ORDER_TYPE type;
          datetime date;
          datetime expiration;
          color clrName;
          double stopLoss;
          double takeProfit;
          double ask;
          double bid;
          
          };
class CTrade : public CList
  {
private:
     TradeData tradeData1;              
   CList OrderList;
public:
   
  
int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != tradeData1.MagicNumber || OrderSymbol() != Symbol() || OrderType() != tradeData1.type) continue;
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
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == tradeData1.MagicNumber)
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
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == tradeData1.MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

double TotalOpenProfit(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)   
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != tradeData1.MagicNumber) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      result += OrderProfit();
     }
   return(result);
  }
    
    
  
   
   
   void CloseTrade(TradeData &tradeData2){

      int tickets=OrderClose(OrderTicket(),OrderLots(),tradeData2.price,tradeData2.slippage,tradeData2.clrName);
    if(tickets>0){
    
    printf("Error order "+(string)tickets+" "+tradeData2.symbol +"not closed!");
    }else{
    
    printf("Order "+tradeData2.symbol+ "has been  closed at "+(string)tradeData2.price );
    
    }
   
   }
   
                  
                     
   

    
    
void myAlert(string type, string message1)
  {bool crossed[2]; //initialized to true, used in function Cross
 Send_Email = true;  Audible_Alerts = true;
Push_Notifications = true;
   int handle;
   if(type == "print")
      Print(message1);
   else if(type == "error")
     {
      Print(type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
     }
   else if(type == "order")
     {
      Print((string)tradeData1.type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
      if(Audible_Alerts) Alert((string)tradeData1.type+" | breakout @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Send_Email) SendMail("breakout", (string)tradeData1.type+" | breakout @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      handle = FileOpen("breakout.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, (string)tradeData1.type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification((string)tradeData1.type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
     }
   else if(type == "modify")
     {
      if(Audible_Alerts) Alert((string)tradeData1.type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
      if(Send_Email) SendMail("breakout", (string)tradeData1.type+" | breakout @ "+tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
      if(Push_Notifications) SendNotification((string)tradeData1.type+" | breakout @ "+(string)tradeData1.symbol+","+IntegerToString(Period())+" | "+message1);
     }
   }               
                     
  //----------------open trade--------------------
    int OpenTrade(TradeData &tradeData11)
    {

    
   string  ordername_, ordername=tradeData11.comment;
   if(!IsTradeAllowed()) return(-1);
   int tickets = -1;
 
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
  ordername_ =tradeData1.comment;
   if(ordername != "")
      ordername_ = "("+ordername+")";
 
   //prepare to send order
   while(IsTradeContextBusy()){ Sleep(100);break;}
   RefreshRates();
   
    if(tradeData1.price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
    
   int clr = (tradeData11.type % 2 == 1) ? clrRed : clrBlue;
    ENUM_ORDER_TYPE type=tradeData11.type;
    double price=tradeData1.price;
    myPoint=(int)MarketInfo(tradeData1.symbol,MODE_POINT);
   //adjust price for pending order if it is too close to the market price
   double MinDistance = tradeData11.bid * myPoint;
   if(type == OP_BUYLIMIT && tradeData11.price- price < MinDistance)
      price = tradeData1.price- MinDistance;
   else if(type == OP_BUYSTOP && price - Ask < MinDistance)
      price = Ask + MinDistance;
   else if(type == OP_SELLLIMIT && price - Bid < MinDistance)
      price = Bid + MinDistance;
   else if(type == OP_SELLSTOP && Bid - price < MinDistance)
      price = Bid - MinDistance;
      
   while(tickets < 0 && retries < OrderRetry+1)
     {
      tickets= OrderSend(tradeData11.symbol, tradeData11.type, tradeData11.volume, NormalizeDouble(tradeData11.price, tradeData11.digit),tradeData11.slippage, 0,0, ordername, tradeData11.MagicNumber, 0, clr);
      if(tickets < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(tickets< 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+tradeData1.symbol+" Magic #"+IntegerToString(tradeData1.MagicNumber));
  
   return(tickets);
   
   
  }
                    
   CTrade(){
 
   }
   
   
   
   
   
   ~CTrade(){  }
   
   
   ;
 
  };
     
    
 

