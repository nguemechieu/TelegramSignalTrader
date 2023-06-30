//+------------------------------------------------------------------+
//|                                                      Symbols.mqh |
//|                                Copyright © 2010, 7bit and sxTed. |
//| Purpose.: Functions for handling Multi Currency or Instruments.  |
//| Set up..: Place file into the "\experts\include" subdirectory.   |
//| Notes...: Download custom indicator "Max.mq4" for sample usage.  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, 7bit and sxTed."
#property link      "sxTed@gmx.com"

#include <stderror.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Function..: Symbols                                              |
//| Purpose...: Retrieve a list of all Symbols/Instruments known to  |
//|             the Server with some MarketInfo output to a CSV file.|
//| Parameters: sSymbols - name of the string array to receive data. |
//| Returns...: Returns number of Symbols found or -1 if an error    |
//|             occured, the error is printed @ Terminal -> Experts. |
//| Notes.....: The array will be resized to number of Symbols found.|
//|             Only the Symbol name is listed in the array.         |
//|             The description and other market info of the Symbols |
//|             is output to a CSV file having "Symbols_" as prefix  |
//|             and the connected Server's name as suffix, the CSV   |
//|             file is output to the "\experts\files" sub-directory |
//|             may be viewed or edited with spreadsheet software.   |
//| Sample 1..: string sSymbols[1000];                               |
//|             int    iSymbols=Symbols(sSymbols);                   |
//| Sample 2..: Indicator that alert's when price crosses over the   |
//|             Moving Average for any one of the Symbols offered by |
//|             the Broker's Server.                                 |
/*+------------------------------------------------------------------+

include <Symbols.mqh> // #### must be stated here to pull in the functions

void start() {
  static string   sSymbols[1000];
  static int      iSymbols;
  static datetime tPreviousTime;
  double dMA;
  int    iMA_Period=100, i;
  string sPeriod=","+PeriodToStr();
  
  // only load the Symbols once into the array "sSymbols"
  if(iSymbols == 0) iSymbols=Symbols(sSymbols);
  
  // only start analysis on complete bars
  if(tPreviousTime == Time[0]) return;
  
  for(i=0; i < iSymbols; i++) {
    dMA=iMA(sSymbols[i],0,iMA_Period,13,MODE_EMA,PRICE_CLOSE,0);
    if(iOpen(sSymbols[i],0,1) > dMA && iClose(sSymbols[i],0,1) < dMA)    
      Alert("Price crossed below ",iMA_Period," EMA on ",sSymbols[i],sPeriod);
    if(iOpen(sSymbols[i],0,1) < dMA && iClose(sSymbols[i],0,1) > dMA)
      Alert("Price crossed above ",iMA_Period," EMA on ",sSymbols[i],sPeriod);
  }
  tPreviousTime=Time[0];  
}
*/

int Symbols(string& sSymbols[]) {
  int    iCount, handle, handle2, i;
  string sData="Symbols_"+AccountServer()+".csv", sSymbol;
    
  handle=FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
  if(handle == -1) return(Error("File: symbols.raw  Error: "+ErrorDescription(GetLastError())));
  handle2=FileOpen(sData, FILE_CSV|FILE_WRITE, ',');
  if(handle2 == -1) return(Error("File: "+sData+"  Error: "+ErrorDescription(GetLastError())));
  iCount=FileSize(handle) // 1936;
  ArrayResize(sSymbols, iCount);
  
  FileWrite(handle2,"Symbol","Description","Point","Digits","Spread","StopLevel",
            "LotSize","TickValue","TickSize","SwapLong","SwapShort","Starting",
            "Expiration","TradeAllowed","MinLot","LotStep","MaxLot","SwapType",
            "ProfitCalcMode","MarginCalcMode","MarginMaintenance","MarginHedged",
            "MarginRequired","FreezeLevel");
  
  for(i=0; i<iCount; i++) {
    sSymbol=FileReadString(handle, 12);
    sSymbols[i]=sSymbol;
    FileWrite(handle2,
              sSymbol,
              StringTransform(StringTrimRight(FileReadString(handle, 75)),","), // Field 1 - Symbol/Instrument Description
              MarketInfo(sSymbol,MODE_POINT),
              MarketInfo(sSymbol,MODE_DIGITS),
              MarketInfo(sSymbol,MODE_SPREAD),
              MarketInfo(sSymbol,MODE_STOPLEVEL),
              MarketInfo(sSymbol,MODE_LOTSIZE),
              MarketInfo(sSymbol,MODE_TICKVALUE),
              MarketInfo(sSymbol,MODE_TICKSIZE),
              MarketInfo(sSymbol,MODE_SWAPLONG),
              MarketInfo(sSymbol,MODE_SWAPSHORT),
              ifS(MarketInfo(sSymbol,MODE_STARTING)==0,"0",
                  TimeToStr(MarketInfo(sSymbol,MODE_STARTING),TIME_DATE|TIME_MINUTES)
                 ),
              ifS(MarketInfo(sSymbol,MODE_EXPIRATION)==0,"0",
                  TimeToStr(MarketInfo(sSymbol,MODE_EXPIRATION),TIME_DATE|TIME_MINUTES)
                 ),
              ifS(MarketInfo(sSymbol,MODE_TRADEALLOWED)==1,"Yes","No"),
              MarketInfo(sSymbol,MODE_MINLOT),
              MarketInfo(sSymbol,MODE_LOTSTEP),
              MarketInfo(sSymbol,MODE_MAXLOT),
              ifS(    MarketInfo(sSymbol,MODE_SWAPTYPE)==0,"0=in points",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==1,"1=in base ccy",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==2,"2=by interest",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==3,"3=in margin ccy",
                      DoubleToStr(MarketInfo(sSymbol,MODE_SWAPTYPE),0))))
                 ),
             ifS(    MarketInfo(sSymbol,MODE_PROFITCALCMODE)==0,"0=Forex",
                 ifS(MarketInfo(sSymbol,MODE_PROFITCALCMODE)==1,"1=CFD",
                 ifS(MarketInfo(sSymbol,MODE_PROFITCALCMODE)==2,"2=Futures",
                     DoubleToStr(MarketInfo(sSymbol,MODE_PROFITCALCMODE),0)))
                ),
             ifS(    MarketInfo(sSymbol,MODE_MARGINCALCMODE)==0,"0=Forex",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==1,"1=CFD",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==2,"2=Futures",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==3,"3=CFD for indices",
                     DoubleToStr(MarketInfo(sSymbol,MODE_MARGINCALCMODE),0))))
                ),
              MarketInfo(sSymbol,MODE_MARGININIT),
              MarketInfo(sSymbol,MODE_MARGINHEDGED),
              MarketInfo(sSymbol,MODE_MARGINREQUIRED),
              MarketInfo(sSymbol,MODE_FREEZELEVEL)
             );
    FileSeek(handle, 1849, SEEK_CUR); // move to start of next record
  }
  
  FileClose(handle2);
  FileClose(handle);
  return(iCount);
}

