//+------------------------------------------------------------------+
//|                                  TelegramSignalTrader.mq4 |
//|                                  Copyright 2023, tradeadviser Llc. |
//|                                             https://www.tradeadviser.org |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tradeadviser LLc."
#property link      "https://www.tradeadviser.org"
#property strict
//+------------------------------------------------------------------+
#define EXPERT_NAME     "TelegramSignalTrader"
#define EXPERT_VERSION  "1.01"
#property version       EXPERT_VERSION
#property indicator_buffers 2
//--- to download the xml
#import "urlmon.dll"
int URLDownloadToFileW(int pCaller, string szURL, string szFileName, int dwReserved, int Callback);
#import
//---
#define INAME     "FFC"
#define TITLE     0
#define COUNTRY   1
#define DATE      2
#define TIME      3
#define IMPACT    4
#define FORECAST  5
#define PREVIOUS  6



#property tester_file "trade.csv"    // file with the data to be read by an Expert Advisor TradeExpert_file "trade.csv"    // file with the data to be read by an Expert Advisor

#property tester_library "Libraries"
#property stacksize 1000000
#property description "This is a very interactive smartBot. It uses multiples indicators base on  define strategy to get trade signals a"
#property description "nd open orders. It also integrate news filter to allow you to trade base on news events. In addition the ea generate s"
#property description "ignals with screenshot on telegram or others withoud using dll import.This  give ea ability to trade on your vps witho"
#property description "ut restrictions."
#property description "This Bot will can trade generate ,manage and generate trading signals on telegram channel"
#include <stdlib.mqh>
#include <stderror.mqh>
#include <DiscordTelegram\Comment.mqh>
#include <DiscordTelegram\Telegram.mqh>
#include <DiscordTelegram\CMybot.mqh>
#include <DiscordTelegram\News.mqh>





//+------------------------------------------------------------------+

enum MONEY_MANAGEMENT
  {
   RISK_PERCENTAGE,
   POSITION_SIZE,
   MARTINGALE,
   FIXED_SIZE
  }
;



enum Answer {yes, no};


enum DYS_WEEK
  {
   Sunday = 0,
   Monday = 1,
   Tuesday = 2,
   Wednesday,
   Thursday = 4,
   Friday = 5,
   Saturday
  };

enum TIME_LOCK
  {
   closeall,//CLOSE_ALL_TRADES
   closeprofit,//CLOSE_ALL_PROFIT_TRADES
   breakevenprofit//MOVE_PROFIT_TRADES_TO_BREAKEVEN
  };





//---
CComment       comment;
CMyBot         bot;
ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;
string         photo_id = NULL;
int siz = 0;



int MagicNumber = 123;






//  Input parameters                                               |
input ENUM_UPDATE_MODE  InpUpdateMode = UPDATE_NORMAL; //Update Mode
input string            InpToken = "2125623831:AAF28ssPXid819-xSoLwGwc4V-q0yrKgyzg"; //Token
input long ChatID = -1001648392740; //CHAT OR GROUP ID

input string CHANNEL_NAME = "tradeexpert_infos";
long TELEGRAM_GROUP_CHAT_ID = ChatID;
string            InpUserNameFilter = ""; //Whitelist Usernames
input   string            InpTemplates = "ADX,RSI, ADX,Momentum"; //Templates for screenshot

//I need an expert to develop a Telegram to MT4 & MT5 copying system with the following functions:


input EXECUTION_MODE  ImmediateExecution;// TRADE MODE

input MONEY_MANAGEMENT  money_management;// MONEY MANAGEMENT
input bool  Move_SL_Automatically = true; // MOVE SL AUTOMATICALLY
input bool  Move_TP_to_Breakeven = true; //MOVE TP TO BREAKEVEN


input int slippage = 2; //SLIPPAGE
input int stoploss = 100; // SL IN POINT
input int takeprofit = 100; // SL IN POINT
extern string  h1                   = "===Time Management System==="; // =========Monday==========
input  Answer   SET_TRADING_DAYS     = no;
input  DYS_WEEK EA_START_DAY        = Sunday;//Starting Day
input string EA_START_TIME          = "22:00";
input DYS_WEEK EA_STOP_DAY          = Friday;//Ending Day
input string EA_STOP_TIME          = "22:00";


input string fsiz;//FIXED SIZE PARAMS
input double lotSize = 0.01; //FIXED SIZE

input string sddd; //MATINGALE PARAMS
input   double MM_Martingale_Start = 0.01;
input double MM_Martingale_ProfitFactor = 1;
input double MM_Martingale_LossFactor = 2;
input bool MM_Martingale_RestartProfit = true;
input bool MM_Martingale_RestartLoss = false;
input int MM_Martingale_RestartLosses = 1000;
input int MM_Martingale_RestartProfits = 1000;
input string psds;//POSITION SIZE PARAMS


input double MM_PositionSizing = 10000;








