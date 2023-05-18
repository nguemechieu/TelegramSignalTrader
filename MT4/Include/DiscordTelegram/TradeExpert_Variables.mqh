//+------------------------------------------------------------------+
//|                                        TradeExpert_Variables.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property strict

#define SIGNAL_SELL (-1)
#define SIGNAL_NONE ( 0)
#define SIGNAL_BUY  ( 1)
#define SIGNAL_BUYLIMIT  ( 2)

#define SIGNAL_SELLLIMIT  ( -2)

#define SIGNAL_BUYSTOP ( 3)

#define SIGNAL_SELLSTOP  ( -3)

#define  LOSS_COLOR clrGold
#define  CAPTION_COLOR  clrAliceBlue


#define OPENPRICE          0
#define CLOSEPRICE         1
//---
#define OP_ALL            -1
//---
#define KEY_UP             38
#define KEY_DOWN           40
#define MAX_CLOSE_BUTTONS 7
#define CLIENT_BG_X (20)
#define CLIENT_BG_Y (20)
#define TOTAL_OpenOrExit 2
#define CLIENT_BG_WIDTH (700)
 int startx=CLIENT_BG_X;
           int  starty=0;
       string CloseButtonNames[MAX_CLOSE_BUTTONS] = {"CPCloseBuy","CPCloseSell","CPCloseProfit","CPCloseLoss","CPCloseLimit","CPCloseStop","CPCloseAll"};
 int ExitSignal3[200]={} , ExitSignal2[200]={}, ExitSignal1[200]={}, ExitSignal0[200]={};   
 int  MasterSignal[200]={};
 
 int Signal1[200]={},Signal2[200]={},Signal3[200]={};
bool alarm_fibo_level_1=false;
bool alarm_fibo_level_2=false;
bool alarm_fibo_level_3=false;
bool alarm_fibo_level_4=false;
bool alarm_fibo_level_5=false;
bool alarm_fibo_level_6=false;
bool alarm_fibo_level_7=false;
bool alarm_fibo_level_8=false;
bool alarm_fibo_level_9=false;
bool alarm_fibo_level_10=false;
string tradeReason;
bool AutoSL = false;
bool AutoTP = false;
bool AutoLots = false;
bool ClearedTemplate = false;
bool FirstRun = true;
//---
color COLOR_BG = clrNONE;
color COLOR_FONT = clrNONE;
//---
color COLOR_GREEN = clrForestGreen;
color COLOR_RED = clrFireBrick;
color COLOR_SELL = C'225, 68, 29';
color COLOR_BUY = C'3, 95, 172';
color COLOR_CLOSE = clrNONE;
color COLOR_AUTO = clrDodgerBlue;
color COLOR_LOW = clrNONE;
color COLOR_MARKER = clrNONE;
int FONTSIZE = 9;
//---
int _x1 = 0;
int _y1 = 0;
int ChartX = 0;
int ChartY = 0;
int CalcTF = 0;
datetime drop_time = 0;
datetime stauts_time = 0;
//---
color COLOR_REGBG = C'27, 27, 27';
color COLOR_REGFONT = clrSilver;
//---
int Bck_Win_X = 255;
int Bck_Win_Y = 150;
//---
string Symbols[1000];

//---


string  ExpertName="TradeExpert";
string MB_CAPTION = ExpertName+" v"+(string)5.1;
   double lastResistance[100]= {};

//--- includes

double RiskP = 0;
double RiskC = 0;
double RiskInpC = 0;
double RiskInpP = 0;
//---
int ResetAlertUp = 0;
int ResetAlertDwn = 0;
bool UserIsEditing = false;
bool UserWasNotified = false;
//---
double StopLossDist = 0;
double RiskInp = 0;
double RR = 0;
double _TP = 0;
//---
int SelectedTheme = 0;
int PriceRowLeft = 0;
int PriceRowRight = 0;
//---
int ErrorInterval = 300;
int LastReason = 0;
string ErrorSound = "error.wav";
bool SoundIsEnabled = false;
bool AlarmIsEnabled = false;
int ProfitMode = 0;

//--- Set the number of symbols in SymbolArraySize


  
         string SYMBOL[10]={};
          ENUM_ORDER_TYPE tradesignals[100]={};  

int timer_ms=1000;


 int fibo_levels=11;
double current_high;
double current_low;
double price_delta;


string headerString = "AutoFibo_";



int panelwidth=400;
int panelheight= 250;
int buttonwidth=(panelwidth-8)/3;
int buttonheight=(panelheight-36)/5;
int editwidth=(panelwidth-8)/4;
int init_status;
//--- GUI debug
int y_offset;
int IndicatorSubWindow = 0;
 int retries=1;
           
