//+------------------------------------------------------------------+
//|                                              MoneyManagement.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
double TradeSize(MONEYMANAGEMENT moneymanagement){

if(moneymanagement==MARTINGALE_OR_ANTI_MATINGALE){





return  MM_Size();
};
return 0.01;
}
datetime LastOpenTradeTime()
  {
   datetime result = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderType() > 1) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
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
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

double BOProfit(int tickets) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(tickets)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profits && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
            break;
         count++;
        }
     }
   return(count >= n);
  }

double TotalOpenProfit(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)   
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      result += OrderProfit();
     }
   return(result);
  }

double POSITION_SIZING() //position sizing
  {
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lots = AccountBalance() / MM_PositionSizing;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
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


double MM_Size() //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
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

datetime LastCloseTime()
  {
   if(SelectLastHistoryTrade())
     {
      return(OrderCloseTime());
     }
   return(0);
  }
  
  
  
  
  