//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Position_Size(string sym) //position sizing
  {
   double MaxLot = MarketInfo(sym, MODE_MAXLOT);
   double MinLot = MarketInfo(sym, MODE_MINLOT);
   double lots = AccountBalance() / MM_PositionSizing;
   if(lots > MaxLot)
      lots = MaxLot;
   if(lots < MinLot)
      lots = MinLot;
   return(lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MM_Size(string sym) //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
   double MaxLot = MarketInfo(sym, MODE_MAXLOT);
   double MinLot = MarketInfo(sym, MODE_MINLOT);
   if(SelectLastHistoryTrade(sym))
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else
         if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
            lots = orderlots * MM_Martingale_LossFactor;
         else
            if(orderprofit + boprofit == 0)
               lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots = MM_Martingale_Start;
   if(lots > MaxLot)
      lots = MaxLot;
   if(lots < MinLot)
      lots = MinLot;
   return(lots);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SelectLastHistoryTrade(string sym)
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;
      if(OrderSymbol() == sym && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     }
   return(lastOrder >= 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#" + IntegerToString(ticket) + " ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  GetLotSize(MONEY_MANAGEMENT money)
  {
string sym=Symbol();
   if(money == RISK_PERCENTAGE)
     {
      return MM_Size(sym);
     }
   else
      if(money == MARTINGALE)
        {
         return MM_Size(sym);
        }
      else
         if(money == POSITION_SIZE)
           {
            return Position_Size(sym);
           }
         else
            if(money == FIXED_SIZE)
               return lotSize;
   return 0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   int totalOP  = OrdersTotal(), tiket = 0;
   for(int cnt = totalOP - 1 ; cnt >= 0 ; cnt--)
     {
      int Oc = 0, Os = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
        {
         Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);
         Sleep(300);
         continue;
        }
      if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
        {
         Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, CLR_NONE);
         Sleep(300);
        }
     }
  }


//+------------------------------------------------------------------+
//|             TradeDays                                                     |
//+------------------------------------------------------------------+
bool TradeDays()
  {
   if(SET_TRADING_DAYS == no)
      return(true);
   bool ret = false;
   int today = DayOfWeek();
   if(EA_START_DAY < EA_STOP_DAY)
     {
      if(today > EA_START_DAY && today < EA_STOP_DAY)
         return(true);
      else
         if(today == EA_START_DAY)
           {
            if(TimeCurrent() >= datetime(StringToTime(EA_START_TIME)))
               return(true);
            else
               return(false);
           }
         else
            if(today == EA_STOP_DAY)
              {
               if(TimeCurrent() < datetime(StringToTime(EA_STOP_TIME)))
                  return(true);
               else
                  return(false);
              }
     }
   else
      if(EA_STOP_DAY < EA_START_DAY)
        {
         if(today > EA_START_DAY || today < EA_STOP_DAY)
            return(true);
         else
            if(today == EA_START_DAY)
              {
               if(TimeCurrent() >= datetime(StringToTime(EA_START_TIME)))
                  return(true);
               else
                  return(false);
              }
            else
               if(today == EA_STOP_DAY)
                 {
                  if(TimeCurrent() < datetime(StringToTime(EA_STOP_TIME)))
                     return(true);
                  else
                     return(false);
                 }
        }
      else
         if(EA_STOP_DAY == EA_START_DAY)
           {
            datetime st = (datetime)StringToTime(EA_START_TIME);
            datetime et = (datetime)StringToTime(EA_STOP_TIME);
            if(et > st)
              {
               if(today != EA_STOP_DAY)
                  return(false);
               else
                  if(TimeCurrent() >= st && TimeCurrent() < et)
                     return(true);
                  else
                     return(false);
              }
            else
              {
               if(today != EA_STOP_DAY)
                  return(true);
               else
                  if(TimeCurrent() >= et && TimeCurrent() < st)
                     return(false);
                  else
                     return(true);
              }
           }
   /*int JamH1[] = { 10, 20, 30, 40 }; // A[2] == 30
    //   if (JamH1[Hour()] == Hour()) Alert("Trade");
    if (Hour() >= StartHour1 && Hour() <= EndHour1 && DayOfWeek() == 1 && MondayTrade )  return (true);
    if (Hour() >= StartHour2 && Hour() <= EndHour2 && DayOfWeek() == 2 && TuesdayTrade )  return (true);
    if (Hour() >= StartHour3 && Hour() <= EndHour3 && DayOfWeek() == 3 && WednesdayTrade )  return (true);
    if (Hour() >= StartHour4 && Hour() <= EndHour4 && DayOfWeek() == 4 && ThursdayTrade )  return (true);
    if (Hour() >= StartHour5 && Hour() <= EndHour5 && DayOfWeek() == 5 && FridayTrade && !ExitFriday)  return (true);
    if (StartHour5 <=StartHourX - LastTradeFriday - 1 && Hour() >= StartHour5 && Hour() <= StartHourX - LastTradeFriday - 1 && DayOfWeek() == 5 && FridayTrade && ExitFriday)  return (true);
    if ( DayOfWeek() == 1 && !MondayTrade )  return (true);
    if ( DayOfWeek() == 2 && !TuesdayTrade )  return (true);
    if ( DayOfWeek() == 3 && !WednesdayTrade )  return (true);
    if ( DayOfWeek() == 4 && !ThursdayTrade )  return (true);
    if ( DayOfWeek() == 5 && !FridayTrade && ExitFridayOk() == 0)  return (true);
    */
   return (ret);
  }

////////////////////////////////////////////////////////////////////////
void timelockaction(void)
  {
   if(TradeDays())
      return;
   double stoplevel = 0, proffit = 0, newsl = 0, price = 0;
   double ask = 0, bid = 0;
   string sy = NULL;
   int sy_digits = 0;
   double sy_points = 0;
   bool ans = false;
   bool next = false;
   int otype = -1;
   int kk = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderMagicNumber() != MagicNumber)
         continue;
      next = false;
      ans = false;
      sy = OrderSymbol();
      ask = SymbolInfoDouble(sy, SYMBOL_ASK);
      bid = SymbolInfoDouble(sy, SYMBOL_BID);
      sy_digits = (int)SymbolInfoInteger(sy, SYMBOL_DIGITS);
      sy_points = SymbolInfoDouble(sy, SYMBOL_POINT);
      stoplevel = MarketInfo(sy, MODE_STOPLEVEL) * sy_points;
      otype = OrderType();
      kk = 0;
      proffit = OrderProfit() + OrderSwap() + OrderCommission();
      newsl = OrderOpenPrice();
      if(proffit <= 0)
         break;
      else
        {
         price = (otype == OP_BUY) ? bid : ask;
         while(otype < 2 && kk < 5 && MathAbs(price - newsl) >= stoplevel && !OrderModify(OrderTicket(), newsl, newsl, OrderTakeProfit(), OrderExpiration()))
           {
            kk++;
            price = (otype == OP_BUY) ? SymbolInfoDouble(sy, SYMBOL_BID) : SymbolInfoDouble(sy, SYMBOL_ASK);
           }
        }
      continue;
     }
  }

//+------------------------------------------------------------------+
//|                     CHART COLOR SET                                             |
//+------------------------------------------------------------------+
bool ChartColorSet()//set chart colors
  {
   ChartSetInteger(ChartID(), CHART_COLOR_ASK, BearCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_BID, clrOrange);
   ChartSetInteger(ChartID(), CHART_COLOR_VOLUME, clrAqua);
   int keyboard = 12;
   ChartSetInteger(ChartID(), CHART_KEYBOARD_CONTROL, keyboard);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, 231);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BEAR, BearCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BULL, BullCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, Bear_Outline);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_UP, Bull_Outline);
   ChartSetInteger(ChartID(), CHART_SHOW_GRID, 0);
   ChartSetInteger(ChartID(), CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(ChartID(), CHART_MODE, 1);
   ChartSetInteger(ChartID(), CHART_SHIFT, 1);
   ChartSetInteger(ChartID(), CHART_SHOW_ASK_LINE, 1);
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, BackGround);
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, ForeGround);
   return(true);
  }

input color BearCandle = clrWhite;
input color BullCandle = clrGreen;
input color BackGround = clrBlack;
input color ForeGround = clrAquamarine;
input color Bear_Outline = clrRed;
input color Bull_Outline = clrGreen;
input string license_key = "trial";
bool CheckLicense(string license)
  {
   datetime tim = D'2023.07.01 00:00';
   if(license == "trial")
     {
      int op = FileOpen(license, FILE_WRITE | FILE_CSV);
      if(op < 0)
        {
         printf("Can't open license key folder");
         return false;
        }
      uint write = FileWrite(op, license_key + (string)AccountNumber() + (string)TimeCurrent());
      FileClose(op);
      Comment("\n\n                                                     Trial Mode");
      if(tim > TimeCurrent())
        {
         return true;
        }
      else
        {
         MessageBox("Your trial Mode is Over!Please purchase a new license to get access to a full product.You can also contact support at https://t.me/tradeexpert_infos"
                    , NULL, 1);
         return false;
        }
     }
   else
     {
      return false;
     }
   return false;
  }



