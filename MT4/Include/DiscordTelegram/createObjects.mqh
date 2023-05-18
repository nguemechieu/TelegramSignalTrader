//+------------------------------------------------------------------+
//|                                                createObjects.mqh |
//|                                        Copyright 2021, FxWeirdos |
//|                                               info@fxweirdos.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, FxWeirdos. Mario Gharib. Forex Jarvis. info@fxweirdos.com"
#property link      "https://fxweirdos.com"
#property strict



void vSetArrow(long lChartid, string sName,int sub_window, datetime dtTime, double dPrice, int iFontWidth, color cFontColor, int iArrowCode) export{

   ObjectCreate(lChartid,sName, OBJ_ARROW, sub_window, dtTime, dPrice);
   ObjectSetInteger(lChartid, sName, OBJPROP_ARROWCODE, iArrowCode);
   ObjectSetInteger(lChartid, sName, OBJPROP_WIDTH, iFontWidth);
   ObjectSetInteger(lChartid, sName, OBJPROP_COLOR, cFontColor);
   
}


void vSetText(long lChartid, string sName,int sub_window, datetime dtTime, double dPrice, int iFontWidth, color cFontColor, string sText)export {

   ObjectCreate(lChartid,sName, OBJ_TEXT, sub_window, dtTime, dPrice);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT,sText);
   ObjectSetInteger(lChartid,sName,OBJPROP_FONTSIZE,iFontWidth);         
   ObjectSetInteger(lChartid,sName,OBJPROP_COLOR,cFontColor);

}


void vSetLabel(long lChartid, string sName,int sub_window, int xx, int yy, int iFontSize, color cFontColor, string sText) export{

   ObjectCreate(lChartid,sName,OBJ_LABEL,sub_window,0,0);
   ObjectSetInteger(lChartid,sName, OBJPROP_YDISTANCE, xx);
   ObjectSetInteger(lChartid,sName, OBJPROP_XDISTANCE, yy);
   ObjectSetInteger(lChartid,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(lChartid,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT, 0,sText);

}




/*

void vSetHLine(long lChartid, string sName,int sub_window, double dPrice, color cFontColor, int iFontSize) {
   ObjectCreate(lChartid,sName,OBJ_HLINE,sub_window,0,0,dPrice);

   ObjectSetInteger(lChartid,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(lChartid,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT, 0,sText);
}

void vSetHLine (string sName,int sub_window, double dPrice, color cFontColor) {
   ObjectCreate(0,sName,OBJ_HLINE,sub_window,0,0);
   ObjectSetInteger(0,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetDouble(0,sName, OBJPROP_PRICE, dPrice);
}

*/