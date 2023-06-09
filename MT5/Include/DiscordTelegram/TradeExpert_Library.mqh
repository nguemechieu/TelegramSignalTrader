//+------------------------------------------------------------------+
//|                                          TradeExpert_Library.mq4 |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
input bool InpAlign=true;

 //+------------------------------------------------------------------+
//|                                                     stderror.mqh |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
//--- errors returned from trade server
#define ERR_NO_ERROR                                  0
#define ERR_NO_RESULT                                 1
#define ERR_COMMON_ERROR                              2
#define ERR_INVALID_TRADE_PARAMETERS                  3
#define ERR_SERVER_BUSY                               4
#define ERR_OLD_VERSION                               5
#define ERR_NO_CONNECTION                             6
#define ERR_NOT_ENOUGH_RIGHTS                         7
#define ERR_TOO_FREQUENT_REQUESTS                     8
#define ERR_MALFUNCTIONAL_TRADE                       9
#define ERR_ACCOUNT_DISABLED                         64
#define ERR_INVALID_ACCOUNT                          65
#define ERR_TRADE_TIMEOUT                           128
#define ERR_INVALID_PRICE                           129
#define ERR_INVALID_STOPS                           130
#define ERR_INVALID_TRADE_VOLUME                    131
#define ERR_MARKET_CLOSED                           132
#define ERR_TRADE_DISABLED                          133
#define ERR_NOT_ENOUGH_MONEY                        134
#define ERR_PRICE_CHANGED                           135
#define ERR_OFF_QUOTES                              136
#define ERR_BROKER_BUSY                             137
#define ERR_REQUOTE                                 138
#define ERR_ORDER_LOCKED                            139
#define ERR_LONG_POSITIONS_ONLY_ALLOWED             140
#define ERR_TOO_MANY_REQUESTS                       141
#define ERR_TRADE_MODIFY_DENIED                     145
#define ERR_TRADE_CONTEXT_BUSY                      146
#define ERR_TRADE_EXPIRATION_DENIED                 147
#define ERR_TRADE_TOO_MANY_ORDERS                   148
#define ERR_TRADE_HEDGE_PROHIBITED                  149
#define ERR_TRADE_PROHIBITED_BY_FIFO                150
//--- mql4 run time errors
#define ERR_NO_MQLERROR                            4000
#define ERR_WRONG_FUNCTION_POINTER                 4001
#define ERR_ARRAY_INDEX_OUT_OF_RANGE               4002
#define ERR_NO_MEMORY_FOR_CALL_STACK               4003
#define ERR_RECURSIVE_STACK_OVERFLOW               4004
#define ERR_NOT_ENOUGH_STACK_FOR_PARAM             4005
#define ERR_NO_MEMORY_FOR_PARAM_STRING             4006
#define ERR_NO_MEMORY_FOR_TEMP_STRING              4007
#define ERR_NOT_INITIALIZED_STRING                 4008
#define ERR_NOT_INITIALIZED_ARRAYSTRING            4009
#define ERR_NO_MEMORY_FOR_ARRAYSTRING              4010
#define ERR_TOO_LONG_STRING                        4011
#define ERR_REMAINDER_FROM_ZERO_DIVIDE             4012
#define ERR_ZERO_DIVIDE                            4013
#define ERR_UNKNOWN_COMMAND                        4014
#define ERR_WRONG_JUMP                             4015
#define ERR_NOT_INITIALIZED_ARRAY                  4016
#define ERR_DLL_CALLS_NOT_ALLOWED                  4017
#define ERR_CANNOT_LOAD_LIBRARY                    4018
#define ERR_CANNOT_CALL_FUNCTION                   4019
#define ERR_EXTERNAL_CALLS_NOT_ALLOWED             4020
#define ERR_NO_MEMORY_FOR_RETURNED_STR             4021
#define ERR_SYSTEM_BUSY                            4022
#define ERR_DLLFUNC_CRITICALERROR                  4023
#define ERR_INTERNAL_ERROR                         4024   // new MQL4
#define ERR_OUT_OF_MEMORY                          4025   // new MQL4
#define ERR_INVALID_POINTER                        4026   // new MQL4
#define ERR_FORMAT_TOO_MANY_FORMATTERS             4027   // new MQL4
#define ERR_FORMAT_TOO_MANY_PARAMETERS             4028   // new MQL4
#define ERR_ARRAY_INVALID                          4029   // new MQL4
#define ERR_CHART_NOREPLY                          4030   // new MQL4
#define ERR_INVALID_FUNCTION_PARAMSCNT             4050
#define ERR_INVALID_FUNCTION_PARAMVALUE            4051
#define ERR_STRING_FUNCTION_INTERNAL               4052
#define ERR_SOME_ARRAY_ERROR                       4053
#define ERR_INCORRECT_SERIESARRAY_USING            4054
#define ERR_CUSTOM_INDICATOR_ERROR                 4055
#define ERR_INCOMPATIBLE_ARRAYS                    4056
#define ERR_GLOBAL_VARIABLES_PROCESSING            4057
#define ERR_GLOBAL_VARIABLE_NOT_FOUND              4058
#define ERR_FUNC_NOT_ALLOWED_IN_TESTING            4059
#define ERR_FUNCTION_NOT_CONFIRMED                 4060
#define ERR_SEND_MAIL_ERROR                        4061
#define ERR_STRING_PARAMETER_EXPECTED              4062
#define ERR_INTEGER_PARAMETER_EXPECTED             4063
#define ERR_DOUBLE_PARAMETER_EXPECTED              4064
#define ERR_ARRAY_AS_PARAMETER_EXPECTED            4065
#define ERR_HISTORY_WILL_UPDATED                   4066
#define ERR_TRADE_ERROR                            4067
#define ERR_RESOURCE_NOT_FOUND                     4068   // new MQL4
#define ERR_RESOURCE_NOT_SUPPORTED                 4069   // new MQL4
#define ERR_RESOURCE_DUPLICATED                    4070   // new MQL4
#define ERR_INDICATOR_CANNOT_INIT                  4071   // new MQL4
#define ERR_INDICATOR_CANNOT_LOAD                  4072   // new MQL4
#define ERR_NO_HISTORY_DATA                        4073   // new MQL4
#define ERR_NO_MEMORY_FOR_HISTORY                  4074   // new MQL4
#define ERR_NO_MEMORY_FOR_INDICATOR                4075   // new MQL4
#define ERR_END_OF_FILE                            4099
#define ERR_SOME_FILE_ERROR                        4100
#define ERR_WRONG_FILE_NAME                        4101
#define ERR_TOO_MANY_OPENED_FILES                  4102
#define ERR_CANNOT_OPEN_FILE                       4103
#define ERR_INCOMPATIBLE_FILEACCESS                4104
#define ERR_NO_ORDER_SELECTED                      4105
#define ERR_UNKNOWN_SYMBOL                         4106
#define ERR_INVALID_PRICE_PARAM                    4107
#define ERR_INVALID_TICKET                         4108
#define ERR_TRADE_NOT_ALLOWED                      4109
#define ERR_LONGS_NOT_ALLOWED                      4110
#define ERR_SHORTS_NOT_ALLOWED                     4111
#define ERR_OBJECT_ALREADY_EXISTS                  4200
#define ERR_UNKNOWN_OBJECT_PROPERTY                4201
#define ERR_OBJECT_DOES_NOT_EXIST                  4202
#define ERR_UNKNOWN_OBJECT_TYPE                    4203
#define ERR_NO_OBJECT_NAME                         4204
#define ERR_OBJECT_COORDINATES_ERROR               4205
#define ERR_NO_SPECIFIED_SUBWINDOW                 4206
#define ERR_SOME_OBJECT_ERROR                      4207
#define ERR_CHART_PROP_INVALID                     4210   // new MQL4
#define ERR_CHART_NOT_FOUND                        4211   // new MQL4
#define ERR_CHARTWINDOW_NOT_FOUND                  4212   // new MQL4
#define ERR_CHARTINDICATOR_NOT_FOUND               4213   // new MQL4
#define ERR_SYMBOL_SELECT                          4220   // new MQL4
#define ERR_NOTIFICATION_ERROR                     4250
#define ERR_NOTIFICATION_PARAMETER                 4251
#define ERR_NOTIFICATION_SETTINGS                  4252
#define ERR_NOTIFICATION_TOO_FREQUENT              4253
#define ERR_FTP_NOSERVER                           4260   // new MQL4
#define ERR_FTP_NOLOGIN                            4261   // new MQL4
#define ERR_FTP_CONNECT_FAILED                     4262   // new MQL4
#define ERR_FTP_CLOSED                             4263   // new MQL4
#define ERR_FTP_CHANGEDIR                          4264   // new MQL4
#define ERR_FTP_FILE_ERROR                         4265   // new MQL4
#define ERR_FTP_ERROR                              4266   // new MQL4
#define ERR_FILE_TOO_MANY_OPENED                   5001   // new MQL4
#define ERR_FILE_WRONG_FILENAME                    5002   // new MQL4
#define ERR_FILE_TOO_LONG_FILENAME                 5003   // new MQL4
#define ERR_FILE_CANNOT_OPEN                       5004   // new MQL4
#define ERR_FILE_BUFFER_ALLOCATION_ERROR           5005   // new MQL4
#define ERR_FILE_CANNOT_DELETE                     5006   // new MQL4
#define ERR_FILE_INVALID_HANDLE                    5007   // new MQL4
#define ERR_FILE_WRONG_HANDLE                      5008   // new MQL4
#define ERR_FILE_NOT_TOWRITE                       5009   // new MQL4
#define ERR_FILE_NOT_TOREAD                        5010   // new MQL4
#define ERR_FILE_NOT_BIN                           5011   // new MQL4
#define ERR_FILE_NOT_TXT                           5012   // new MQL4
#define ERR_FILE_NOT_TXTORCSV                      5013   // new MQL4
#define ERR_FILE_NOT_CSV                           5014   // new MQL4
#define ERR_FILE_READ_ERROR                        5015   // new MQL4
#define ERR_FILE_WRITE_ERROR                       5016   // new MQL4
#define ERR_FILE_BIN_STRINGSIZE                    5017   // new MQL4
#define ERR_FILE_INCOMPATIBLE                      5018   // new MQL4
#define ERR_FILE_IS_DIRECTORY                      5019   // new MQL4
#define ERR_FILE_NOT_EXIST                         5020   // new MQL4
#define ERR_FILE_CANNOT_REWRITE                    5021   // new MQL4
#define ERR_FILE_WRONG_DIRECTORYNAME               5022   // new MQL4
#define ERR_FILE_DIRECTORY_NOT_EXIST               5023   // new MQL4
#define ERR_FILE_NOT_DIRECTORY                     5024   // new MQL4
#define ERR_FILE_CANNOT_DELETE_DIRECTORY           5025   // new MQL4
#define ERR_FILE_CANNOT_CLEAN_DIRECTORY            5026   // new MQL4
#define ERR_FILE_ARRAYRESIZE_ERROR                 5027   // new MQL4
#define ERR_FILE_STRINGRESIZE_ERROR                5028   // new MQL4
#define ERR_FILE_STRUCT_WITH_OBJECTS               5029   // new MQL4
//+------------------------------------------------------------------+
//|                                                       stdlib.mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#import "stdlib.ex4"

