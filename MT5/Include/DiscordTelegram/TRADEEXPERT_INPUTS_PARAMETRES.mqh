//+------------------------------------------------------------------+
//|                                TRADEEXPERT_INPUTS_PARAMETRES.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property strict

#include <DiscordTelegram/TradeExpert_Variables.mqh>





#include <DiscordTelegram/Position.mqh>
#include <DiscordTelegram/HistoryPosition.mqh>

#include <DiscordTelegram/Trade.mqh>

#include <DiscordTelegram/MyBot.mqh>

CArrayString UsedSymbols[100];
CPosition *Positions[];
CPosition *SellPositions[];
CPosition *BuyPositions[];
COrder *Pendings[];
COrder *SellStopPendings[];
COrder *BuyStopPendings[];
COrder *SellLimitPendings[];
COrder *BuyLimitPendings[];
CHistoryPosition *Hist[];
  ENUMS_TIMEFRAMES indicatorTimeFrame[];
  ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;




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



//+------------------------------------------------------------------------------+
//|                        DEFINE  EA parameters                                                      |
//+------------------------------------------------------------------------------+

#define  SEPARATOR "---------------------------"


input const string  menu0="========= User  Configuration  ============";

input ENUM_LANGUAGES InpLanguage=LANGUAGE_EN;
ENUM_LANGUAGES m_lang=InpLanguage;

//====================  USER PARAMETERS ======================

input ENUM_LICENSE_TYPE LicenseMode=LICENSE_DEMO;//EA License Mode
input string License="none";// EA License




string EA_Name="TFM EA v4.00";

extern string     conctact          = "===== For enquiries Contact +13022764379 on WhatApps====="; //====Contact NGUEMECHIEU@LIVE.COM=====
extern int        MT4account        = 1234567;     // MT4 Number/ Pascode

extern  string  menu1="========= TradeExpert Bot Configuration  ============";


input Platform InpLatform=TELEGRAM;// SELECT SIGNAL PLATFORM


input ENUM_UPDATE_MODE InpUpdateMode=UPDATE_FAST ;//UPDATE MODE
//You can edit these externs freely *******/

input string user_account="8848155";
input string user_password="Bigboss307#";
input string servers ="OANDA-v20 Live-1";//SERVER IP ADDRESS/HOSTNAME;
extern string _username ="bigbossmanager"   ;//platform username:
extern string _password = "Bigboss307#";//platform  password:
extern string _message  =   "WELCOME TO TRADE_EXPERT";



#define SCREENSHOT_FILENAME "_screenshot.gif"


input bool UseBot=true; // Use Bot  ? (TRUE/FALSE)
extern string     InpTocken   = "2032573404:AAGImbZXeATS-XMutlqlJC8hgOP1BMlrcKM";//API TOCKEN
extern string     InpChannel = "tradeexpert_infos";//CHANNEL NAME
extern long  InpChannelChatID=-1001659738763;
extern long InpChatID2=-1001648392740;//Chat ID
extern long InpChatID= 805814430;//private chat ID
input bool InpToChannel=true;
input bool InpTochat=true;

input string UserName="noel";//EA UserName
input string  InpUserNameFilter="noel, Olusegun";//EA UserName Filter

input bool SendScreenshot=true;//Send Screenshot ?(Yes/No)
input string google_url="https://nfs.faireconomy.media/ff_calendar_thisweek.json?version=393359e9932452a2579e1e46e6e3319a";//news url
input const string InpFileName="report.csv";    // File Name
input string InpDirectoryName="MQL4";   // Directory name
input int    InpEncodingType=FILE_ANSI; // ANSI=32 or UNICODE=64




input string Template="TradeExpert";//Default Template (for signal screenshot)
input ENUMS_TIMEFRAMES InpTimFrame=PERIOD_DAY;
input bool UseMaxspread=false;

input const string  menu2="========= Trading Time Configuration  ============";

