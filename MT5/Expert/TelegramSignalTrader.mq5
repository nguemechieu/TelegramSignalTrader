//+------------------------------------------------------------------+
//|                                              TelegramTrader.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright. NOEL M NGUEMECHIEU"
#property link      "http:// www.tradeexpert.org/TelegramTrader"
#property version   "5.00"
#property strict
#include <DiscordTelegram/Comment.mqh>
#include <DiscordTelegram/Telegram.mqh>

const ENUM_TIMEFRAMES _periods[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
  {
private:
   ENUM_LANGUAGES    m_lang;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   string            m_template;
   CArrayString      m_templates;

public:
   //+------------------------------------------------------------------+
   void              Language(const ENUM_LANGUAGES _lang)
     {
      m_lang=_lang;
     }

   //+------------------------------------------------------------------+
   int               Templates(const string _list)
     {
      m_templates.Clear();
      //--- parsing
      string text=StringTrim(_list);
      if(text=="")
         return(0);

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      amount=fmin(amount,5);

      for(int i=0; i<amount; i++)
        {
         array[i]=StringTrim(array[i]);
         if(array[i]!="")
            m_templates.Add(array[i]);
        }

      return(amount);
     }

   //+------------------------------------------------------------------+
   int               SendScreenShot(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
                                    const string _template=NULL)
     {
      int result=0;

      long chart_id=ChartOpen(_symbol,_period);
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=60;
      while(--wait>0)
        {
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
            break;
         Sleep(500);
        }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(500);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(100);

      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
        {

         Sleep(100);

         //--- Need for MT4/mt5 on weekends !!!
         ChartRedraw(chart_id);

         bot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=60;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(300);

         //---
         if(FileIsExist(filename))
           {
            string screen_id;
            result=bot.SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
           }
         else
           {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
           }
        }

      ChartClose(chart_id);
      return(result);
     }
   int               OrderSends(ENUM_ORDER_TYPE order_type, long xchat,string symbol,double TP,double SL)
     {

      ENUM_ORDER_TYPE orderType= order_type;
      //--- declare and initialize the trade request and result of trade request
      MqlTradeRequest request= {};
      MqlTradeResult  result= {};
      //--- parameters to place a pending order
      request.action   =TRADE_ACTION_PENDING;                             // type of trade operation
      request.symbol   =symbol;                                         // symbol
      request.volume   =0.01;                                              // volume of 0.1 lot
      request.deviation=2;                                                // allowed deviation from the price
      request.magic    =234567;                                     // MagicNumber of the order
      int offset = 100;                                                    // offset from the current price to place the order, in points
      double price;                                                       // order triggering price
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);                // value of point
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);                // number of decimal places (precision)
      //--- checking the type of operation
      if(orderType==ORDER_TYPE_BUY_LIMIT)
        {
         request.type     =ORDER_TYPE_BUY_LIMIT;                          // order type
         price        =SymbolInfoDouble(symbol,SYMBOL_ASK); // price for opening
         request.price=NormalizeDouble(price,digits);
         request.sl=price- SL*point;
         request.tp=price+ TP*point;
        }
      else
         if(orderType==ORDER_TYPE_SELL_LIMIT)
           {
            request.type     =ORDER_TYPE_SELL_LIMIT;
            price=SymbolInfoDouble(symbol,SYMBOL_BID);         // price for opening
            request.price    =NormalizeDouble(price,digits);
            request.sl=price+ SL*point;
            request.tp=price- TP*point;                              // order type

           }
         else
            if(orderType==ORDER_TYPE_BUY_STOP)
              {
               request.type =ORDER_TYPE_BUY_STOP;                                // order type
               price        =SymbolInfoDouble(symbol,SYMBOL_ASK)+offset*point; // price for opening
               request.price=NormalizeDouble(price,digits);
               request.sl=price- SL*point;
               request.tp=price+ TP*point;                   // normalized opening price
              }
            else
               if(orderType==ORDER_TYPE_SELL_STOP)
                 {
                  request.type     =ORDER_TYPE_SELL_STOP;                           // order type
                  price=SymbolInfoDouble(symbol,SYMBOL_BID)-offset*point;         // price for opening
                  request.price    =NormalizeDouble(price,digits);
                  request.sl=price+ SL*point;
                  request.tp=price- TP*point;              // normalized opening price
                 }

               else
                  if(orderType== ORDER_TYPE_BUY)
                    {
                     request.type     =ORDER_TYPE_BUY;
                     request.action=TRADE_ACTION_DEAL;
                     price=SymbolInfoDouble(symbol,SYMBOL_ASK);                            // order type
                     // price for opening
                     request.price  =SymbolInfoDouble(symbol,SYMBOL_ASK);
                     request.sl=0;
                     request.tp=price+ TP*point;
                    }
                  else
                     if(orderType== ORDER_TYPE_SELL)
                       {
                        request.type     =ORDER_TYPE_SELL;
                        request.action=TRADE_ACTION_DEAL;                          // order type
                        price=SymbolInfoDouble(symbol,SYMBOL_BID);
                        // order type
                        // price for opening

                        request.price=price;
                        request.sl=0;
                        request.tp=price- TP*point;
                       }
                     else
                        Alert("This Unsupported orders");   // if not pending order is selected
      //--- send the request
      int ticket=0;
      if(!OrderSend(request,result))
        {
         PrintFormat("OrderSend error"+symbol+" %d",GetLastError());
         ticket=OrderSend(request,result);
         SendMessage(xchat,"OrderSend error "+symbol+" %s"+request.symbol +"\n"+request.comment+"\n"+ result.comment);
        }             // if unable to send the request, output the error code
      //--- information about the operation
      PrintFormat("ret=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,(string)result.order +"  "+symbol);
      if(ticket<0)
        {
         SendMessage(xchat,StringFormat("Trade=%u  deal=%I64u  order=%I64u",(string)result.retcode,(string)result.deal,(string)result.order +" @"+ symbol));


        }
      else
        {
         SendMessage(xchat,StringFormat("Trade=%u  deal=%I64u  order=%I64u",(string)result.retcode,(string)result.deal,(string)result.order +" @"+ symbol));

        }
      return  ticket;
     }

   //+------------------------------------------------------------------+
   void              ProcessMessages(void)
     {


      MqlTradeRequest trade;
      MqlTradeResult tradeResult;

#define EMOJI_TOP    "\xF51D"
#define EMOJI_BACK   "\xF519"
#define KEYB_MAIN    (m_lang==LANGUAGE_EN)?"[[\"Account Info\"],[\"Quotes\"],[\"Charts\"],[\"trade\"],[\"analysis\"],[\"OrderTotal\"],[\"report\"],[\"news\"]]":"[[\"Информация\"],[\"Котировки\"],[\"Графики\"]]"
#define KEYB_SYMBOLS "[[\""+EMOJI_TOP+"\",\"GBPUSD\",\"EURUSD\"],[\"AUDCAD\",\"EURCAD\"],[\"AUDUSD\",\"USDJPY\",\"EURJPY\"],[\"USDCAD\",\"USDCHF\",\"EURCHF\"],[\"EURCAD\"],[\"USDCHF\"],[\"USDDKK\"],[\"USDJPY\"],[\"AUDCAD\"]]"
#define KEYB_PERIODS "[[\""+EMOJI_TOP+"\",\"M1\",\"M5\",\"M15\"],[\""+EMOJI_BACK+"\",\"M30\",\"H1\",\"H4\"],[\" \",\"D1\",\"W1\",\"MN1\"]]"
#define  KEYB_TRADES "[[\""+EMOJI_TOP+"\",\"BUY\",\"SELL\",\"BUY_LIMT\"],[\""+EMOJI_BACK+"\",\"SELLLIMIT\",\"BUY_STOP\",\"SELL_STOP\"]]"
      for(int i=0; i<m_chats.Total(); i++)

        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;


          string currencyList[];
          string symb
          ;
          for(i=0;i<StringSplit(currencyLists,',',currencyList);i++){
            if(StringFind(text,currencyList[i],0)){
            
            symb=currencyList[i];
            break;
            }}


            //--- start
            if(text=="/start" || text=="/help")
              {
               chat.m_state=0;
               string msg="The bot works with your trading account:\n";
               msg+="/Info - get account information\n";
               msg+="/Quotes - get quotes\n";
               msg+="/Charts - get chart images\n";
               msg+="/Trade- start live  trade\n";
               msg+="/News -get market news events\n";
               msg+="/OrderTotal - get All open orders number";


               msg+="/analysis  - get market analysis\n";

               if(m_lang==LANGUAGE_RU)
                 {
                  msg="Бот работает с вашим торговым счетом:\n";
                  msg+="/info - запросить информацию по счету\n";
                  msg+="/quotes - запросить котировки\n";
                  msg+="/charts - запросить график\n";
                  msg+="/trade";
                  msg+="/news";
                  msg+="/analysis";

                 }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
              }

            //---
            if(text==EMOJI_TOP)
              {
               chat.m_state=0;
               string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
              }

            //---
            if(text==EMOJI_BACK)
              {
               if(chat.m_state==31)
                 {
                  chat.m_state=3;
                  string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
                 }
               else
                  if(chat.m_state==32)
                    {
                     chat.m_state=31;
                     string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                     SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
                    }
                  else
                    {
                     chat.m_state=0;
                     string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
                     SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
                    }
               continue;
              }

            //---
            if(text=="/Info" ||text=="info" || text=="Account Info" || text=="Информация")
              {
               chat.m_state=1;
               string currency=AccountInfoString(ACCOUNT_CURRENCY);
               string msg=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"BALANCE":"Баланс",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"PROFIT ":"Прибыль",AccountInfoDouble(ACCOUNT_PROFIT),currency);
              msg+="OrderTotal :"+(string)OrdersTotal()+"\n";
              msg+="Margin :"+ (string)AccountInfoDouble(ACCOUNT_MARGIN)+"\n";
             msg+="FREE Margin :"+(string) AccountInfoDouble(ACCOUNT_MARGIN_FREE)+"\n";
                 msg+="EQUITY :"+(string) AccountInfoDouble(ACCOUNT_EQUITY);
                     msg+="LIABILITIES :"+ (string)AccountInfoDouble(ACCOUNT_LIABILITIES);
                         msg+="Margin INITIAL:"+ (string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL);
                             msg+="Margin MAINTENANCE :"+ (string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
                                 msg+="Commission blocked :"+ (string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
              
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
              }

            //---
            if(text=="/quotes" || text=="Quotes" || text=="Котировки")
              {
               chat.m_state=2;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
              }

            //---
            if(text=="/charts" || text=="/Charts" || text=="Charts")
              {
               chat.m_state=3;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
              }
            //Trade



            int ticket;
            string sym[1];

            if(text== "/Trade" || text=="trade" ||text=="Trade")
              {
               chat.m_state=4;
               string msg="=======TRADE MODE====== \nSelect a Pair (EURUSD)";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));

               continue;
              }
            if(text=="/Analysis"|| text=="analysis")
              {

               string msg="=========== Market Analysis ==========";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));

              }

            if(text=="/report"|| text=="report")
              {
               string msg="======== Trade Report ======";

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,true));



              }

            if(text=="/OrderTotal"|| text =="OrderTotal" || text=="ordertotal" || text=="orderTotal")
              {
               string msg="========Order ToTal ======\n Total :"+ (string)OrdersTotal();
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,true));

              }



            if(chat.m_state==4)
              {





           
           
              
         if(text!="trade"|| text!="/Trade" ||text!="null")
         {
                  sym[0]=symb;
         }else {
                  SendMessage(chat.m_id,"Something  wrong!",ReplyKeyboardMarkup(KEYB_MAIN,false,false));
              
              }
 chat.m_state =5;

                }
            if(chat.m_state==5)
              {

              
               if(text !="Select a Pair" || text!="null" || text!="")
                 {



                  chat.m_state =5;
                  SendMessage(chat.m_id,sym[0],

                              ReplyKeyboardMarkup(KEYB_TRADES,false,false));


                 }
               else
                 {
                  SendMessage(chat.m_id,"",

                              ReplyKeyboardMarkup(KEYB_TRADES,false,false));


                 }


              }





            //--- Quotes
            if(chat.m_state==2)
              {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
               string msg=StringFormat(mask,text);
               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
                 {
                  double open[1]= {0};

                  m_symbol=symbol;
                  //--- upload history
                  for(int k=0; k<3; k++)
                    {
#ifdef __MQL4__
                     double array[][6];
                     ArrayCopyRates(array,symbol,PERIOD_D1);
#endif

                     Sleep(2000);
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                    }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                    {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg=StringFormat("%s: %s %s (%s%%)",symbol,DoubleToString(bid,digits),sign,DoubleToString(percent,2));
                    }
                  else
                    {
                     msg=(m_lang==LANGUAGE_EN)?"No history for ":"Нет истории для "+symbol;
                    }
                 }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
              }





            if(text == "BUY@"+sym[0])
              {
               if(text == "BUY@"+sym[0])
                 {

                  SendMessage(chat.m_id,"Telegram @BUY" +sym[0]+"SIGNAL ORDER Send!");

                  ticket =OrderSends(ORDER_TYPE_BUY,chat.m_id,sym[0],100,100);

                 }
               if(text == "SELL@"+sym[0] )
                 {

                  SendMessage(chat.m_id,"Telegram @SELL" + sym[0]+" SIGNAL ORDER Send!");
                  ticket =OrderSends(ORDER_TYPE_SELL,chat.m_id,sym[0],100,100);

                 }

              }
            else
               if(text =="SELL")
                 {
                  ticket =OrderSends(ORDER_TYPE_BUY,chat.m_id,sym[0],100,100);
                 }
            //--- Charts
            if(chat.m_state==3)
              {

               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
                 {
                  m_symbol=symbol;

                  chat.m_state=31;
                  string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
                 }
               else
                 {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  string msg=StringFormat(mask,text);
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
                 }
               continue;

              }



            if(chat.m_state==5)
              {

               printf("sym "+sym[0]);

               if(text =="BUY")
                 {
                  ticket =OrderSends(ORDER_TYPE_SELL,chat.m_id,sym[0],0,0);
                  if(text == "BUY@"+sym[0])
                    {

                     SendMessage(chat.m_id,"Telegram @BUY SIGNAL ORDER Send!");
                    }
                  if(text == "SELL@"+sym[0])
                    {
                     SendMessage(chat.m_id,"Telegram @BUY SIGNAL ORDER Send!");
                    }

                 }
               else
                  if(text =="SELL"||text=="SELL@"+sym[0]  )
                    {
                     ticket =OrderSends(ORDER_TYPE_BUY,chat.m_id,sym[0],0,0);
                    }
                  
           
           
              if(text =="BUYLIMIT")
                       {
                        ticket =OrderSends(ORDER_TYPE_BUY_LIMIT,chat.m_id,sym[0],0,0);

                       }
                     else
               if(text =="SELLLIMIT")
                          {
                           ticket =OrderSends(ORDER_TYPE_SELL_LIMIT,chat.m_id,sym[0],0,0);

                          }
                else if(text =="BUY_STOP")
                             {
                              ticket =OrderSends(ORDER_TYPE_BUY_STOP,chat.m_id,sym[0],0,0);
                             }
                 else if(text =="SELL_STOP")
                                {
                                 ticket =OrderSends(ORDER_TYPE_SELL_STOP,chat.m_id,sym[0],0,0);
                                }
                              else
                                 chat.m_state=4;


              }



            //Charts->Periods
            if(chat.m_state==31)
              {
               bool found=false;
               int total=ArraySize(_periods);
               for(int k=0; k<total; k++)
                 {
                  string str_tf=StringSubstr(EnumToString(_periods[k]),7);
                  if(StringCompare(str_tf,text,false)==0)
                    {
                     m_period=_periods[k];
                     found=true;
                     break;
                    }
                 }

               if(found)
                 {
                  //--- template
                  chat.m_state=32;
                  string str="[[\""+EMOJI_BACK+"\",\""+EMOJI_TOP+"\"]";
                  str+=",[\"None\"]";
                  for(int k=0; k<m_templates.Total(); k++)
                     str+=",[\""+m_templates.At(k)+"\"]";
                  str+="]";

                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"Выберите шаблон",ReplyKeyboardMarkup(str,false,false));
                 }
               else
                 {
                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"Неправильно задан период графика",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
                 }
               continue;
              }
            //---
            if(chat.m_state==32)
              {
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=SendScreenShot(chat.m_id,m_symbol,m_period,m_template);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
              }
           }
        }



     }


  };