//+------------------------------------------------------------------+
//| Expert check license                                             |
//+------------------------------------------------------------------+
bool CheckLicense()
  {
   Print("Account name: ", AccountName());
   if(StringFind(StringLower(AccountName()), "account name in lowercase!!") < 0)
     {
      Alert("No license active!");
      Comment("No license active!");
      ExpertRemove();
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Expert string to lower                                           |
//+------------------------------------------------------------------+
string StringLower(string str)
  {
   string outstr = "ertyuio";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   for(int i = 0; i < StringLen(str); i++)
     {
      int t1 = StringFind(upper, StringSubstr(str, i, 1), 0);
      if(t1 >= 0)
        {
         outstr = outstr + StringSubstr(lower, t1, 1);
        }
      else
        {
         outstr = outstr + StringSubstr(str, i, 1);
        }
     }
   int op = FileOpen("licence.txt", 0, ',', CP_ACP);
   if(op > 0)
     {
      printf("File open");
     }
   else
     {
      printf("ERROR WECAN'T OPEN FILE license.txt");
     }
   return(outstr);
  }

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//Verify license
//if ( !CheckLicense()){
//return false;
//}
   ChartColorSet();
   if(TradeDays() && SET_TRADING_DAYS == yes)
     {
      MessageBox("TIME REACHED!PLEASE WAIT FOR NEW TRADING SESSION");
      return INIT_FAILED;
     }
//---
   run_mode = GetRunMode();
//--- stop working in tester
   if(run_mode != RUN_LIVE)
     {
      PrintError(ERR_RUN_LIMITATION, InpLanguage);
      return(INIT_FAILED);
     }
   int y = 40;
   if(ChartGetInteger(0, CHART_SHOW_ONE_CLICK))
      y = 120;
   comment.Create("myPanel", 19, y);
   comment.SetColor(clrDimGray, clrGreen, 223);
//--- set language
   bot.Language(InpLanguage);
//--- set token
   init_error = bot.Token(InpToken);
//--- set filter
   bot.UserNameFilter(InpUserNameFilter);
//--- set templates
   bot.Templates(InpTemplates);
//--- set timer
   int timer_ms = 3000;
   switch(InpUpdateMode)
     {
      case UPDATE_FAST:
         timer_ms = 1000;
         break;
      case UPDATE_NORMAL:
         timer_ms = 2000;
         break;
      case UPDATE_SLOW:
         timer_ms = 3000;
         break;
      default:
         timer_ms = 3000;
         break;
     };
   EventSetMillisecondTimer(timer_ms);
   OnTimer();
//--- done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason == REASON_CLOSE ||
      reason == REASON_PROGRAM ||
      reason == REASON_PARAMETERS ||
      reason == REASON_REMOVE ||
      reason == REASON_RECOMPILE ||
      reason == REASON_ACCOUNT ||
      reason == REASON_INITFAILED)
     {
      time_check = 0;
      comment.Destroy();
     }
//---
   EventKillTimer();
   OnDeinit3(reason);
   ChartRedraw();
  }


extern double BreakEven_Points = 6;
int LotDigits; //initialized in OnInit