input Answer UseTime=No;
int offset=(int)(TimeCurrent()-TimeLocal());//Auto GMT Shift
extern int NextOpenTradeAfterBars = 12; //Next open trade after time
extern int TOD_From_Hour = 09; //Time of the day (from hour)
extern int TOD_From_Min = 45; //Time of the day (from min)
extern int TOD_To_Hour = 16; //Time of the day (to hour)
extern int TOD_To_Min = 15; //Time of the day (to min)
extern bool TradeMonday = true;
extern bool TradeTuesday = true;
extern bool TradeWednesday = true;
extern bool TradeThursday = true;
extern bool TradeFriday = true;
extern bool TradeSaturday = true;
extern bool TradeSunday = true;
extern int MaxTradeDurationBars = 12; //Maximum trade duration
input const string  menu3="========= Trade symbols&& size Configuration  ============";
input ENUM_SYMBOLS_MODE InpModeUsedSymbols   =  SYMBOLS_MODE_CURRENT;   // Mode of used symbols list
input string            InpUsedSymbols       =  "EURUSD,AUDUSD,EURAUD,EURCAD,EURGBP,EURJPY,EURUSD,GBPUSD,NZDUSD,USDCAD,USDJPY";  // List of used symbols (comma - separator)
input string InpCryptoSymbol="BTCUSG,ETHUSD,XLMUSD,RLCUSD,XRPUSD,LRCUSD,LTCUSD";

input Answer UseAllsymbol=Yes;//Use All symbols  ?(true/false)
input string sdf="=== Schedule Trade Symbols ===";
input Answer InpSelectPairs_By_Basket_Schedule =No;//Select Pairs By Schedule Time
input  string  symbolList1="USDCAD,EURUSD,AUDUSD";//BASKET LIST 1;
input datetime start1=D'2021.01.19 04:00';
input datetime stop1=D'2022.01.19 06:00';
input const string symbolList2="EURGBP,AUDCAD";//BASKET LIST 2;
input datetime start2=D'2022.01.19 09:00';
input datetime stop2=D'2022.01.20 11:00';
input  string symbolList3="USDJPY,AUDJPY";//BASKET LIST 3;
input  datetime start3=D'2022.01.18 14:00';
input datetime stop3=D'2022.01.18 15:00';

extern bool                   ShowDashboard = true;
input ENUM_MODE               SelectedMode = COMPACT; /*Dashboard (Size)*/


extern int        minbalance        =10;           //Min Equity Balance IN USD
double inpReqEquity                       = minbalance;                   // Min. Required Equity
input MONEYMANAGEMENT InpMoneyManagement=Risk_Percent_Per_Trade;


input string M1="==== Fix Size ========";
input double Fixed_size=0.01; //Fix Lot
input string  M2="======= Lot Optimize =========";
input double InpLot=0.01;//Lot
extern double     SubLots           = 0.02;        //Sub Lots
input double MaximumRisk             = 0.08;           // MaximumRisk
input double DecreaseFactor          = 3;              // DecreaseFactor
extern double     Lots              = 0.05;        //First Lots
extern double     Risk              = 10;           // Risk Percent

input string M3="===== Risk % Per Trade ========";
 double   Risk_Percentage=Risk; // Risk %
input string M4="==== POSITION SIZE ==========";
input double  Position_size=3000; //Position Size EXAMPLE LOT :5000
input string M5="===MARTINGALE /ANTIMARTINGALE===============";
extern double MM_Martingale_Start = 0.1;
extern double MM_Martingale_ProfitFactor = 1;
extern double MM_Martingale_LossFactor = 2;
extern bool MM_Martingale_RestartProfit = true;
extern bool MM_Martingale_RestartLoss = false;
extern int MM_Martingale_RestartLosses = 2;
extern int MM_Martingale_RestartProfits = 3;

input const string  menu4="========= Advance News trade Setting ============";