//+------------------------------------------------------------------+
#define EXPERT_NAME     "Telegram Bot"
#define EXPERT_VERSION  "1.00"
#property version       EXPERT_VERSION
#define CAPTION_COLOR   clrWhite
#define LOSS_COLOR      clrOrangeRed

//+------------------------------------------------------------------+
//|   Input parameters                                               |
//+------------------------------------------------------------------+
input ENUM_LANGUAGES    InpLanguage=LANGUAGE_EN;//Language
input ENUM_UPDATE_MODE  InpUpdateMode=UPDATE_NORMAL;//Update Mode
input string            InpToken="";//Token

input string            InpUserNameFilter="";//Whitelist Usernames
input string            InpTemplates="Stochasti, Ichimoku, ADX,BollingerBands,Momentum";//Templates (Indicators templates)
input string channel_name="" ;//Channel


input ENUM_LICENSE_TYPE license =LICENSE_DEMO;
input string password="noel301@";
input string currencyLists="EURUSD,AUDUSD,USDCAD,USDJPY,GBPUSD,AUDCHF,AUDCAD,USDKK";
//---
CComment       comment;
CMyBot         bot;
ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;
string         photo_id=NULL;


//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   datetime date=D'2024.04.29 00:00';

   if(license==LICENSE_DEMO)
     {


      if(TimeCurrent()<date)
        {

         Comment("Welcome to TelegramTrader !\n Your Trial will expired "+(string)date);
        }
      else
        {

         Comment("Welcome to TelegramTrader !\n Your Trial has expired  since "+(string)date+ "Contact Support!To get a new license.");
         return 0;

        }


     }
   else
      if(license==LICENSE_TIME)
        {


         return 0;
        }
      else
         if(license==LICENSE_FULL && password =="Noel307!")
           {
            Comment("Welcome to TelegramTrader !\n  "+(string)LICENSE_FULL+" "+(string)date);

           }
         else
           {
            Comment("Invalid license key !\n  "+(string)LICENSE_FULL+" "+(string)date);
            return 0;
           }