double MM_Percent = 1;
int MaxSlippage = 3; //slippage, adjusted in OnInit
double MaxTP = 100;
double MinTP = 50;
extern double CloseAtPL = 50;
bool crossed[4]; //initialized to true, used in function Cross
input int MaxOpenTrades = 3;
input int MaxLongTrades = 3;
input int MaxShortTrades = 3;
int MaxPendingOrders = 1000;
int MaxLongPendingOrders = 1000;
int MaxShortPendingOrders = 1000;
input bool Hedging = false;
input int OrderRetry = 2; //# of retries if sending order returns error
input  int OrderWait = 3; //# of seconds to wait if sending order returns error
double myPoint; //initialized in OnInit

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MM_Size(double SL) //Risk % per trade, SL = relative Stop Loss to calculate risk
  {
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double lots = (MM_Percent / 100) * SL / 2;
   if(lots > MaxLot)
      lots = MaxLot;
   if(lots < MinLot)
      lots = MinLot;
   return(lots);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MM_Size_BO() //Risk % per trade for Binary Options
  {
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   return(MM_Percent * 1.0 / 100 * AccountBalance());
  }

void CloseTradesAtPL(double PL) //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
  {
   double totalPL = TotalOpenProfit(0);
   if((PL > 0 && totalPL >= PL) || (PL < 0 && totalPL <= PL))
     {
      myOrderClose(Symbol(), OP_BUY, 100, "");
      myOrderClose(Symbol(), OP_SELL, 100, "");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
  {
   bool ret = condition && !crossed[i];
   crossed[i] = condition;
   return(ret);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAlert(string sym, string type, string message)
  {
   if(type == "print")
      Print(message);
   else
      if(type == "error")
        {
         Print(type + " | @  " + sym + "," + IntegerToString(Period()) + " | " + message);
         bot.SendMessage(ChatID, type + " | @  " + sym + "," + IntegerToString(Period()) + " | " + message);
        }
      else
         if(type == "order")
           {
           }
         else
            if(type == "modify")
              {
              }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type)
         continue;
      result++;
     }
   return(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalOpenProfit(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
         continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL))
         continue;
      result += OrderProfit();
     }
   return(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int myOrderSend(string sym, int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   long chatId = ChatID;
   if(!IsTradeAllowed())
      return(-1);
   int ticket = -1;
   int retries = 0;
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "(" + ordername + ")";
//test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert(sym, "print", "Order" + ordername_ + " not sent, hedging not allowed");
      bot.SendMessage(ChatID, "Order" + ordername_ + "not sent, hedging not allowed");
      return(-1);
     }
//test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
      || (type % 2 == 1 && short_trades >= MaxShortTrades)
      || (long_trades + short_trades >= MaxOpenTrades)
      || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
      || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
      || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
     )
     {
      myAlert(sym, "print", "Order" + ordername_ + " not sent, maximum reached");
      bot.SendMessage(chatId, "Order" + ordername_ + " not sent, maximum reached");
      return(-1);
     }
   double SL = 0, TP = 0;
//prepare to send order
   while(IsTradeContextBusy())
      Sleep(100);
   RefreshRates();
   if(type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP)
     {
      price = MarketInfo(sym, MODE_ASK);
      SL = price - stoploss * MarketInfo(sym, MODE_POINT);
      TP = price + takeprofit * MarketInfo(sym, MODE_POINT);
     }
   else
      if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
        {
         price =  price = MarketInfo(sym, MODE_BID);
         SL = price + stoploss * MarketInfo(sym, MODE_POINT);
         TP = price - takeprofit * MarketInfo(sym, MODE_POINT);
        }
      else
         if(price < 0) //invalid price for pending order
           {
            myAlert(sym, "order", "Order" + ordername_ + " not sent, invalid price for pending order");
            bot.SendMessage(ChatID, "Order" + ordername_ + " not sent, invalid price for pending order");
            return(-1);
           }
   int clr = (type % 2 == 1) ? clrWhite : clrGold;
   while(ticket < 0 && retries < OrderRetry + 1)
     {
      LotDigits = (int)MarketInfo(sym, MODE_LOTSIZE);
      ticket = OrderSend(sym, type,
                         NormalizeDouble(volume, LotDigits),
                         NormalizeDouble(price, (int)MarketInfo(sym, MODE_DIGITS))
                         ,
                         MaxSlippage,
                         SL, TP,
                         ordername,
                         MagicNumber,
                         0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert(sym, "print", "OrderSend" + ordername_ + " error #" + IntegerToString(err) + " " + ErrorDescription(err));
         Sleep(OrderWait * 1000);
        }
      if(ticket < 0)
        {
         myAlert(sym, "error", "OrderSend" + ordername_ + " failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
         bot.SendMessage(ChatID, "OrderSend" + ordername_ + " failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
         return(-1);
        }
      string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
      myAlert(sym, "order", "Order sent" + ordername_ + ": " + typestr[type] + " " + sym + " Magic #" + IntegerToString(MagicNumber));
      bot.SendMessage(ChatID, "Order sent" + ordername_ + ": " + typestr[type] + sym + " " + (string)MagicNumber + " " + IntegerToString(MagicNumber));
      retries++;
     }
   return ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int myOrderModify(string sym, int ticket, double SL, double TP) //modify SL and TP (absolute price), zero targets do not modify
  {
   if(!IsTradeAllowed())
      return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = stoploss;
   TP = takeprofit;
   SL = NormalizeDouble(SL, (int)MarketInfo(sym, MODE_DIGITS));
   TP =  NormalizeDouble(TP, (int)MarketInfo(sym, MODE_DIGITS));
   if(SL < 0)
      SL = 0;
   if(TP < 0)
      TP = 0;
//prepare to select order
   while(IsTradeContextBusy())
      Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert(sym, "error", "OrderSelect failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
      bot.SendMessage(ChatID, "OrderSelect failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
      return(-1);
     }
//prepare to modify order
   while(IsTradeContextBusy())
      Sleep(100);
   RefreshRates();
   if(CompareDoubles(SL, 0))
      SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0))
      TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit()))
      return(0); //nothing to do
   while(!success && retries < OrderRetry + 1)
     {
      success = OrderModify(ticket,
                            NormalizeDouble(OrderOpenPrice(),
                                            (int) MarketInfo(sym, MODE_DIGITS)),
                            NormalizeDouble(SL, (int) MarketInfo(sym, MODE_DIGITS)),
                            NormalizeDouble(TP, (int) MarketInfo(sym, MODE_DIGITS)), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert(sym, "print", "OrderModify error #" + IntegerToString(err) + " " + ErrorDescription(err));
         bot.SendMessage(ChatID, "OrderModify error #" + IntegerToString(err) + " " + ErrorDescription(err));
         Sleep(OrderWait * 1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert(sym, "error", "OrderModify failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
      bot.SendMessage(ChatID, "OrderModify failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket=" + IntegerToString(ticket);
   if(!CompareDoubles(SL, 0))
      alertstr = alertstr + " SL=" + DoubleToString(SL);
   if(!CompareDoubles(TP, 0))
      alertstr = alertstr + " TP=" + DoubleToString(TP);
   myAlert(sym, "modify", alertstr);
   bot.SendMessage(ChatID, "Modify " + alertstr);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myOrderClose(string sym, int type, double volumepercent, string ordername) //close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
  {
   if(!IsTradeAllowed())
      return;
   if(type > 1)
     {
      myAlert(sym, "error", "Invalid type in myOrderClose");
      bot.SendMessage(ChatID, "Invalid type in myOrderClose");
      return;
     }
   bool success = false;
   int retries = 0;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "(" + ordername + ")";
   int total = OrdersTotal();
   ulong orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy())
         Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != sym || OrderType() != type)
         continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   LotDigits = (int)MarketInfo(sym, MODE_LOTSIZE);
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect((int)orderList[i][1], SELECT_BY_TICKET, MODE_TRADES))
         continue;
      while(IsTradeContextBusy())
         Sleep(100);
      RefreshRates();
      double price = (type == OP_SELL) ? MarketInfo(sym, MODE_ASK) : MarketInfo(sym, MODE_BID);
      double volume = NormalizeDouble(OrderLots() * volumepercent * 1.0 / 100, LotDigits);
      if(NormalizeDouble(volume, (int)MarketInfo(sym, MODE_LOTSIZE)) == 0)
         continue;
      success = false;
      retries = 0;
      while(!success && retries < OrderRetry + 1)
        {
         success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, (int)MarketInfo(sym, MODE_DIGITS)), MaxSlippage, clrWhite);
         if(!success)
           {
            err = GetLastError();
            myAlert(sym, "print", "OrderClose" + ordername_ + " failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
            bot.SendMessage(ChatID, "OrderClose" + ordername_ + " failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
            Sleep(OrderWait * 1000);
           }
         retries++;
        }
      if(!success)
        {
         myAlert(sym, "error", "OrderClose" + ordername_ + " failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
         bot.SendMessage(ChatID, "OrderClose" + ordername_ + " failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
         return;
        }
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   if(success)
     {
      myAlert(sym, "order", "Orders closed" + ordername_ + ": " + typestr[type] + " " + sym + " Magic #" + IntegerToString(MagicNumber));
      bot.SendMessage(ChatID, "Orders closed" + ordername_ + ": " + typestr[type] + " " + sym + " Magic #" + IntegerToString(MagicNumber));
     }
  }

//+------------------------------------------------------------------+
//|   OnChartEvent                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   comment.OnChartEvent(id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTimer3();
//--- show init error
   if(init_error != 0)
     {
      //--- show error on display
      CustomInfo info;
      GetCustomInfo(info, init_error, InpLanguage);
      //---
      comment.Clear();
      comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);
      comment.SetText(1, info.text1, LOSS_COLOR);
      if(info.text2 != "")
         comment.SetText(2, info.text2, LOSS_COLOR);
      comment.Show();
      return;
     }
//--- show web error
   if(run_mode == RUN_LIVE)
     {
      //--- check bot registration
      if(time_check < TimeLocal() - PeriodSeconds(PERIOD_H1))
        {
         time_check = TimeLocal();
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            //---
            web_error = bot.GetMe();
            if(web_error != 0)
              {
               //---
               if(web_error == ERR_NOT_ACTIVE)
                 {
                  time_check = TimeCurrent() - PeriodSeconds(PERIOD_H1) + 300;
                 }
               //---
               else
                 {
                  time_check = TimeCurrent() - PeriodSeconds(PERIOD_H1) + 5;
                 }
              }
            if(Move_TP_to_Breakeven)
               timelockaction();
           }
         else
           {
            web_error = ERR_NOT_CONNECTED;
            time_check = 0;
           }
        }
      //--- show error
      if(web_error != 0)
        {
         comment.Clear();
         comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);
         if(
#ifdef __MQL4__ web_error==ERR_FUNCTION_NOT_CONFIRMED #endif
#ifdef __MQL5__ web_error==ERR_FUNCTION_NOT_ALLOWED #endif
         )
           {
            time_check = 0;
            CustomInfo info = {0};
            GetCustomInfo(info, web_error, InpLanguage);
            comment.SetText(1, info.text1, LOSS_COLOR);
            comment.SetText(2, info.text2, LOSS_COLOR);
           }
         else
            comment.SetText(1, GetErrorDescription(web_error, InpLanguage), LOSS_COLOR);
         comment.Show();
         return;
        }
     }
//---
   bot.GetUpdates();
//---
   if(run_mode == RUN_LIVE)
     {
      comment.Clear();
      comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);
      comment.SetText(1, StringFormat("%s: %s", (InpLanguage == LANGUAGE_EN) ? "Bot " : "Имя Бота", bot.Name()), CAPTION_COLOR);
      comment.SetText(2, StringFormat("%s: %d", (InpLanguage == LANGUAGE_EN) ? "Chats" : "Чаты", bot.ChatsTotal()), CAPTION_COLOR);
      comment.Show();
     }
//---
   bot.ProcessMessages();
  }



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculates(string sym)
  {
   const int rates_total = 0;
   int prev_calculated = 7;
   datetime time[];
   double open[];
   double high[];
   double low[];
   double close[];
   long tick_volume[];
   long volume[];
   int spread[];
//--
//--- BY AUTHORS WITH SOME MODIFICATIONS
//--- define the XML Tags, Vars
   string sTags[7] = {"<title>", "<country>", "<date><![CDATA[", "<time><![CDATA[", "<impact><![CDATA[", "<forecast><![CDATA[", "<previous><![CDATA["};
   string eTags[7] = {"</title>", "</country>", "]]></date>", "]]></time>", "]]></impact>", "]]></forecast>", "]]></previous>"};
   int index = 0;
   int next = -1;
   int BoEvent = 0, begin = 0, end = 0;
   string myEvent = "";
//--- Minutes calculation
   datetime EventTime = 7;
   int EventMinute = 7;
//--- split the currencies into the two parts
   string MainSymbol = StringSubstr(sym, 0, 3);
   string SecondSymbol = StringSubstr(sym, 3, 3);
//--- loop to get the data from xml tags
   while(true)
     {
      BoEvent = StringFind(sData, "<event>", BoEvent);
      if(BoEvent == -1)
         break;
      BoEvent += 7;
      next = StringFind(sData, "</event>", BoEvent);
      if(next == -1)
         break;
      myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
      BoEvent = next;
      begin = 0;
      for(int i = 0; i < 7; i++)
        {
         Event[index][i] = "";
         next = StringFind(myEvent, sTags[i], begin);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next == -1)
            continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin = next + StringLen(sTags[i]);
            end = StringFind(myEvent, eTags[i], begin);
            //---Find start of end tag and Get data between start and end tag
            if(end > begin && end != -1)
               Event[index][i] = StringSubstr(myEvent, begin, end - begin);
           }
        }
      //--- filters that define whether we want to skip this particular currencies or events
      if(ReportActive && MainSymbol != Event[index][COUNTRY] && SecondSymbol != Event[index][COUNTRY])
         continue;
      if(!IsCurrency(Event[index][COUNTRY]))
         continue;
      if(!IncludeHigh && Event[index][IMPACT] == "High")
         continue;
      if(!IncludeMedium && Event[index][IMPACT] == "Medium")
         continue;
      if(!IncludeLow && Event[index][IMPACT] == "Low")
         continue;
      if(!IncludeSpeaks && StringFind(Event[index][TITLE], "Speaks") != -1)
         continue;
      if(!IncludeHolidays && Event[index][IMPACT] == "Holiday")
         continue;
      if(Event[index][TIME] == "All Day" ||
         Event[index][TIME] == "Tentative" ||
         Event[index][TIME] == "")
         continue;
      if(FindKeyword != "")
        {
         if(StringFind(Event[index][TITLE], FindKeyword) == -1)
            continue;
        }
      if(IgnoreKeyword != "")
        {
         if(StringFind(Event[index][TITLE], IgnoreKeyword) != -1)
            continue;
        }
      //--- sometimes they forget to remove the tags :)
      if(StringFind(Event[index][TITLE], "<![CDATA[") != -1)
         StringReplace(Event[index][TITLE], "<![CDATA[", "");
      if(StringFind(Event[index][TITLE], "]]>") != -1)
         StringReplace(Event[index][TITLE], "]]>", "");
      if(StringFind(Event[index][TITLE], "]]>") != -1)
         StringReplace(Event[index][TITLE], "]]>", "");
      //---
      if(StringFind(Event[index][FORECAST], "&lt;") != -1)
         StringReplace(Event[index][FORECAST], "&lt;", "");
      if(StringFind(Event[index][PREVIOUS], "&lt;") != -1)
         StringReplace(Event[index][PREVIOUS], "&lt;", "");
      //--- set some values (dashes) if empty
      if(Event[index][FORECAST] == "")
         Event[index][FORECAST] = "---";
      if(Event[index][PREVIOUS] == "")
         Event[index][PREVIOUS] = "---";
      //--- Convert Event time to MT4 time
      EventTime = datetime(MakeDateTime(Event[index][DATE], Event[index][TIME]));
      //--- calculate how many minutes before the event (may be negative)
      EventMinute = int(EventTime - TimeGMT()) / 60;
      //--- only Alert once
      if(EventMinute == 0 && AlertTime != EventTime)
        {
         FirstAlert = false;
         SecondAlert = false;
         AlertTime = EventTime;
        }
      //--- Remove the event after x minutes
      if(EventMinute + EventDisplay < 0)
         continue;
      //--- Set buffers
      ArrayResize(MinuteBuffer, index + 23, 0);
      ArrayResize(ImpactBuffer, index + 23, 0);
      MinuteBuffer[index] = EventMinute;
      ImpactBuffer[index] = ImpactToNumber(Event[index][IMPACT]);
      index++
      ;
     }
