//+------------------------------------------------------------------+
//|                                                    DibMax1-1.mq5 |
//|                                   Copyright 2020, Andrey Dibrov. |
//|                           https://www.mql5.com/ru/users/tomcat66 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrey Dibrov."
#property link      "https://www.mql5.com/ru/users/tomcat66"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE 
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_color1 LightSeaGreen
#property indicator_label1  "DibMax1-1"
//---- input parameters
input int History=500;
double Buf[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Buf,INDICATOR_DATA);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int    i,z,Calc;
   double price;
   
   i=iBars(NULL,PERIOD_H1)-1;
   if (i>History-1)i=History-1;
   if (History==0) i=iBars(NULL,PERIOD_H1)-1;
   ArraySetAsSeries(Buf,true);
   ArraySetAsSeries(time,true);
   
   while(i>=0)
     {
      int max=0;
      Calc=(int)time[i]%86400/3600;
      double max1=iHigh(NULL,PERIOD_D1,iBarShift(NULL,PERIOD_D1,iTime(NULL,PERIOD_H1,i)));
      for(z=0;z<=Calc;z++)
        {
          price=iHigh(NULL,PERIOD_H1,i+z);//+1-1
          if(max1>price)
          {
           max=1;
          }else
          {
           max=-1;
           break;
          }
         }   
      Buf[i]=max;
      i--;
      } 
   return(rates_total);
  }
//+------------------------------------------------------------------+
