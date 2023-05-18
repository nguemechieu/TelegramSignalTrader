//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Macro substitutions                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with trading classes                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  Logging level                                                   |
//+------------------------------------------------------------------+

//--- enums
enum ENUM_BUTTONS
  {
   BUTT_BUY,
   BUTT_BUY_LIMIT,
   BUTT_BUY_STOP,
   BUTT_BUY_STOP_LIMIT,
   BUTT_CLOSE_BUY,
   BUTT_CLOSE_BUY2,
   BUTT_CLOSE_BUY_BY_SELL,
   BUTT_SELL,
   BUTT_SELL_LIMIT,
   BUTT_SELL_STOP,
   BUTT_SELL_STOP_LIMIT,
   BUTT_CLOSE_SELL,
   BUTT_CLOSE_SELL2,
   BUTT_CLOSE_SELL_BY_BUY,
   BUTT_DELETE_PENDING,
   BUTT_CLOSE_ALL,
   BUTT_PROFIT_WITHDRAWAL,
   BUTT_SET_STOP_LOSS,
   BUTT_SET_TAKE_PROFIT,
   BUTT_TRAILING_ALL
  };
//+------------------------------------------------------------------+

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
 enum ENUMS_TIMEFRAMES {//CUSTOM TIMEFRAMES
    PERIOD_1_MIN=(int)PERIOD_MN1,//1 min
    PERIOD_5_MIN=(int)PERIOD_M5,//5 min
    PERIOD_15_MIN=(int)PERIOD_M15,//15 min
    PERIOD_30_MIN=(int)PERIOD_M30,//30 min
    PERIOD_1_HOUR=(int)PERIOD_H1,//1 H
    PERIOD_2_HOURS=120,//2 H
    PERIOD_3_HOURS=180,//3 H
    PERIOD_4_HOURS=240,//4 H
    PERIOD_DAY=(int)PERIOD_D1,// 1 DAY
    PERIOD_WEEKS=(int)PERIOD_W1,//1 WEEK
    PERIOD_MONTHS=(int)PERIOD_MN1,//1 MONTH
    PERIOD_YEARS=518400// 1 YEAR
}
;

enum ENUMS_TRADE_ACTIONS{
NO_TRADE_ACTIONS=0,//NO TRADE ACTION FOUND
OPEN_BUY_ORDER=1,//OPEN  MARKET BUY  ORDER

OPEN_SELL_ORDER=2,//OPEN  MARKET SELL ORDER
OPEN_BUYLIMIT_ORDER=3,//OPEN   BUYLIMIT  ORDER

OPEN_SELLLIMIT_ORDER=4,//OPEN  SELLLIMT  ORDER
OPEN_BUYSTOP_ORDER=5,//OPEN  BUYSTOP  ORDER
OPEN_SELLSTOP_ORDER=6,//OPEN  SELLSTOP   ORDER



CLOSE_BUY_ORDER=7,//CLOSE  MARKET BUY  ORDER

CLOSE_SELL_ORDER=8,//CLOSE  MARKET SELL ORDER
CLOSE_BUYLIMIT_ORDER=9,//CLOSE  BUYLIMIT  ORDER

CLOSE_SELLLIMIT_ORDER=10,//CLOSE  SELLLIMT  ORDER
CLOSE_BUYSTOP_ORDER=11,//CLOSE BUYSTOP  ORDER
CLOSE_SELLSTOP_ORDER=12,//CLOSE SELLSTOP   ORDER

CHECK_ACCOUNT_FREE_MARGIN=13,//CHECK_ACCOUNT_FREE_MARGIN
CHECK_ACCOUNT_BALANCE=14,//CHECK_ACCOUNT_BALANCE

CHECK_ACCOUNT_MARGIN_REQUIRED=15,//CHECK_ACCOUNT_MARGIN_REQUIRED
CONTROL_PROFITS=16,//CONTROL_PROFITS
CONTROL_LOSSES=17//CONTROL LOSSES

};//GET TRADE BEHAVIOURS


enum ENUMS_CHAT_ACTIONS{
ACTIONS_TYPING,//Typing...
ACTIONS_SEND_EMAIL,//ACTIONS_SEND_EMAIL
ACTIONS_SEND_TEXT,//SEND TEXT
ACTIONS_WRITING,//Writting
ACTIONS_SEND_SCREESHOT//ACTIONS_SEND_SCREESHOT

};//GET CHAT BEHAVIOURS

enum ENUMS_FILE_ACTIONS{
ACTIONS_OPEN_FILE,

ACTIONS_CLOSE_FILE,

ACTIONS_WRITING_FILE,
ACTIONS_DELETE_FILE,
ACTIONS_SAVE_FILE,
ACTIONS_FILE_NOT_SAVE,
ACTIONS_OPEN_FILE_NOT_OPEN
};//GET FILES BEHAVIOURS




enum ENUM_MODE
  {
   FULL/*Full*/,
   COMPACT/*Compact*/,
   MINI/*Mini*/
  };
 