//--- loop to set arrays/buffers that uses to draw objects and alert
   for(int i = 0; i < index; i++)
     {
      for(int n = i; n < 10; n++)
        {
         eTitle[n]    = Event[i][TITLE];
         eCountry[n]  = Event[i][COUNTRY];
         eImpact[n]   = Event[i][IMPACT];
         eForecast[n] = Event[i][FORECAST];
         ePrevious[n] = Event[i][PREVIOUS];
         eTime[n]     = datetime(MakeDateTime(Event[i][DATE], Event[i][TIME])) - TimeGMTOffset();
         eMinutes[n]  = (int)MinuteBuffer[i];
         //--- Check if there are any events
         if(ObjectFind(eTitle[n]) != 0)
            IsEvent = true;
        }
     }
//--- check then call draw / alert function
   if(IsEvent)
      DrawEvents();
   else
      Draw("no more events", "NO MORE EVENTS", 14, "Arial Black", RemarksColor, 2, 10, 30, "Get some rest!");
//--- call info function
   if(ShowInfo)
      SymbolInfo(sym);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int i = MathRand() % SymbolsTotal(false);
   if(i < SymbolsTotal(false))
     {
      //false is used to work with all symbols
      string sym = SymbolName(i, false);
      printf("sym :" + sym + (string)i);
      OnCalculates(sym);
      //MOVE TP AND SL
      double TradeSize = 0, SL = stoploss, TP = takeprofit, price;
      int ticket = -1;
      for(i = 0; i <= OrdersTotal(); i++)
        {
         if(OrdersTotal() > 0 && OrderSelect(i, SELECT_BY_TICKET, MODE_TRADES) && OrderType() == OP_BUY && OrderSymbol() == sym)
           {
            price = MarketInfo(sym, MODE_ASK);
            if(price - TP > MaxTP)
               TP = price - MaxTP;
            if(price - TP < MinTP)
               TP = price - MinTP;
            myOrderModify(sym, ticket, SL, 0);
            myOrderModify(sym, ticket, 0, TP);
           }
         if(OrdersTotal() > 0 && OrderSelect(i, SELECT_BY_TICKET, MODE_TRADES) && OrderType() == OP_SELL && sym == OrderSymbol())
           {
            price = MarketInfo(sym, MODE_BID);
            if(price - TP < MinTP)
               TP = price - MinTP;
            //not autotrading => only send alert
            myOrderModify(sym, ticket, SL, 0);
            myOrderModify(sym, ticket, 0, TP);
           }
        }
     }
  }