//--- input parameters 
input Answer sendnews=Yes;
input Answer sendorder =Yes;
input Answer sendclose=Yes;//Send order close msgs
input Answer InpTradeNews=Yes;// Allow Trade news
input bool sendcontroltrade=true;//Send Trade Advises messages
input bool showoverbought =true;//Send ov bought or ov sell


int Now=0;
datetime LastUpd=0;
string str1;
extern const string commen           ="==================="; // =========IN THE NEWS FILTER==========
extern bool    AvoidNews            = true;                // News Filter
extern bool    CloseBeforNews       = true;                // Close and Stop Order Before News


extern  int    AfterNewsStop        =59;                    // Stop Trading Before News Release (in Minutes)
extern  int    BeforeNewsStop       =59;                    // Start Trading After News Release (in Minutes)
extern bool    NewsLight            = true;                // Low Impact
extern bool    NewsMedium           = true;                // Middle News
extern bool    NewsHard             = true;                 // High Impact News
input  bool    NewsTunggal          =true; // Enable Keyword News
extern string  judulnews            ="FOMC"; // Keyword News
input int   Style          = 2;          // Line style
input int   Upd            = 86400;      // Period news updates in seconds
bool NewsFilter = FALSE;



bool  Vtunggal       = false;
bool  Vhigh          = false;
bool  Vmedium        = false;
bool  Vlow           = false;

 
extern string  NewsSymb             ="USD,EUR,GBP,CHF,CAD,AUD,NZD,JPY"; //Currency to display the news  
extern bool    CurrencyOnly         = false;                 // Only the current currencies
extern bool    DrawLines            = true;                 // Draw lines on the chart
extern bool    Next                 = false;                // Draw only the future of news line
input  bool    Signal               = false;                // Signals on the upcoming news
extern string noterf          = "-----< Other >-----";//=========================================


input  string  menu5="========= Trade Setting ============";

input MARKET_TYPES InpMarket_Type= FOREX;//MARKET TYPE;
input ExchangeName exchange;
input string api_key;
input string secret_key;


input string pUsername="nguemechieu@live.com";
input string pPasword="Bigboss307#";


extern TRADEMODE  inpTradeMode           = AutoTrade;        // Trade Mode
extern ORDERS_TYPE Order_Type= MARKET_ORDERS;
input TRADE_STYLES inpTradeStyle=BOTH;



input TRADE_STRATEGY inpOpenTradeStrategy=joint;

input double inpMaxSpread=20;//MAX SPREAD
//--- input variables
input ulong             InpMagic             =  123;  // Magic number
input double            InpLots              =  0.1;  // Lots
input uint              InpStopLoss          =  50;   // StopLoss in points
input uint              InpTakeProfit        =  50;   // TakeProfit in points
input uint              InpDistance          =  50;   // Pending orders distance (points)
input uint              InpDistanceSL        =  50;   // StopLimit orders distance (points)
input uint              InpSlippage          =  0;    // Slippage in points
input double            InpWithdrawal        =  10;   // Withdrawal funds (in tester)
input uint              InpButtShiftX        =  40;   // Buttons X shift 
input uint              InpButtShiftY        =  10;   // Buttons Y shift 
input uint              InpTrailingStop      =  50;   // Trailing Stop (points)
input uint              InpTrailingStep      =  20;   // Trailing Step (points)
input uint              InpTrailingStart     =  0;    // Trailing Start (points)
input uint              InpStopLossModify    =  20;   // StopLoss for modification (points)
input uint              InpTakeProfitModify  =  60;   // TakeProfit for modification (points)