//---
   run_mode=GetRunMode();

//--- stop working in tester
   if(run_mode!=RUN_LIVE)
     {
      PrintError(ERR_RUN_LIMITATION,InpLanguage);
      return(INIT_FAILED);
     }

   int y=40;
   if(ChartGetInteger(0,CHART_SHOW_ONE_CLICK))
      y=120;
   comment.Create("myPanel",20,y);
   comment.SetColor(clrDimGray,clrBlack,220);
//--- set language
   bot.Language(InpLanguage);

//--- set token
   init_error=bot.Token(InpToken);

//--- set filter
   bot.UserNameFilter(InpUserNameFilter);

//--- set templates
   bot.Templates(InpTemplates);

//--- set timer
   int timer_ms=3000;
   switch(InpUpdateMode)
     {
      case UPDATE_FAST:
         timer_ms=1000;
         break;
      case UPDATE_NORMAL:
         timer_ms=2000;
         break;
      case UPDATE_SLOW:
         timer_ms=3000;
         break;
      default:
         timer_ms=3000;
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
   if(reason==REASON_CLOSE ||
      reason==REASON_PROGRAM ||
      reason==REASON_PARAMETERS ||
      reason==REASON_REMOVE ||
      reason==REASON_RECOMPILE ||
      reason==REASON_ACCOUNT ||
      reason==REASON_INITFAILED)
     {
      time_check=0;
      comment.Destroy();
     }
//---
   EventKillTimer();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|   OnChartEvent                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   comment.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {

//--- show init error
   if(init_error!=0)
     {
      //--- show error on display
      CustomInfo info;
      GetCustomInfo(info,init_error,InpLanguage);

      //---
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),clrAquamarine);
      comment.SetText(2,info.text1, LOSS_COLOR);
      if(info.text2!="")
         comment.SetText(2,info.text2,LOSS_COLOR);
      comment.Show();

      return;
     }