enum ENUM_UNIT
  {
   InPips,                 // SL in pips
   InDollars               // SL in dollars
  };
/** Now, MarketData and MarketRates flags can change in real time, according with
 *  registered symbols and instruments.
 */




int GridError;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|   TRADE EXPERT parameters                                               |
//+------------------------------------------------------------------+

input string auth;//==========AUTH PARAMS ================
input ENUM_LICENSE_TYPE licenseType = 0;
input string LICENSE_KEY = "3EEEE4";
input string email = "test";
input string password = "12349";

input const string ss15 ;// "============== TELEGRAM BOT SETTINGS ================";


input string channel = "tradeexpert_infos"; // TELEGRAM CHANNEL
input long chatID = -1001648392740; // GROUP or BOT CHAT ID

input Answer telegram = yes;
input bool UseAllSymbol = true;
input bool trade0 = false;//Trade News
bool now = false;

//+------------------------------------------------------------------+
//|                         NEWS                                         |
//+------------------------------------------------------------------+
bool AvoidNews = trade0;

//-------------------------------------------- EXTERNAL VARIABLE ---------------------------------------------
//------------------------------------------------------------------------------------------------------------
extern bool    ReportActive      = true;                // Report for active chart only (override other inputs)
extern bool    IncludeHigh       = true;                 // Include high
extern bool    IncludeMedium     = true;                 // Include medium
extern bool    IncludeLow        = true;                 // Include low
extern bool    IncludeSpeaks     = true;                 // Include speaks
extern bool    IncludeHolidays   = false;                // Include holidays
extern string  FindKeyword       = "FOMC";                   // Find keyword
extern string  IgnoreKeyword     = "";                   // Ignore keyword
extern bool    AllowUpdates      = true;                 // Allow updates
extern int     UpdateHour        = 4;                    // Update every (in hours)
input string   lb_0              = "";                   // ------------------------------------------------------------
input string   lb_1              = "";                   // ------> PANEL SETTINGS
extern bool    ShowPanel         = true;                 // Show panel
extern bool    AllowSubwindow    = false;                // Show Panel in sub window
extern ENUM_BASE_CORNER Corner   = 2;                    // Panel side
extern string  PanelTitle = "Forex Calendar @ Forex Factory"; // Panel title
extern color   TitleColor        = C'46,188,46';         // Title color
extern bool    ShowPanelBG       = true;                 // Show panel backgroud
extern color   Pbgc              = C'25,25,25';          // Panel backgroud color
extern color   LowImpactColor    = C'91,192,222';        // Low impact color
extern color   MediumImpactColor = C'255,185,83';        // Medium impact color
extern color   HighImpactColor   = C'217,83,79';         // High impact color
extern color   HolidayColor      = clrOrchid;            // Holidays color
extern color   RemarksColor      = clrGray;              // Remarks color
extern color   PreviousColor     = C'170,170,170';       // Forecast color
extern color   PositiveColor     = C'46,188,46';         // Positive forecast color
extern color   NegativeColor     = clrTomato;            // Negative forecast color
extern bool    ShowVerticalNews  = true;                 // Show vertical lines
extern int     ChartTimeOffset   = -6;                    // Chart time offset (in hours)
extern int     EventDisplay      = 10;                   // Hide event after (in minutes)
input string   lb_2              = "";                   // ------------------------------------------------------------

input string   lb_4              = "";                   // ------------------------------------------------------------
input string   lb_5              = "";                   // ------> INFO SETTINGS
extern bool    ShowInfo          = true;                 // Show Symbol info ( Strength / Bar Time / Spread )
extern color   InfoColor         = C'255,185,83';        // Info color
extern int     InfoFontSize      = 10;                    // Info font size
input string   lb_6              = "";                   // ------------------------------------------------------------
input string   lb_7              = "";                   // ------> NOTIFICATION
input string   lb_8              = "";                   // *Note: Set (-1) to disable the Alert
extern int     Alert1Minutes     = 30;                   // Minutes before first Alert
extern int     Alert2Minutes     = 30;                   // Minutes before second Alert
extern bool    PopupAlerts       = true;                // Popup Alerts
extern bool    SoundAlerts       = true;                 // Sound Alerts
extern string  AlertSoundFile    = "news.wav";           // Sound file name
extern bool    EmailAlerts       = true;                // Send email
extern bool    NotificationAlerts = false;               // Send push notification


//------------------------------------------------------------------------------------------------------------
//--------------------------------------------- INTERNAL VARIABLE --------------------------------------------
//--- Vars and arrays
string xmlFileName;
string sData;
string Event[200][7];
string eTitle[10], eCountry[10], eImpact[10], eForecast[10], ePrevious[10];
int eMinutes[10];
datetime eTime[10];
int x0, xx1, xx2, xxf, xp;
int Factor = 2;
//--- Alert
bool FirstAlert;
bool SecondAlert;
datetime AlertTime;
//--- Buffers
double MinuteBuffer[];
double ImpactBuffer[];
//--- time
datetime xmlModifed;
int TimeOfDay;
datetime Midnight;
bool IsEvent;



//+------------------------------------------------------------------+
//|   GetCustomInfo                                                  |
//+------------------------------------------------------------------+
void GetCustomInfo(CustomInfo &info,
                   const int _error_code,
                   const ENUM_LANGUAGES _lang)
  {
   switch(_error_code)
     {
#ifdef __MQL5__
      case ERR_FUNCTION_NOT_ALLOWED:
         info.text1 = (_lang == LANGUAGE_EN) ? "The URL does not allowed for WebRequest" : "Этого URL нет в списке для WebRequest.";
         info.text2 = TELEGRAM_BASE_URL;
         break;
#endif
#ifdef __MQL4__
      case ERR_FUNCTION_NOT_CONFIRMED:
         info.text1 = (_lang == LANGUAGE_EN) ? "The URL does not allowed for WebRequest" : "Этого URL нет в списке для WebRequest.";
         info.text2 = TELEGRAM_BASE_URL;
         break;
#endif
      case ERR_TOKEN_ISEMPTY:
         info.text1 = (_lang == LANGUAGE_EN) ? "The 'Token' parameter is empty." : "Параметр 'Token' пуст.";
         info.text2 = (_lang == LANGUAGE_EN) ? "Please fill this parameter." : "Пожалуйста задайте значение для этого параметра.";
         break;
     }
  }