int Error(string sErrorMessage) {
  Print(sErrorMessage);
  return(-1);
}

string ifS(bool bExpression, string sValue1, string sValue2) {
  if(bExpression) return(sValue1); else return(sValue2);
}

string PeriodToStr(int iPeriod=0) {
  if(iPeriod < 1) iPeriod=Period();
  switch(iPeriod) {
    case PERIOD_M1 : return("M1");
    case PERIOD_M5 : return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1 : return("H1");
    case PERIOD_H4 : return("H4");
    case PERIOD_D1 : return("D1");
    case PERIOD_W1 : return("W1");
    case PERIOD_MN1: return("MN1");
    default        : return(iPeriod);
  }
}

//+------------------------------------------------------------------+
//| Function..: SymFind                                              |
//| Purpose...: Find a Symbol in a single dimension array.           |
//| Parameters: sSymbols - The string array in which to search for.  |
//|             sSymbol  - Symbol or Instrument to find.             |
//|             iCount   - Count of elements to search for starting  |
//|                        from the first row. By default searches   |
//|                        the whole array.                          |
//| Returns...: The index position of where the Symbol was found in  |
//|             the array, or -1 if not found.                       |
//| Sample....: string sSymbols[] = {"EURUSD", "GBPUSD"};            |
//|             int    iIndexPos = SymFind(sSymbols, "GBPUSD");      |
//|             Print("iIndexPos=", iIndexPos); // 1                 |
//+------------------------------------------------------------------+
int SymFind(string sSymbols[], string sSymbol, int iCount = WHOLE_ARRAY) {
  if(iCount == WHOLE_ARRAY) iCount = ArrayRange(sSymbols, 0); 
  for(int i=0; i < iCount; i++) {
    if(sSymbols[i] == sSymbol) return(i);
  }
  return(-1);
}

//+------------------------------------------------------------------+
//| Function..: StringTransform                                      |
//| Purpose...: Transform a matched string in text with a new string.|
//| Parameters: sText    - Text string to be transformed.            |
//|             sFind    - String to search for in <sText>.          |
//|             sReplace - String to replace <sFind> in <sText>.     |
//| Returns...: Returns  a copy of <sText> with each occurence of    |
//|             <sFind> replaced by <sReplace>.                      |
//| Notes.....: The replacement for the matched characters does not  |
//|             need to be a single character.                       |
//| Sample 1..: StringTransform("oNe mAn"," ",""); // oNemAn         |
//| Sample 2..: StringTransform("cat&","&"," & dog"); // "cat & dog" | 
//+------------------------------------------------------------------+
string StringTransform(string sText, string sFind=" ", string sReplace="") {
  int    iLenText=StringLen(sText), iLenFind=StringLen(sFind), i;
  string sReturn="";
  
  for(i=0; i<iLenText; i++) {
    if(StringSubstr(sText,i,iLenFind)==sFind) {
      sReturn=sReturn+sReplace;
      i=i+iLenFind-1;
    }
    else sReturn=sReturn+StringSubstr(sText,i,1);
  }
  return(sReturn);
}
//+------------------------------------------------------------------+