//--- show web error
   if(run_mode==RUN_LIVE)
     {

      //--- check bot registration
      if(time_check<TimeLocal()-PeriodSeconds(PERIOD_H1))
        {
         time_check=TimeLocal();
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            //---
            web_error=bot.GetMe();
            if(web_error!=0)
              {
               //---
               if(web_error==ERR_NOT_ACTIVE)
                 {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+300;
                 }
               //---
               else
                 {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+5;
                 }
              }
           }
         else
           {
            web_error=ERR_NOT_CONNECTED;
            time_check=0;
           }
        }

      //--- show error
      if(web_error!=0)
        {
         comment.Clear();
         comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);

         if(
#ifdef __MQL4__ web_error==ERR_FUNCTION_NOT_CONFIRMED #endif
#ifdef __MQL5__ web_error==ERR_FUNCTION_NOT_ALLOWED #endif
         )
           {
            time_check=0;

            CustomInfo info= {};
            GetCustomInfo(info,web_error,InpLanguage);
            comment.SetText(1,info.text1,LOSS_COLOR);
            comment.SetText(2,info.text2,LOSS_COLOR);
           }
         else
            comment.SetText(1,GetErrorDescription(web_error,InpLanguage),LOSS_COLOR);

         comment.Show();
         return;
        }
     }

//---
   bot.GetUpdates();

//---
   if(run_mode==RUN_LIVE)
     {
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);
      comment.SetText(1,StringFormat("%s: %s",(InpLanguage==LANGUAGE_EN)?"Bot Name":"Имя Бота",bot.Name()),CAPTION_COLOR);
      comment.SetText(2,StringFormat("%s: %d",(InpLanguage==LANGUAGE_EN)?"Chats":"Чаты",bot.ChatsTotal()),CAPTION_COLOR);
      comment.Show();
     }

//---
   bot.ProcessMessages();
  }
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
         info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
         info.text2 = TELEGRAM_BASE_URL;
         break;
#endif
#ifdef __MQL4__
      case ERR_FUNCTION_NOT_CONFIRMED:
         info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
         info.text2 = TELEGRAM_BASE_URL;
         break;
#endif

      case ERR_TOKEN_ISEMPTY:
         info.text1 = (_lang==LANGUAGE_EN)?"The 'Token' parameter is empty.":"Параметр 'Token' пуст.";
         info.text2 = (_lang==LANGUAGE_EN)?"Please fill this parameter.":"Пожалуйста задайте значение для этого параметра.";
         break;
     }

  }
//+------------------------------------------------------------------+