input bool UsePartialClose                      = true;                  // Use Partial Close
input ENUM_UNIT PartialCloseUnit                = InPips;             // Partial Close Unit
input double PartialCloseTrigger                = 40;                    // Partial Close after
input double PartialClosePercent                = 0.5;                   // Percentage of lot size to close
input int MaxNoPartialClose                     = 1;                     // Max No of Partial Close
input string ___TRADE_MONITORING_TRAILING___    = "";                    // - Trailing Stop Parameters
input bool UseTrailingStop                      = true;                  // Use Trailing Stop
input ENUM_UNIT TrailingUnit                    = InPips;             // Trailing Unit
input double TrailingStart                      = 35;                   // Trailing Activated After
input double TrailingStep                       = 10;                   // Trailing Step
input double TrailingStop                       = 2;                    // Trailing Stop
input string ___TRADE_MONITORING_BE_________    = "";                    // - Break Even Parameters
input bool UseBreakEven                         = true;                  // Use Break Even
input ENUM_UNIT BreakEvenUnit                   = InPips;             // Break Even Unit
input double BreakEvenTrigger                   = 30;                   // Break Even Trigger
input double BreakEvenProfit                    = 1;                   // Break Even Profit
input int MaxNoBreakEven                        = 1;                     // Max No of Break Even
extern Answer     DeletePendingOrder       = Yes;          //Delete Pending Order
extern int        orderexp          = 43;           //Pending order Experation (inBars)
extern caraclose  closetype         = opposite;        //Choose Closing Type

extern bool        OpenNewBarIndicator           = true;        //Open New Bar Indicator

input bool DebugTrailingStop         = true;           // Trailing Stop Infos in Journal
input bool DebugBreakEven            = true;           // Break Even Infos in Journal
input bool DebugUnit                 = true;           // SL TP Trail BE Units Infos in Journal (in tester)
input bool DebugPartialClose         = true;           // Partial close Infos in Journal
input Answer UseFibo_TP=Yes;//Use Fibo take profit?(Yes/No)

//extern bool     snr           = TRUE;           //Use Support & Resistance
extern bool    showfibo       = true;           // Show Fibo Line
extern bool Show_Support_Resistance=true;//Show Support & Resistance lines
extern  ENUMS_TIMEFRAMES snrperiod     = PERIOD_30_MIN;         //Support & Resistance Time Frame

extern Answer      sendTradesignal       = Yes; //Send Strategy Trade Signal
input int MagicNumber=3123456;//Magic Number
extern int MaxSlippage = 0; //Slippages
input ENUM_UNIT TakeProfitUnit       = InDollars;      // Take Profit Unit
extern double MaxTP = 40;//Take Profit Value
double inpTP= MaxTP;

input ENUM_UNIT StopLossUnit         = InDollars;      // Stop Loss Unit
input double MaxSL = 40;// Stop Loss Value
double inpSL                   = MaxSL;

double MinTP=MaxTP/2;
double MinSL=MaxTP/2;
extern bool closeTradesAtPL=false;//Use Close trade
extern double CloseAtPL = 50; //Close trade if total profit & loss exceed
extern double PriceTooClose =5; // Price to close
extern int  orderdistance     = 30;          //Order Distance
input ENUM_UNIT OrderDistanceUnit               = InPips; // Order Distance Unit
double inpStopDis = orderdistance; // Order Distance
input bool DeletePendingOrders = true;                  // Delete Pending Orders
input bool UseTrailingOrders=true;
input int inpPendingBar = 5;                     // Delete Pending After (bars)
extern int MaxOpenTrades = 12;//Maximum Open Trades
extern int MaxLongTrades = 5;//Max LongTrades
extern int MaxShortTrades = 5;// Max ShortTrades
extern int MaxPendingOrders = 5;//Max PendingOrders
extern int MaxLongPendingOrders = 5;//Max LongPendingOrders
double Trail_Above =TrailingStart;//Trailing above
double Trail_Step = TrailingStep;// Trailing steps
extern int MaxShortPendingOrders = 5;//Max ShortPendingOrders
extern int PendingOrderExpirationBars = 12; //pending order expiration
extern double DeleteOrderAtDistance = 100; //delete order when too far from current price
extern bool Hedging = true;//Allow  Hedging ?(true/false)
input int NextOpenTradeAfterMinutes=30;//Next Open Trade After ? Minutes
input int MaxTradeDurationHours =60;//Max Trade Duration in Hours
input int  PendingOrderExpirationMinutes=124;// Pending Order ExpirationMinutes
extern int OrderRetry = 5; //# Of retries if sending order returns error
extern int OrderWait = 5; //# Of seconds to wait if sending order returns error