string ErrorDescription(int error_code);
int    RGB(int red_value,int green_value,int blue_value);
bool   CompareDoubles(double number1,double number2);
string DoubleToStrMorePrecision(double number,int precision);
string IntegerToHexString(int integer_number);

#import




#define  EXPERT_NAME "TradeExpert"
//--- define the maximum number of used indicators in the EA

#include <DiscordTelegram/Common.mqh>//start settings all include file orders matters
#include <DiscordTelegram/PanelDialog.mqh>

#include <DiscordTelegram/Autheticator.mqh>


struct TOOLS{

MqlTick tick;
int Pip(){ return(int) _Point; 

};
double Ask(){return tick.ask;

};
double Digits(){return _Digits;
};
double Bid(){return tick.bid;}
;
};
  
  //+------------------------------------------------------------------+
  //|                       CREATE OBJECTS                                           |
  //+------------------------------------------------------------------+
  
void vSetRectangle(string name, int sub_window, int xx, int yy, int width, int height, color bg_color, color border_clr, int border_width) export{

   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);

}


void vSetBackground(string sName,int sub_window, int xx, int yy, int width, int height, color BacgroundColor)export {

   ObjectCreate(0,sName,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR,BacgroundColor);
   ObjectSetInteger(0,sName,OBJPROP_SELECTABLE,false);
   
}



