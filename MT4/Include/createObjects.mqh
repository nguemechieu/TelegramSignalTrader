


void vSetRectangle(string name, int sub_window, int xx, int yy, int width, int height, color bg_color, color border_clr, int border_width) {

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


void vSetBackground(string sName,int sub_window, int xx, int yy, int width, int height) {

   ObjectCreate(0,sName,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR,C'19,22,31');
   ObjectSetInteger(0,sName,OBJPROP_SELECTABLE,false);
   
}


void vSetArrow(long lChartid, string sName,int sub_window, datetime dtTime, double dPrice, int iFontWidth, color cFontColor, int iArrowCode) {

   ObjectCreate(lChartid,sName, OBJ_ARROW, sub_window, dtTime, dPrice);
   ObjectSetInteger(lChartid, sName, OBJPROP_ARROWCODE, iArrowCode);
   ObjectSetInteger(lChartid, sName, OBJPROP_WIDTH, iFontWidth);
   ObjectSetInteger(lChartid, sName, OBJPROP_COLOR, cFontColor);
   
}


void vSetText(long lChartid, string sName,int sub_window, datetime dtTime, double dPrice, int iFontWidth, color cFontColor, string sText) {

   ObjectCreate(lChartid,sName, OBJ_TEXT, sub_window, dtTime, dPrice);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT,sText);
   ObjectSetInteger(lChartid,sName,OBJPROP_FONTSIZE,iFontWidth);         
   ObjectSetInteger(lChartid,sName,OBJPROP_COLOR,cFontColor);

}


void vSetLabel(long lChartid, string sName,int sub_window, int xx, int yy, int iFontSize, color cFontColor, string sText) {

   ObjectCreate(lChartid,sName,OBJ_LABEL,sub_window,0,0);
   ObjectSetInteger(lChartid,sName, OBJPROP_YDISTANCE, xx);
   ObjectSetInteger(lChartid,sName, OBJPROP_XDISTANCE, yy);
   ObjectSetInteger(lChartid,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(lChartid,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT, 0,sText);

}





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