input TIME_LOCK EA_TIME_LOCK_ACTION = closeprofit;// Time Lock Action
extern bool Send_Email = true; //Send email ?(true/false)
extern bool Audible_Alerts = true;
extern bool Push_Notifications = true;          
double xlimit=0,xstop=0,slimit=0,slstop=0,tplimit=0,tpstop=0;

int LotDigits; //initialized in OnInit
extern bool       BarBaru           = true;        //Open New Bar Indicator
extern   ORDERS_TYPE    Order_Types         = MARKET_ORDERS;      //Order Execution Mode 
extern bool    PendingOrderDeletes       = true;          //Delete Pending Order 
extern double     ProfitValue       = 30.0;         //Maximum Profit in %
input bool sendsupportandResisitance=true;
input string  ts1="=====  CHART  SETTINGS ===="; //===================


input string   lb_0              = "";                   // ------------------------------------------------------------
input string   lb_1              = "";                   // ------> PANEL SETTINGS
extern bool    ShowPanel         = true;                 // Show panel
input bool            AllowSubwindow    = false;                // Show Panel in sub window
extern ENUM_BASE_CORNER Corner   = 2;                    // Panel 
extern color   TitleColor        = C'46,188,46';         // Title color
extern bool    ShowPanelBG       = true;                 // Show panel backgroud
extern color   Pbgc              = C'25,25,25';          // Panel backgroud color
extern int     EventDisplay      = 10;                   // Hide event after (in minutes)
input string   lb_2              = "";                   // ------------------------------------------------------------
input string   lb_3              = "";                   // ------> SYMBOL SETTINGS

//input bool     snr           = TRUE;           //Use Support & Resistance

extern double RiskPercent 	= 2.0;	// risk for lot calculation according to the SL (for manual trading info)
extern int Offset				= 10;		// offset for arrows in pips
extern int BarsBack 			= 2000;
extern color InfoColor		= Snow;

extern string AlertSound = "alert.wav";

input bool KeyboardTrading = true; /*Keyboard Trading*/
input string h6      = "============================= Graphics ==========================";
input color COLOR_BORDER = C'255, 151, 25'; /*Panel Border*/
input color COLOR_CBG_LIGHT = C'252, 252, 252'; /*Chart Background (Light)*/
input color COLOR_CBG_DARK = C'28, 27, 26'; /*Chart Background (Dark)*/
//--- Global variables
input int ChartHigth =800;//Set chart hight
input int ChartWidth=1280;//Set Chart widht
input  color BearCandle=clrRed;
input color BullCandle=clrGreen;
input color Bear_Outline=clrWhite;
input color Bull_Outline=clrBlue;
input color BackGround;
input color ForeGround=clrDarkTurquoise;
extern string                                                        dff="TRADE OBJECTS SETTING";
extern color      color1            = clrGreenYellow;             // EA's name color
extern color      color2            = clrDarkOrange;             // EA's balance & info color
extern color      color3            = clrBeige;             // EA's profit color
extern color      color4            = clrMagenta;             // EA's loss color
extern color      color5            = clrBlue;          // Head Label Color
extern color      color6            = clrBlack;             // Main Label Color
extern int        Xordinate         = 20;                   // X
extern int        Yordinate         = 30;                   // Y


extern color _tableHeader=clrWhite;
extern color _Header = clrBlue;
extern color _SellSignal = clrRed;  //Sell Signal Color
extern color _BuySignal = clrBlue;//Buy Signal Color
extern color _Neutral = clrGray; //Neutral Signal Color
extern color _cSymbol = clrPowderBlue;//Symbol Signal Color
extern color _Separator = clrMediumPurple;