//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer3()
  {
//---
   Print(INAME + ": xml file is out of date");
   xmlUpdate();
//---
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit3(const int reason)
  {
// Print(__FUNCTION__, " Terima Kasih - SignalForex.id");
//---
   for(int i = ObjectsTotal(); i >= 0; i--)
     {
      string name = ObjectName(i);
      if(StringFind(name, INAME) == 0)
         ObjectDelete(name);
     }
//--- Kill update timer only if removed
   if(reason == 1)
      EventKillTimer();
//---
  }
string sUrl = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml?version=d29b91da222cb3963b932ad3466d9973"; // ForexFactory NEWS URL (XML)

string newsfile = "news.csv";
//+-------------------------------------------------------------------------------------------+
//| Download XML file from forexfactory                                                       |
//| for windows 7 and later file path would be:                                               |
//| C:\Users\xxx\AppData\Roaming\MetaQuotes\Terminal\xxxxxxxxxxxxxxx\MQL4\Files\xmlFileName   |
//+-------------------------------------------------------------------------------------------+
void xmlDownload()
  {
//---
   ResetLastError();
   string FilePath = StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH), "\\MQL4\\files\\", newsfile);
   int FileGet = URLDownloadToFileW(NULL, sUrl, FilePath, 0, NULL);
   if(FileGet == 0)
      PrintFormat(INAME + ": %s file downloaded successfully!", newsfile);
//--- check for errors
   else
      PrintFormat(INAME + ": failed to download %s file, Error code = %d", newsfile, GetLastError());
//---
  }
//+------------------------------------------------------------------+
//| Read the XML file                                                |
//+------------------------------------------------------------------+
void xmlRead()
  {
//---
   ResetLastError();
   int FileHandle = FileOpen(newsfile, FILE_BIN | FILE_READ);
   if(FileHandle != INVALID_HANDLE)
     {
      //--- receive the file size
      ulong size = FileSize(FileHandle);
      //--- read data from the file
      while(!FileIsEnding(FileHandle))
         sData = FileReadString(FileHandle, (int)size);
      printf("read news :" + sData);
      //--- close
      FileClose(FileHandle);
     }
//--- check for errors
   else
      PrintFormat(INAME + ": failed to open %s file, Error code = %d", newsfile, GetErrorDescription(GetLastError(), 0));
//---
  }
//+------------------------------------------------------------------+
//| Check for update XML                                             |
//+------------------------------------------------------------------+
void xmlUpdate()
  {
//--- do not download on saturday
   if(TimeDayOfWeek(Midnight) == 6)
      return;
   else
     {
      Print(INAME + ": check for updates...");
      Print(INAME + ": delete old file");
      FileDelete(newsfile);
      xmlDownload();
      xmlRead();
      xmlModifed = (datetime)FileGetInteger(newsfile, FILE_MODIFY_DATE, false);
      PrintFormat(INAME + ": updated successfully! last modified: %s", (string)xmlModifed);
     }
//---
  }
//+------------------------------------------------------------------+
//| Draw panel and events on the chart                               |
//+------------------------------------------------------------------+
void DrawEvents()
  {
   string FontName = "Arial";
   int    FontSize = 8;
   string eToolTip = "";
//--- draw backbround / date / special note
   if(ShowPanel && ShowPanelBG)
     {
      eToolTip = "Hover on the Event!";
      Draw("BG", "gggg", 85, "Webdings", Pbgc, Corner, x0, 3, eToolTip);
      Draw("Date", DayToStr(Midnight) + ", " + MonthToStr() + " " + (string)TimeDay(Midnight), FontSize + 1, "Arial Black", TitleColor, Corner, xx2, 95, "Today");
      Draw("Title", PanelTitle, FontSize, FontName, TitleColor, Corner, xx1, 195, "Panel Title");
      Draw("Spreator", "------", 13, "Arial", RemarksColor, Corner, xx2, 183, eToolTip);
     }
//--- draw objects / alert functions
   for(int i = 0; i < 5; i++)
     {
      eToolTip = eTitle[i] + "\nCurrency: " + eCountry[i] + "\nTime left: " + (string)eMinutes[i] + " Minutes" + "\nImpact: " + eImpact[i];
      printf("Out0 :" + eToolTip);
      //--- impact color
      color EventColor = ImpactToColor(eImpact[i]);
      //--- previous/forecast color
      color ForecastColor = PreviousColor;
      if(ePrevious[i] > eForecast[i])
         ForecastColor = NegativeColor;
      else
         if(ePrevious[i] < eForecast[i])
            ForecastColor = PositiveColor;
      //--- past event color
      if(eMinutes[i] < 0)
         EventColor = ForecastColor = PreviousColor = RemarksColor;
      //--- panel
      if(ShowPanel)
        {
         //--- date/time / title / currency
         Draw("Event " + (string)i,
              DayToStr(eTime[i]) + "  |  " +
              TimeToStr(eTime[i], TIME_MINUTES) + "  |  " +
              eCountry[i] + "  |  " +
              eTitle[i], FontSize, FontName, EventColor, Corner, xx2, 70 - i * 15, eToolTip);
         //--- forecast
         Draw("Event Forecast " + (string)i, "[ " + eForecast[i] + " ]", FontSize, FontName, ForecastColor, Corner, xxf, 70 - i * 15,
              "Forecast: " + eForecast[i]);
         //--- previous
         Draw("Event Previous " + (string)i, "[ " + ePrevious[i] + " ]", FontSize, FontName, PreviousColor, Corner, xp, 70 - i * 15,
              "Previous: " + ePrevious[i]);
         //     bot.SendMessage(channel, DayToStr(eTime[i])+"  |  "+    TimeToStr(eTime[i],TIME_MINUTES)+"  |  "+eCountry[i]+"|"+ eTitle[i]);
         //--- forecast
        }
      //--- vertical news
      if(ShowVerticalNews)
         DrawLine("Event Line " + (string)i, eTime[i] + (ChartTimeOffset * 3600), EventColor, eToolTip);
      //--- Set alert message
      string AlertMessage = (string)eMinutes[i] + " Minutes until [" + eTitle[i] + "] Event on " + eCountry[i] +
                            "\nImpact: " + eImpact[i] +
                            "\nForecast: " + eForecast[i] +
                            "\nPrevious: " + ePrevious[i];
      //--- first alert
      if(Alert1Minutes != -1 && eMinutes[i] == Alert1Minutes && !FirstAlert)
        {
         setAlerts("First Alert! " + AlertMessage);
         FirstAlert = true;
         bot.SendMessage(channel, AlertMessage);
        }
      //--- second alert
      if(Alert2Minutes != -1 && eMinutes[i] == Alert2Minutes && !SecondAlert)
        {
         setAlerts("Second Alert! " + AlertMessage);
         bot.SendMessage(channel, AlertMessage);
         SecondAlert = true;
        }
      //--- break if no more data
      if(eTitle[i] == eTitle[i + 1])
        {
         Draw(INAME + " no more events", "NO MORE EVENTS! GET SOME REST. ", 8, "Arial", RemarksColor, Corner, xx2, 50 - i * 15, "Get some rest!");
         break;
        }
     }
//---
  }