bool previous_trend=false;
const ENUM_TIMEFRAMES _periods[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};

 int  cryptoSymbolNumbers=0;
  string indicatorsArrayList[];
     
   int IndicatorListArraySize=4;
 
       
     int shiftR[100]={2};
   

      int option=10;
      
double Tsa =0; bool exitSell[1],exitBuy[1];



double lastSupport[];
//---- Get new daily prices & calculate pivots
double cur_day  = 0;
double yesterday_close = 0,
       today_open = 0,
       yesterday_high = 0,//day_high;
       yesterday_low = 0,//day_low;
       day_high = 0,
       day_low  =0;
double prev_day = cur_day;
int TargetReachedForDay=-1;
int ThisDayOfYear=DayOfYear();
datetime TMN=0;
datetime NewCandleTime=0;
string postfix="";
bool Os,Om,Od,Oc;
bool CloseOP=false;
color  warnatxt = clrAqua;// Warning Text
double HEDING=true;
double maxlot,minlot;
ENUM_BASE_CORNER Info_Corner = 0;
color  FontColorUp1 = Yellow,FontColorDn1 = Pink,FontColor = White,FontColorUp2 = LimeGreen;
double PR=0,PB=0,PS=0,LTB=0,LTS=0;
string closeAskedFor ="";
datetime expire_date=0;
datetime e_d ;
double minlotx;
datetime sendOnce;
double startbalance;
datetime starttime=D'2022.01.01 00:00';
bool isNewBar=false;
bool trade=true;
string google_urlx;

double harga;
double lastprice;
string jamberita;
string judulberita;
string infoberita=" >>>> checking news <<<";

double P1=0,Wp1=0,MNp1=0,P2=0,P3=0,Persentase1=0,Persentase2=0,Persentase3=0;

//extern     string mysimbol = "EURUSD,USDJPY,GBPUSD,AUDUSD,USDCAD,USDCHF,NZDUSD,EURJPY,EURGBP,EURCAD,EURCHF,EURAUD,EURNZD,AUDJPY,CHFJPY,CADJPY,NZDJPY,GBPJPY,GBPCHF,GBPAUD,GBPCAD,CADCHF,AUDCHF,GBPNZD,AUDNZD,AUDCAD,NZDCAD,NZDCHF";
int  tradecount=0;

string PriceRowLeftArr[]= {"Bid","Low","Open","Pivot"};
string PriceRowRightArr[]= {"Ask","High","Open","Pivot"};



int xc,xpair,xbuy,xsell,xcls,xlot,xpnl,xexp,yc,ypair,ysell,ybuy,ylot,ycls,ypnl,yexp,ytxtb,ytxts,ytxtcls,ytxtpnl,ytxtexp;
double poexp[100];//= { 0,0.00000000000002,0.000000000000000000003,
double profitss[100];
double DayProfit ;
double BalanceStart;
double DayPnLPercent;
datetime mydate=TimeLocal();string sFontType = "";
string sep=",";                // A separator as a character
              // The code of the separator character
// string result;               // An array to get strings
datetime _opened_last_time =0 ;
datetime _closed_last_time =mydate;


 int  EntrySiGnal[100]={};//entry signals

        bool   Exitchange0[100],  Exitchange1[100],  Exitchange2[100],  Exitchange3[100];
         
   //initialize
   int myPoint =(int)Point;

 
 

int xSell1=0;
int xSell2=0;
int xSell3=0;
int xSell4=0;
int xBuy1=0;
int xBuy2=0;
int xBuy3=0;
int xBuy4=0;
int sinyalb1 ;
int sinyalb2 ;
int sinyalb3 ;
int sinyalb4 ;
int sinyal1;
int sinyal2;
int sinyal3;
int sinyal4;
datetime PrevTime[5];


#define OBJPREFIX          "YM- "
//---


//--
//---

#define JOB "7022"
#define EPOCH D'2021.01.01 00:00'
#define OBJPFX JOB"_"
#define TOTAL_BUTT   (20)
//--- structures
struct SDataButt
  {
   string      name;
   string      text;
  };
//--- global variables

SDataButt      butt_data[TOTAL_BUTT];
string         prefix;
double         lot;
ulong          magic_number;
uint           stoploss;
uint           takeprofit;
uint           distance_pending;
uint           distance_stoplimit;
uint           slippage;
bool           trailing_on;
double         trailing_stop;
double         trailing_step;
uint           trailing_start;
uint           stoploss_to_modify;
uint           takeprofit_to_modify;
int            used_symbols_mode;
string         used_symbols;
 string cryptoList[];
// Class object
string _sep=",";  
ushort u_sep=StringGetChar(_sep,0);                                               // A separator as a character
// The code of the separator character
string array_used_symbols[100];