///////////////////////////////////////////////////
extern int Corners= 1;
extern int dys = 25;
extern string sss="";////////INDICATORRS PARAMETERS /////////////////////
input int InpMaxValidation= 4;
input int InpMinValidation=0;


input  string  menu6="========= Files Configurations ============";
input bool Report=true;
input ENUM_TRADE_REPORT InpTradeReport;
input  string  menu7="========= Indicators Configurations ============";

string prefix2 = "capital_";

input int MaxSignalValidation=4;
 input  int MinSignalValidation=2;
            
 input  TRADE_STRATEGY inpCloseTradeStrategy = joint;                 // Close Trade Strategy
input ENUM_TRADE_CLOSE_MODE inpTradeCloseMode   = CloseOnReversedSignal; // Trade Close Mode


input const  string ;//===================== ENTRY 1 ====== ====================================

input string __EA_OPEN_STRATEGY_INDICATOR_1__   = SEPARATOR;          // Open Strategy Indicator 1
input string inpInd0                        ="RSI.ex4" ;              // Entry Indicator 1
input ENUMS_TIMEFRAMES inpTF0                   = PERIOD_30_MIN;     // Entry Indicator 1 TF
input ENUM_TYPE_OF_ENTRY inpType0               = With_Trend;         // Type of entry 1
input int                             inpShift0 = 1;                  // Shift of Entry Indicator 1


input const  string ;//===================== EXIT 1 ====================================

input string __EA_CLOSE_STRATEGY_INDICATOR_1__  = SEPARATOR;             // Close Strategy Indicator 1
input  string inpInd0Ex                     = "RSI.ex4";                 // Exit Indicator 1
input ENUMS_TIMEFRAMES inpTF0Ex                  = PERIOD_30_MIN;        // Exit Indicator 1 TF
input ENUM_TYPE_OF_ENTRY inpType0Ex             = When_Trend_Change;     // Type of exit 1
input int inpShift0Ex                           = 1;

input const  string ;//===================== ENTRY 2 ====== ====================================

input string __EA_OPEN_STRATEGY_INDICATOR_2__   = SEPARATOR;          // Open Strategy Indicator 2
input string inpInd1                        = "CCI.ex4";               // Entry Indicator 2
input ENUMS_TIMEFRAMES inpTF1                   = PERIOD_15_MIN;     // Entry Indicator 2 TF
input ENUM_TYPE_OF_ENTRY inpType1              = With_Trend;         // Type of entry 2
input int                             inpShift1= 1;                  // Shift of Entry Indicator 2


input const  string ;//===================== EXIT 2 ====================================

input string __EA_CLOSE_STRATEGY_INDICATOR_2__  = SEPARATOR;             // Close Strategy Indicator 2
input  string inpInd1Ex                     = "CCI.ex4";                 // Exit Indicator 2
input ENUMS_TIMEFRAMES inpTF1Ex                  = PERIOD_30_MIN;        // Exit Indicator 2 TF
input ENUM_TYPE_OF_ENTRY inpType1Ex             = When_Trend_Change;     // Type of exit 2
input int inpShift1Ex                           = 1;


input const  string ;//===================== ENTRY 3 ====== ====================================

input string __EA_OPEN_STRATEGY_INDICATOR_3__   = SEPARATOR;          // Open Strategy Indicator 3
input string inpInd2                       ="uni_cross.ex4";              // Entry Indicator 3
input ENUMS_TIMEFRAMES inpTF2                    = PERIOD_5_MIN;     // Entry Indicator 3 TF
input ENUM_TYPE_OF_ENTRY inpType2               = With_Trend;         // Type of entry 3
input int                             inpShift2 = 1;                  // Shift of Entry Indicator 3




input const  string ;//===================== EXIT 3 ====================================