void vSetHLine(long lChartid, string sName,int sub_window, double dPrice, color cFontColor, int iFontSize,string Textx) export{
   ObjectCreate(lChartid,sName,OBJ_HLINE,sub_window,0,0,dPrice);

   ObjectSetInteger(lChartid,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(lChartid,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT, 0,Textx);
}

void vSetHLine (string sName,int sub_window, double dPrice, color cFontColor)export {
   ObjectCreate(0,sName,OBJ_HLINE,sub_window,0,0);
   ObjectSetInteger(0,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetDouble(0,sName, OBJPROP_PRICE, dPrice);
}

  
  
//+------------------------------------------------------------------+ 
//| Create cycle lines                                               | 
//+------------------------------------------------------------------+ 
bool CyclesCreate(const long            chart_ID=0,        // chart's ID 
                  const string          name="Cycles",     // object name 
                  const int             sub_window=0,      // subwindow index 
                  datetime              time1=0,           // first point time 
                  double                price1=0,          // first point price 
                  datetime              time2=0,           // second point time 
                  double                price2=0,          // second point price 
                  const color           clr=clrRed,        // color of cycle lines 
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // style of cycle lines 
                  const int             width=1,           // width of cycle lines 
                  const bool            back=false,        // in the background 
                  const bool            selection=true,    // highlight to move 
                  const bool            hidden=true,       // hidden in the object list 
                  const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   ChangeCyclesEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create cycle lines by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_CYCLES,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create cycle lines! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set color of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set display style of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the lines by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Move the anchor point                                            | 
//+------------------------------------------------------------------+ 
bool CyclesPointChange(const long   chart_ID=0,    // chart's ID 
                       const string name="Cycles", // object name 
                       const int    point_index=0, // anchor point index 
                       datetime     time=0,        // anchor point time coordinate 
                       double       pricex=0)       // anchor point price coordinate 
  { 
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time) 
      time=TimeCurrent(); 
   if(!pricex) 
      pricex=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,pricex)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move the anchor point! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Delete the cycle lines                                           | 
//+------------------------------------------------------------------+ 
bool CyclesDelete(const long   chart_ID=0,    // chart's ID 
                  const string name="Cycles") // object name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete cycle lines 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete cycle lines! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+-----------------------------------------------------------------------+ 
//| Check the values of cycle lines' anchor points and set default values | 
//| values for empty ones                                                 | 
//+-----------------------------------------------------------------------+ 
void ChangeCyclesEmptyPoints(datetime &time1,double &price1, 
                             datetime &time2,double &price2) 
  { 
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1) 
      time1=TimeCurrent(); 
//--- if the first point's price is not set, it will have Bid value 
   if(!price1) 
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2) 
     { 
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10]; 
      CopyTime(Symbol(),Period(),time1,10,temp); 
      //--- set the second point 9 bars left from the first one 
      time2=temp[0]; 
     } 
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2) 
      price2=price1; 
  } 
//+------------------------------------------------------------------+
//| My functions                                                    |
//+------------------------------------------------------------------+
int MyCalculator(int value,int value2) export
   {
    return(value+value2);
  }
  
  double add(double sum1,double sum2)export{//calculate sum
  double sum=sum1+sum2;
  return sum;
  };
  
    double substract(double sum1,double sum2)export{//calculate substract
  double sum=sum1-sum2;
  return sum;
  };
  
    double divide(double sum1,double sum2)export{//calculate divide
    
    if(sum2==0){ printf ("sum2 can't be null");return 0;}
  double sum=sum1/sum2;
  
  return sum;
  };
    double multiply(double sum1,double sum2)export{//calculate sum
  double sum=sum1*sum2;
  return sum;
  };
  
  
  