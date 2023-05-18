//+------------------------------------------------------------------+
//|                                             PythonTestExpert.mq5 |
//|                                   Copyright 2020, Andrey Dibrov. |
//|                           https://www.mql5.com/ru/users/tomcat66 |
//+------------------------------------------------------------------+
#property copyright " Copyright © 2019, Andrey Dibrov."
#property link      "https://www.mql5.com/ru/users/tomcat66"
#property version   "1.00"
#property strict

int handleInput;
int HandleDate;
//int hour=23;

double in[22];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handleInput=FileOpen(Symbol()+"Test.csv",FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_ANSI|FILE_COMMON,";");
   HandleDate=FileOpen(Symbol()+"Date.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_COMMON,";");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   FileClose(handleInput);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlDateTime stm;
   TimeToStruct(TimeCurrent(),stm);
   
   for(int i=0; i<=14; i++)
     {
      in[i]=in[i+5];
     }

   in[15]=((iOpen(NULL,PERIOD_D1,0)-iLow(NULL,PERIOD_D1,0))*100000);
   in[16]=((iHigh(NULL,PERIOD_D1,0)-iOpen(NULL,PERIOD_D1,0))*100000);
   in[17]=((iHigh(NULL,PERIOD_D1,0)-iLow(NULL,PERIOD_D1,0))*10000);//10000
   in[18]=((iHigh(NULL,PERIOD_D1,0)-iOpen(NULL,PERIOD_H1,1))*10000);
   in[19]=((iOpen(NULL,PERIOD_H1,1)-iLow(NULL,PERIOD_D1,0))*10000);


   in[20]=((iHigh(NULL,PERIOD_D1,0)-iOpen(NULL,PERIOD_H1,0))*10000);
   in[21]=((iOpen(NULL,PERIOD_H1,0)-iLow(NULL,PERIOD_D1,0))*10000);

//if(stm.hour>hour)
//  {
//   for(int i=0; i<=14; i++)
//     {
//      in[i]=in[i+5];
//     }
//  }
//hour=stm.hour;
//for(int i=14; i>=10; i--)
//{
//in[i-5]=in[i];
//}

//for(int i=19; i>=15; i--)
//{
//in[i-5]=in[i];
//}
//}

   FileWrite(handleInput,

             in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7],in[8],in[9],in[10],in[11],in[12],in[13],in[14],in[15],
             in[16],in[17],in[18],in[19],in[20],in[21]);

   FileWrite(HandleDate,TimeCurrent());

  }
//+------------------------------------------------------------------+