input string __EA_CLOSE_STRATEGY_INDICATOR_3__  = SEPARATOR;             // Close Strategy Indicator 3
input string inpInd2Ex                     = "uni_cross.ex4";               // Exit Indicator 3
input ENUMS_TIMEFRAMES inpTF2Ex                  = PERIOD_15_MIN;        // Exit Indicator 3 TF
input ENUM_TYPE_OF_ENTRY inpType2Ex             = When_Trend_Change;     // Type of exit 3
input int inpShift2Ex                           = 1;




input const  string ;//===================== ENTRY 4 ====== ====================================

input string __EA_OPEN_STRATEGY_INDICATOR_4__   = SEPARATOR;          // Open Strategy Indicator 4
input  string inpInd3                        = "ZigZag_Pointer.ex4";                // Entry Indicator 4
input ENUMS_TIMEFRAMES inpTF3                    = PERIOD_15_MIN;     // Entry Indicator 4 TF
input ENUM_TYPE_OF_ENTRY inpType3               = With_Trend;         // Type of entry 4
input int                             inpShift3 = 1;                  // Shift of Entry Indicator 4


input const  string ;//===================== EXIT 4 ====================================

input string __EA_CLOSE_STRATEGY_INDICATOR_4__  = SEPARATOR;             // Close Strategy Indicator 4
input string inpInd3Ex                     = "ZigZag.ex4";                  // Exit Indicator 4
input ENUMS_TIMEFRAMES inpTF3Ex                  = PERIOD_1_HOUR;        // Exit Indicator 4 TF
input ENUM_TYPE_OF_ENTRY inpType3Ex             = When_Trend_Change;     // Type of exit 4
input int inpShift3Ex                           = 1;


input bool inpAligned =false; //Align Signal
input string ___GUI_MANAGEMENT___    = SEPARATOR;      //=== GUI Settings ===
input bool ShowTradedSymbols         = true;           // Display Traded Symbols Dashboard
input int PanelFontSize              = 12;             // Panel Font Size
input int TradedSymbolsFontSize      = 10;     
        // Traded Symbols Dashboard Font Size
input bool ShowIndicator1Panel       = true;           // Display information on indicators
input string inpComment              = "";             // COMMENT



enum mode_of_alert
 {
    E_MAIL,MOBILE,E_MAIL_AND_MOBILE
 };
extern mode_of_alert ALERT_MODE=E_MAIL;
//User Parameters
extern color fiboColor =clrBlue;
extern double fiboWidth = 1;
extern ENUM_LINE_STYLE fiboStyle = STYLE_DOT;
extern color unretracedZoneColor = Green;
extern bool showUnretracedZone = true;


input double FIBO_LEVEL_0=0.0;

input double FIBO_LEVEL_1=0.236;
input bool ALERT_ACTIVE_FIBO_LEVEL_1=true;

input double FIBO_LEVEL_2=0.382;
input bool ALERT_ACTIVE_FIBO_LEVEL_2=true;

input double FIBO_LEVEL_3=0.50;
input bool ALERT_ACTIVE_FIBO_LEVEL_3=true;

input double FIBO_LEVEL_4=0.618;
input bool ALERT_ACTIVE_FIBO_LEVEL_4=true;

input double FIBO_LEVEL_5=0.786;
input bool ALERT_ACTIVE_FIBO_LEVEL_5=true;

input double FIBO_LEVEL_6=1.0;
input bool ALERT_ACTIVE_FIBO_LEVEL_6=true;

input double FIBO_LEVEL_7=1.214;
input bool ALERT_ACTIVE_FIBO_LEVEL_7=true;

input double FIBO_LEVEL_8=1.618;
input bool ALERT_ACTIVE_FIBO_LEVEL_8=true;

input double FIBO_LEVEL_9=2.618;
input bool ALERT_ACTIVE_FIBO_LEVEL_9=true;

input double FIBO_LEVEL_10=4.236;
input bool ALERT_ACTIVE_FIBO_LEVEL_10=true;
 