//+-----------------------------------------------------------------------------------------------+
//| Subroutine: to ID currency even if broker has added a prefix to the symbol, and is used to    |
//| determine the news to show, based on the users external inputs - by authors (Modified)        |
//+-----------------------------------------------------------------------------------------------+
bool IsCurrency(string symbol)
  {
//---
   for(int jk = 0; jk < SymbolsTotal(false); jk++)
      if(symbol == StringSubstr(SymbolName(jk, false), 0, 3))
         return(true);
   return(false);
//---
  }
//+------------------------------------------------------------------+
//| Converts ff time & date into yyyy.mm.dd hh:mm - by deVries       |
//+------------------------------------------------------------------+
string MakeDateTime(string strDate, string strTime)
  {
//---
   int n1stDash = StringFind(strDate, "-");
   int n2ndDash = StringFind(strDate, "-", n1stDash + 1);
   string strMonth = StringSubstr(strDate, 0, 2);
   string strDay = StringSubstr(strDate, 3, 2);
   string strYear = StringSubstr(strDate, 6, 4);
   int nTimeColonPos = StringFind(strTime, ":");
   string strHour = StringSubstr(strTime, 0, nTimeColonPos);
   string strMinute = StringSubstr(strTime, nTimeColonPos + 1, 2);
   string strAM_PM = StringSubstr(strTime, StringLen(strTime) - 2);
   int nHour24 = StrToInteger(strHour);
   if((strAM_PM == "pm" || strAM_PM == "PM") && nHour24 != 12)
      nHour24 += 12;
   if((strAM_PM == "am" || strAM_PM == "AM") && nHour24 == 12)
      nHour24 = 0;
   string strHourPad = "";
   if(nHour24 < 10)
      strHourPad = "0";
   return(StringConcatenate(strYear, ".", strMonth, ".", strDay, " ", strHourPad, nHour24, ":", strMinute));
//---
  }
//+------------------------------------------------------------------+
//| set impact Color - by authors                                    |
//+------------------------------------------------------------------+
color ImpactToColor(string impact)
  {
//---
   if(impact == "High")
      return (HighImpactColor);
   else
      if(impact == "Medium")
         return (MediumImpactColor);
      else
         if(impact == "Low")
            return (LowImpactColor);
         else
            if(impact == "Holiday")
               return (HolidayColor);
            else
               return (RemarksColor);
//---
  }
//+------------------------------------------------------------------+
//| Impact to number - by authors                                    |
//+------------------------------------------------------------------+
int ImpactToNumber(string impact)
  {
//---
   if(impact == "High")
      return(3);
   else
      if(impact == "Medium")
         return(2);
      else
         if(impact == "Low")
            return(1);
         else
            return(0);
//---
  }
//+------------------------------------------------------------------+
//| Convert day of the week to text                                  |
//+------------------------------------------------------------------+
string DayToStr(datetime time)
  {
   int ThisDay = TimeDayOfWeek(time);
   string day = "";
   switch(ThisDay)
     {
      case 0:
         day = "Sun";
         break;
      case 1:
         day = "Mon";
         break;
      case 2:
         day = "Tue";
         break;
      case 3:
         day = "Wed";
         break;
      case 4:
         day = "Thu";
         break;
      case 5:
         day = "Fri";
         break;
      case 6:
         day = "Sat";
         break;
     }
   return(day);
  }
//+------------------------------------------------------------------+
//| Convert months to text                                           |
//+------------------------------------------------------------------+
string MonthToStr()
  {
   int ThisMonth = Month();
   string month = "";
   switch(ThisMonth)
     {
      case 1:
         month = "Jan";
         break;
      case 2:
         month = "Feb";
         break;
      case 3:
         month = "Mar";
         break;
      case 4:
         month = "Apr";
         break;
      case 5:
         month = "May";
         break;
      case 6:
         month = "Jun";
         break;
      case 7:
         month = "Jul";
         break;
      case 8:
         month = "Aug";
         break;
      case 9:
         month = "Sep";
         break;
      case 10:
         month = "Oct";
         break;
      case 11:
         month = "Nov";
         break;
      case 12:
         month = "Dec";
         break;
     }
   return(month);
  }
//+------------------------------------------------------------------+
//| Candle Time Left / Spread                                        |
//+------------------------------------------------------------------+
void SymbolInfo(string sym)
  {
//---
   string TimeLeft = TimeToStr(Time[0] + Period() * 60 - (int)TimeCurrent(), TIME_MINUTES | TIME_SECONDS);
   string Spread = DoubleToStr(MarketInfo(sym, MODE_SPREAD) / Factor, 1);
   double DayClose = iClose(sym, PERIOD_D1, 1);
   if(DayClose != 0)
     {
      double Strength = ((MarketInfo(sym, MODE_BID) - DayClose) / DayClose) * 100;
      string Label = "Strength " + DoubleToStr(Strength, 2) + "%" + " /Spread " + Spread + " /TimeLeft " + TimeLeft;
      ENUM_BASE_CORNER corner = 1;
      if(Corner == 1)
         corner = 3;
      string arrow = "q";
      if(Strength > 0)
         arrow = "p";
      string tooltip = StringFormat("strength:%d, spread :%d,Time :%s",
                                    Strength, Spread, TimeLeft);
      Draw(INAME + ": info", Label, InfoFontSize, "Calibri", InfoColor, corner, 200, 50, tooltip);
      Draw(INAME + ": info arrow", arrow, InfoFontSize + 4, "Wingdings 3", InfoColor, corner, 100, 50, tooltip);
     }
//---
  }
//+------------------------------------------------------------------+
//| draw event text                                                  |
//+------------------------------------------------------------------+
void Draw(string name, string label, int size, string font, color clr, ENUM_BASE_CORNER c, int x, int y, string tooltip)
  {
//---
   name = INAME + ": " + name;
   int windows = 0;
   if(AllowSubwindow && WindowsTotal() > 1)
      windows = 1;
   ObjectDelete(name);
   ObjectCreate(name, OBJ_LABEL, windows, 0, 0);
   ObjectSetText(name, label, size, font, clr);
   ObjectSet(name, OBJPROP_CORNER, c);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
//--- justify text
   ObjectSet(name, OBJPROP_ANCHOR, 2);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
   ObjectSet(name, OBJPROP_SELECTABLE, 0);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lots = GetLotSize(money_management);
//+------------------------------------------------------------------+
//| draw vertical lines                                              |
//+------------------------------------------------------------------+
void DrawLine(string name, datetime time, color clr, string tooltip)
  {
//---
   name = INAME + ": " + name;
   ObjectDelete(name);
   ObjectCreate(name, OBJ_VLINE, 0, time, 0);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_STYLE, 2);
   ObjectSet(name, OBJPROP_WIDTH, 5);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
//---
  }






//+------------------------------------------------------------------+
//| Notifications                                                    |
//+------------------------------------------------------------------+
void setAlerts(string message)
  {
//---
   if(PopupAlerts)
      Alert(message);
   if(SoundAlerts)
      PlaySound(AlertSoundFile);
   if(NotificationAlerts)
      SendNotification(message);
   if(EmailAlerts)
      SendMail(INAME, message);
//---
  }



//+------------------------------------------------------------------+
