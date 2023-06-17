   //+------------------------------------------------------------------+
   //|                                  TelegramSignalTrader.mq4 |
   //|                                  Copyright 2023, tradeadviser Llc. |
   //|                                             https://www.tradeadviser.org |
   //+------------------------------------------------------------------+
   #property copyright "Copyright 2023, Tradeadviser LLc."
   #property link      "https://www.tradeadviser.org"
   #property strict
   //+------------------------------------------------------------------+
   #define EXPERT_NAME     "TelegramSignalTrader"
   #define EXPERT_VERSION  "1.01"
   #property version       EXPERT_VERSION
   #define CAPTION_COLOR   clrYellow
   #define LOSS_COLOR      clrOrangeRed
   #include <stdlib.mqh>
   #include <stderror.mqh>
   #include <DiscordTelegram\Comment.mqh>
   #include <DiscordTelegram\Telegram.mqh>

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

            //--- Need for MT4 on weekends !!!
            ChartRedraw(chart_id);

            bot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);

            //--- waitng 30 sec for save screenshot
            wait=60;
            while(!FileIsExist(filename) && --wait>0)
               Sleep(500);

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

      //+------------------------------------------------------------------+
      void              ProcessMessages(void)
      {

   #define EMOJI_TOP    "\xF51D"
   #define EMOJI_BACK   "\xF519"
   #define KEYB_MAIN    (m_lang==LANGUAGE_EN)?"[[\"Account Info\"],[\"Quotes\"],[\"Charts\"],[\"trade\"],[\"analysis\"],[\"report\"]]":"[[\"Информация\"],[\"Котировки\"],[\"Графики\"]]"
   #define KEYB_SYMBOLS "[[\""+EMOJI_TOP+"\",\"GBPUSD\",\"EURUSD\"],[\"AUDUSD\",\"USDJPY\",\"EURJPY\"],[\"USDCAD\",\"USDCHF\",\"EURCHF\"],[\"EURCAD\"],[\"USDCHF\"],[\"USDDKK\"],[\"USDJPY\"],[\"AUDCAD\"]]"
   #define KEYB_PERIODS "[[\""+EMOJI_TOP+"\",\"M1\",\"M5\",\"M15\"],[\""+EMOJI_BACK+"\",\"M30\",\"H1\",\"H4\"],[\" \",\"D1\",\"W1\",\"MN1\"]]"
   #define  TRADE_SYMBOLS "[[\""+EMOJI_TOP+"\",\"BUY\",\"SELL\",\"BUY_LIMT\"],[\""+EMOJI_BACK+"\",\"SELLLIMIT\",\"BUY_STOP\",\"SELL_STOP\"]]"
         for(int i=0; i<m_chats.Total(); i++)

         {
            CCustomChat *chat=m_chats.GetNodeAtIndex(i);
            if(!chat.m_new_one.done)
            {
               chat.m_new_one.done=true;
               string text=chat.m_new_one.message_text;

               //--- start
               if(StringFind(text,"start")>=0 || StringFind(text,"help")>=0)
               {
                  chat.m_state=0;
                  string msg="The bot works with your trading account:\n";
                  msg+="/info - get account information\n";
                  msg+="/quotes - get quotes\n";
                  msg+="/charts - get chart images\n";
                  msg+="/trade- start live  trade";

                  msg+="/account -- get account infos ";
                  msg+="/analysis  -- get market analysis";

                  if(m_lang==LANGUAGE_RU)
                  {
                     msg="Бот работает с вашим торговым счетом:\n";
                     msg+="/info - запросить информацию по счету\n";
                     msg+="/quotes - запросить котировки\n";
                     msg+="/charts - запросить график\n";
                     msg+="/trade";

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
                  else if(chat.m_state==32)
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
               if(text=="/info" || text=="Account Info" || text=="Информация")
               {
                  chat.m_state=1;
                  string currency=AccountInfoString(ACCOUNT_CURRENCY);
                  string msg=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
                  msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Balance":"Баланс",AccountInfoDouble(ACCOUNT_BALANCE),currency);
                  msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Profit":"Прибыль",AccountInfoDouble(ACCOUNT_PROFIT),currency);
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
                  continue;
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
               if(text=="/charts" || text=="Charts" || text=="chart"|| text=="Графики")
               {
                  chat.m_state=3;
                  string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
                  continue;
               }
               //Trade



               if(text== "/trade" || text=="trade"){

               string msg="=======TRADE MODE====== \nSelect symbol!";
                SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               chat.m_state =4;

              }
              if(text=="/analysis"|| text=="analysis"){

                string msg="=========== Market Analysis ==========";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(TRADE_SYMBOLS,false,false));
               chat.m_state=7;

              }
             if(text=="/report"||text=="report"){
               string msg="========Trade Report ======";
               msg=StringFormat("Date %s\nBalance %s\nEquity %s\nProfit %s\nDaily Losses %s\nExpected Return :%s\n Weekly Report%s\n",
               TimeToStr(TimeCurrent()), DoubleToStr(AccountBalance()),
               DoubleToStr(AccountEquity()), DoubleToStr(-AccountBalance()+AccountEquity()),
              DoubleToStr( 1),DoubleToStr((AccountEquity()/AccountBalance())*100),

              ((SymbolName(i,false)==text)? text:Symbol()) +(string)(0)+ " pips"

               );

                SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));

                chat.m_state=6;
              }




   int ticket=0;
   string symbol="";
        //CREATE ORDERS

              ObjectCreate(ChartID(),"symb", OBJ_LABEL,0,Time[0],MarketInfo(      Symbol(),MODE_ASK));

        //SEARCHING  SYMBOL TO CREATE ORDER
        for(int j=0;j<SymbolsTotal(false);j++){
                 StringToUpper(text);
        if(StringFind(text,SymbolName(j,false),0)>=0){
              string symb=  SymbolName(j,false);

             ObjectSetInteger(ChartID(),"symb",OBJPROP_YDISTANCE,200);

             ObjectSetInteger(ChartID(),"symb",OBJPROP_XDISTANCE,1);

             ObjectSetText("symb","Telegram Symbol: "+        symb,13,NULL,clrYellow);

             if(ImmediateExecution==MARKET_ORDERS){

               if(StringFind(text,"SELL",0)>=0){

               ticket =myOrderSend(symb,OP_SELL,MarketInfo(symb,MODE_BID),Lots,"MARKET SELL ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
                return;

                 }else
                       if(StringFind(text,"BUY",0)>=0){

               ticket =myOrderSend(symb,OP_BUY,MarketInfo(symb,MODE_ASK),Lots,"MARKET BUY ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
                return;

                 }


          }else

          if(ImmediateExecution==LIMIT_ORDERS){


                   if(StringFind(text,"BUY",0)>=0 ){
                  ticket =myOrderSend(symb,OP_BUYLIMIT,MarketInfo(symb,MODE_ASK),Lots,"BUY LIMIT ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
                return;
              }
              else

              if( StringFind(text,"SELL",0)>=0 ){

                ticket =myOrderSend(symb,OP_SELLLIMIT,MarketInfo(symb,MODE_BID),Lots,"SELL Limit ORDER");

                 if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
                 return  ;

              }

           }else

             if (ImmediateExecution==STOPLOSS_ORDERS){


              if(StringFind(text,"BUY",0)>=0 ){
               ticket =myOrderSend(symb,OP_BUYSTOP,MarketInfo(symb,MODE_ASK),Lots,"BUY STOPLOSS ORDER");
                if(ticket<0){SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
              return;
              }
              }
              else
                    if(StringFind(text,"SELL",0)>=0){
                 ticket =myOrderSend(symb,OP_SELLSTOP,MarketInfo(symb,MODE_BID),Lots,"SELL STOPLOSS ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ ErrorDescription(GetLastError()));
                  }



            }


          }
                  j++;
                  break;
                 }

               //--- Quotes
               if(chat.m_state==2)
               {
                  string mask=(m_lang==LANGUAGE_EN)?"  Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  string msg=StringFormat(mask,text);
                  StringToUpper(text);
                  symbol=text;
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
     ArrayResize(symbols,SymbolsTotal(false),0);
               //--- Charts
               if(chat.m_state==3)
               {

                  StringToUpper(text);
                  symbol=text;
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



    if(i<SymbolsTotal(false)){



                for (int j =0;j<SymbolsTotal(false);j++){
                  if(StringFind(text,SymbolName(j,false),0)>=0){

                symbols[0]=SymbolName(j,false);
                          Comment(symbols[0]);
                break;
                }

                }

             }




                printf("sym[0] :"+symbols[0]);
                if(StringFind(text,"BUY",0)>=0 )
                  {

               myOrderSend(symbols[0],OP_BUY,MarketInfo(symbols[0],MODE_ASK),Lots,"MARKET BUY  ORDER");


              }else

               if(StringFind(text,"SELL",0)>=0 ){

               myOrderSend(symbols[0],OP_SELL,MarketInfo(symbols[0],MODE_BID),Lots,"MARKET SELL ORDER");


                 }

                  // CREATE LIMIT ORDERS

              if(StringFind(text,"BUYLIMIT",0)>=0 ){
                  ticket =myOrderSend(symbols[0],OP_BUYLIMIT,MarketInfo(symbols[0],MODE_ASK),Lots,"BUY LIMIT ORDER");

              }
              else

              if( StringFind(text,"SELLLIMIT",0)>=0 ){

                ticket =myOrderSend(symbols[0],OP_SELLLIMIT,MarketInfo(symbols[0],MODE_BID),Lots,"SELL Limit ORDER");
                ;

              }

             // CREATE STOPLOSS ORDER
              if(StringFind(text,"BUYSTOP",0)>=0 ){
               ticket =myOrderSend(symbols[0],OP_BUYSTOP,MarketInfo(symbols[0],MODE_ASK),Lots,"BUY STOPLOSS ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
              }else

               if(StringFind(text,"SELLSTOP",0)>=0 ){
                 ticket =myOrderSend(symbols[0],OP_SELLSTOP,MarketInfo(symbols[0],MODE_BID),Lots,"SELL STOPLOSS ORDER");
                      }



        if(chat.m_state ==4){

             if(i<SymbolsTotal(false)){

                for (int j =0;j<SymbolsTotal(false);j++){
                  if(StringFind(text,SymbolName(j,false),0)>=0){

                symbols[0]=SymbolName(j,false);
                      SendMessage(chat.m_id,"Click buttons to trade",ReplyKeyboardMarkup(TRADE_SYMBOLS,false,false));
                    chat.m_state=5;
                    Comment(symbols[0]);
                break;  }

                }

             }
         }



          while(chat.m_state==5){


                printf("sym[0] :"+symbols[0]);
                if(StringFind(text,"BUY",0)>=0 )
                  {

               myOrderSend(symbols[0],OP_BUY,MarketInfo(symbols[0],MODE_ASK),Lots,"MARKET BUY  ORDER");


              }else

               if(StringFind(text,"SELL",0)>=0 ){

               myOrderSend(symbols[0],OP_SELL,MarketInfo(symbols[0],MODE_BID),Lots,"MARKET SELL ORDER");


                 }

                  // CREATE LIMIT ORDERS

              if(StringFind(text,"BUYLIMIT",0)>=0 || StringFind(text,"BUY_LIMIT",0)>=0 ){
                  ticket =myOrderSend(symbols[0],OP_BUYLIMIT,MarketInfo(symbols[0],MODE_ASK),Lots,"BUY LIMIT ORDER");

              }
              else

              if( StringFind(text,"SELLLIMIT",0)>=0||StringFind(text,"SELL_LIMIT",0)>=0 ){

                ticket =myOrderSend(symbols[0],OP_SELLLIMIT,MarketInfo(symbols[0],MODE_BID),Lots,"SELL Limit ORDER");
                ;

              }

             // CREATE STOPLOSS ORDER
              if(StringFind(text,"BUYSTOP",0)>=0|| StringFind(text,"BUY_STOP",0)>=0 ){
               ticket =myOrderSend(symbols[0],OP_BUYSTOP,MarketInfo(symbols[0],MODE_ASK),Lots,"BUY STOPLOSS ORDER");
                if(ticket<0)SendMessage(chat.m_id," ERROR "+ GetErrorDescription(GetLastError(),0));
              }else

               if(StringFind(text,"SELLSTOP",0)>=0||StringFind(text,"SELL_STOP",0)>=0 ){
                 ticket =myOrderSend(symbols[0],OP_SELLSTOP,MarketInfo(symbols[0],MODE_BID),Lots,"SELL STOPLOSS ORDER");
                      }
              break;
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
   //|   Input parameters                                               |
   //+------------------------------------------------------------------+
    ENUM_LANGUAGES    InpLanguage =LANGUAGE_EN;//Language
   input ENUM_UPDATE_MODE  InpUpdateMode=UPDATE_NORMAL;//Update Mode
   input string            InpToken="2125623831:AAGtuhGO9JxHh72nYfD6WN6mog7UkDIIL0o";//Token
   input long ChatID=-1001648392740;//CHAT OR GROUP ID

      input string CHANNEL_NAME ="tradeexpert_infos";
    long TELEGRAM_GROUP_CHAT_ID= ChatID;
    string            InpUserNameFilter="";//Whitelist Usernames
 input   string            InpTemplates="Moving Average, Ichimoku, ADX,BollingerBands,Momentum";//Templates for screenshot

   //I need an expert to develop a Telegram to MT4 & MT5 copying system with the following functions:

   enum EXECUTION_MODE{MARKET_ORDERS,LIMIT_ORDERS,STOPLOSS_ORDERS};

   input EXECUTION_MODE  ImmediateExecution;// TRADE MODE

   enum MONEY_MANAGEMENT{
   RISK_PERCENTAGE,
   POSITION_SIZE,
   MARTINGALE,
   FIXED_SIZE
   }
   ;

     string symbols[];
   input MONEY_MANAGEMENT  money_management;// MONEY MANAGEMENT
    input bool  Move_SL_Automatically= true; // MOVE SL AUTOMATICALLY
    input bool  Move_TP_to_Breakeven=true;//MOVE TP TO BREAKEVEN


   input int slippage=3; //SLIPPAGE
   input int stoploss=100;// SL IN POINT
   input int takeprofit=100;//TP IN POINT
   enum Answer {yes, no};


   enum DYS_WEEK
     {
      Sunday = 0,
      Monday = 1,
      Tuesday = 2,
      Wednesday,
      Thursday = 4,
      Friday = 5,
      Saturday
     };

   enum TIME_LOCK
     {
      closeall,//CLOSE_ALL_TRADES
      closeprofit,//CLOSE_ALL_PROFIT_TRADES
      breakevenprofit//MOVE_PROFIT_TRADES_TO_BREAKEVEN
     };



   extern string  h1                   = "===Time Management System==="; // =========Monday==========
   input  Answer   SET_TRADING_DAYS     = no;
   input  DYS_WEEK EA_START_DAY        = Sunday;
   input string EA_START_TIME          = "22:00";
   input DYS_WEEK EA_STOP_DAY          = Friday;
   input string EA_STOP_TIME          = "22:00";


        input string fsiz;//FIXED SIZE PARAMS
   input double lotSize=0.01;   //FIXED SIZE

  input string sddd; //MATINGALE PARAMS
input   double MM_Martingale_Start = 0.01;
input double MM_Martingale_ProfitFactor = 1;
input double MM_Martingale_LossFactor = 2;
input bool MM_Martingale_RestartProfit = true;
input bool MM_Martingale_RestartLoss = false;
input int MM_Martingale_RestartLosses = 1000;
input int MM_Martingale_RestartProfits = 1000;
input string psds;//POSITION SIZE PARAMS


input double MM_PositionSizing = 10000;


   //---
   CComment       comment;
   CMyBot         bot;
   ENUM_RUN_MODE  run_mode;
   datetime       time_check;
   int            web_error;
   int            init_error;
   string         photo_id=NULL;
   int siz=0;



     int MagicNumber=123;


     double Position_Size() //position sizing
  {
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lots = AccountBalance() / MM_PositionSizing;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }
 double MM_Size() //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
         lots = orderlots * MM_Martingale_LossFactor;
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots = MM_Martingale_Start;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }

   bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     }
   return(lastOrder >= 0);
  }

double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(ticket)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profits && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
            break;
         count++;
        }
     }
   return(count >= n);
  }
 double  GetLotSize(MONEY_MANAGEMENT money)  {



 if(money==RISK_PERCENTAGE){

 return MM_Size(stoploss);
 }
 else if(money==MARTINGALE){


 return MM_Size();



 }
 else if(money ==POSITION_SIZE){



 return Position_Size();



 }


 else if(money ==FIXED_SIZE)return lotSize;
 return 0.01;
 }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void CloseAll()
     {
      int totalOP  = OrdersTotal(), tiket = 0;
      for(int cnt = totalOP - 1 ; cnt >= 0 ; cnt--)
        {
         int Oc = 0, Os = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);
            Sleep(300);
            continue;
           }
         if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
           {
            Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, CLR_NONE);
            Sleep(300);
           }
        }
     }


   //+------------------------------------------------------------------+
   //|             TradeDays                                                     |
   //+------------------------------------------------------------------+
   bool TradeDays()
     {
      if(SET_TRADING_DAYS == no)
         return(true);
      bool ret = false;
      int today = DayOfWeek();
      if(EA_START_DAY < EA_STOP_DAY)
        {
         if(today > EA_START_DAY && today < EA_STOP_DAY)
            return(true);
         else
            if(today == EA_START_DAY)
              {
               if(TimeCurrent() >= datetime(StringToTime(EA_START_TIME)))
                  return(true);
               else
                  return(false);
              }
            else
               if(today == EA_STOP_DAY)
                 {
                  if(TimeCurrent() < datetime(StringToTime(EA_STOP_TIME)))
                     return(true);
                  else
                     return(false);
                 }
        }
      else
         if(EA_STOP_DAY < EA_START_DAY)
           {
            if(today > EA_START_DAY || today < EA_STOP_DAY)
               return(true);
            else
               if(today == EA_START_DAY)
                 {
                  if(TimeCurrent() >= datetime(StringToTime(EA_START_TIME)))
                     return(true);
                  else
                     return(false);
                 }
               else
                  if(today == EA_STOP_DAY)
                    {
                     if(TimeCurrent() < datetime(StringToTime(EA_STOP_TIME)))
                        return(true);
                     else
                        return(false);
                    }
           }
         else
            if(EA_STOP_DAY == EA_START_DAY)
              {
               datetime st = (datetime)StringToTime(EA_START_TIME);
               datetime et = (datetime)StringToTime(EA_STOP_TIME);
               if(et > st)
                 {
                  if(today != EA_STOP_DAY)
                     return(false);
                  else
                     if(TimeCurrent() >= st && TimeCurrent() < et)
                        return(true);
                     else
                        return(false);
                 }
               else
                 {
                  if(today != EA_STOP_DAY)
                     return(true);
                  else
                     if(TimeCurrent() >= et && TimeCurrent() < st)
                        return(false);
                     else
                        return(true);
                 }
              }
      /*int JamH1[] = { 10, 20, 30, 40 }; // A[2] == 30
       //   if (JamH1[Hour()] == Hour()) Alert("Trade");
       if (Hour() >= StartHour1 && Hour() <= EndHour1 && DayOfWeek() == 1 && MondayTrade )  return (true);
       if (Hour() >= StartHour2 && Hour() <= EndHour2 && DayOfWeek() == 2 && TuesdayTrade )  return (true);
       if (Hour() >= StartHour3 && Hour() <= EndHour3 && DayOfWeek() == 3 && WednesdayTrade )  return (true);
       if (Hour() >= StartHour4 && Hour() <= EndHour4 && DayOfWeek() == 4 && ThursdayTrade )  return (true);
       if (Hour() >= StartHour5 && Hour() <= EndHour5 && DayOfWeek() == 5 && FridayTrade && !ExitFriday)  return (true);
       if (StartHour5 <=StartHourX - LastTradeFriday - 1 && Hour() >= StartHour5 && Hour() <= StartHourX - LastTradeFriday - 1 && DayOfWeek() == 5 && FridayTrade && ExitFriday)  return (true);
       if ( DayOfWeek() == 1 && !MondayTrade )  return (true);
       if ( DayOfWeek() == 2 && !TuesdayTrade )  return (true);
       if ( DayOfWeek() == 3 && !WednesdayTrade )  return (true);
       if ( DayOfWeek() == 4 && !ThursdayTrade )  return (true);
       if ( DayOfWeek() == 5 && !FridayTrade && ExitFridayOk() == 0)  return (true);
       */
      return (ret);
     }

   ////////////////////////////////////////////////////////////////////////
   void timelockaction(void)
     {
      if(TradeDays())
         return;
      double stoplevel = 0, proffit = 0, newsl = 0, price = 0;
      double ask = 0, bid = 0;
      string sy = NULL;
      int sy_digits = 0;
      double sy_points = 0;
      bool ans = false;
      bool next = false;
      int otype = -1;
      int kk = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         if(OrderMagicNumber() != MagicNumber)
            continue;
         next = false;
         ans = false;
         sy = OrderSymbol();
         ask = SymbolInfoDouble(sy, SYMBOL_ASK);
         bid = SymbolInfoDouble(sy, SYMBOL_BID);
         sy_digits = (int)SymbolInfoInteger(sy, SYMBOL_DIGITS);
         sy_points = SymbolInfoDouble(sy, SYMBOL_POINT);
         stoplevel = MarketInfo(sy, MODE_STOPLEVEL) * sy_points;
         otype = OrderType();
         kk = 0;
         proffit = OrderProfit() + OrderSwap() + OrderCommission();
         newsl = OrderOpenPrice();
               if(proffit <= 0)
                  break;
               else
                 {
                  price = (otype == OP_BUY) ? bid : ask;
                  while(otype < 2 && kk < 5 && MathAbs(price - newsl) >= stoplevel && !OrderModify(OrderTicket(), newsl, newsl, OrderTakeProfit(), OrderExpiration()))
                    {
                     kk++;
                     price = (otype == OP_BUY) ? SymbolInfoDouble(sy, SYMBOL_BID) : SymbolInfoDouble(sy, SYMBOL_ASK);
                    }
                 }

         continue;
        }
     }

//+------------------------------------------------------------------+
//|                     CHART COLOR SET                                             |
//+------------------------------------------------------------------+
bool ChartColorSet()//set chart colors
  {
   ChartSetInteger(ChartID(), CHART_COLOR_ASK, BearCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_BID, clrOrange);
   ChartSetInteger(ChartID(), CHART_COLOR_VOLUME, clrAqua);
   int keyboard = 12;
   ChartSetInteger(ChartID(), CHART_KEYBOARD_CONTROL, keyboard);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, 231);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BEAR, BearCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BULL, BullCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, Bear_Outline);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_UP, Bull_Outline);
   ChartSetInteger(ChartID(), CHART_SHOW_GRID, 0);
   ChartSetInteger(ChartID(), CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(ChartID(), CHART_MODE, 1);
   ChartSetInteger(ChartID(), CHART_SHIFT, 1);
   ChartSetInteger(ChartID(), CHART_SHOW_ASK_LINE, 1);
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, BackGround);
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, ForeGround);
   return(true);
  }

input color BearCandle = clrWhite;
input color BullCandle = clrGreen;
input color BackGround = clrBlack;
input color ForeGround = clrAquamarine;
input color Bear_Outline = clrRed;
input color Bull_Outline = clrGreen;
input string license_key="trial";
bool CheckLicense(string license){
datetime tim=D'2023.07.01 00:00';
if(license=="trial"){


 int op=FileOpen(license,FILE_WRITE|FILE_CSV);

 if(op<0) {printf("Can't open license key folder");

 return false;
 }
uint write= FileWrite(op,license_key+(string)AccountNumber()+(string)TimeCurrent());

FileClose(op);


Comment("\n\n                                                     Trial Mode");

if(tim>TimeCurrent()){return true;

}else {
MessageBox("Your trial Mode is Over!Please purchase a new license to get access to a full product.You can also contact support at https://t.me/tradeexpert_infos"
,NULL,1);
return false;
}

}else {


return false;

}
return false;
}

   double Lots=GetLotSize( money_management);

   //+------------------------------------------------------------------+
   //|   OnInit                                                         |
   //+------------------------------------------------------------------+
   int OnInit()
   {



   //Verify license

 if ( !CheckLicense(license_key)){
 return false;
 }








        ChartColorSet();





   if(TradeDays()&&SET_TRADING_DAYS==yes){

   MessageBox("TIME REACHED!PLEASE WAIT FOR NEW TRADING SESSION");

   return INIT_FAILED;

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


   extern double BreakEven_Points = 6;
   int LotDigits; //initialized in OnInit

   double MM_Percent = 1;
   int MaxSlippage = 3; //slippage, adjusted in OnInit
   double MaxTP = takeprofit;
   double MinTP = 50;
   extern double CloseAtPL = 50;
   bool crossed[4]; //initialized to true, used in function Cross
   input int MaxOpenTrades = 3;
   input int MaxLongTrades = 3;
   input int MaxShortTrades = 3;
   int MaxPendingOrders = 1000;
   int MaxLongPendingOrders = 1000;
   int MaxShortPendingOrders = 1000;
   input bool Hedging = false;
  input int OrderRetry = 2; //# of retries if sending order returns error
 input  int OrderWait = 3; //# of seconds to wait if sending order returns error
   double myPoint; //initialized in OnInit

   double MM_Size(double SL) //Risk % per trade, SL = relative Stop Loss to calculate risk
     {
      double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
      double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
      double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
      double lots = (MM_Percent/100)*SL/2;
      if(lots > MaxLot) lots = MaxLot;
      if(lots < MinLot) lots = MinLot;
      return(lots);
     }

   double MM_Size_BO() //Risk % per trade for Binary Options
     {
      double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
      double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
      double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
      return(MM_Percent * 1.0 / 100 * AccountBalance());
     }

   void CloseTradesAtPL(double PL) //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
     {
      double totalPL = TotalOpenProfit(0);
      if((PL > 0 && totalPL >= PL) || (PL < 0 && totalPL <= PL))
        {
         myOrderClose(Symbol(),OP_BUY, 100, "");
         myOrderClose(Symbol(),OP_SELL, 100, "");
        }
     }

   bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
     {
      bool ret = condition && !crossed[i];
      crossed[i] = condition;
      return(ret);
     }

   void myAlert(string sym,string type, string message)
     {
      if(type == "print")
         Print(message);
      else if(type == "error")
        {
         Print(type+" | @  "+sym+","+IntegerToString(Period())+" | "+message);
         bot.SendMessage(ChatID,type+" | @  "+sym+","+IntegerToString(Period())+" | "+message);
        }
      else if(type == "order")
        {
        }
      else if(type == "modify")
        {
        }
     }

   int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
     {
      int result = 0;
      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
         if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
         result++;
        }
      return(result);
     }

   double TotalOpenProfit(int direction)
     {
      double result = 0;
      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
        {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
         result += OrderProfit();
        }
      return(result);
     }

   int myOrderSend(string sym,int type, double price, double volume, string ordername ) //send order, return ticket ("price" is irrelevant for market orders)
     {

     long chatId =ChatID;
      if(!IsTradeAllowed()) return(-1);
      int ticket = -1;
      int retries = 0;
      int err = 0;
      int long_trades = TradesCount(OP_BUY);
      int short_trades = TradesCount(OP_SELL);
      int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
      int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
      string ordername_ = ordername;
      if(ordername != "")
         ordername_ = "("+ordername+")";
      //test Hedging
      if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
        {
         myAlert(sym,"print", "Order"+ordername_+" not sent, hedging not allowed");

         bot.SendMessage(ChatID,"Order"+ordername_+ "not sent, hedging not allowed");
         return(-1);
        }
      //test maximum trades
      if((type % 2 == 0 && long_trades >= MaxLongTrades)
      || (type % 2 == 1 && short_trades >= MaxShortTrades)
      || (long_trades + short_trades >= MaxOpenTrades)
      || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
      || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
      || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
      )
        {
         myAlert(sym,"print", "Order"+ordername_+" not sent, maximum reached");
         bot.SendMessage(chatId, "Order"+ordername_+" not sent, maximum reached");
         return(-1);
        }
       double SL=0,TP=0;
      //prepare to send order
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      if(type == OP_BUY || type==OP_BUYLIMIT || type==OP_BUYSTOP)
       {  price = MarketInfo(sym,MODE_ASK);
        SL= price -stoploss*MarketInfo(sym,MODE_POINT);

         TP= price +takeprofit*MarketInfo(sym,MODE_POINT);

        }
      else if(type == OP_SELL || type==OP_SELLLIMIT || type==OP_SELLSTOP)
         {price = MarketInfo(sym,MODE_BID);

         SL= price +stoploss*MarketInfo(sym,MODE_POINT);

         TP= price -takeprofit*MarketInfo(sym,MODE_POINT);


         }
      else if(price < 0) //invalid price for pending order
        {
         myAlert(sym,"order", "Order"+ordername_+" not sent, invalid price for pending order");
         bot.SendMessage(ChatID,"Order"+ordername_+" not sent, invalid price for pending order");
   	  return(-1);
        }
      int clr = (type % 2 == 1) ? clrRed : clrBlue;
      while(ticket < 0 && retries < OrderRetry+1)
        {
         ticket = OrderSend(sym, type,
          NormalizeDouble(volume, LotDigits),
          NormalizeDouble(price,   (int)MarketInfo(sym,MODE_DIGITS))
           ,

          MaxSlippage,
          SL, TP,
           ordername,
           MagicNumber,
            0, clr);
         if(ticket < 0)
           {
            err = GetLastError();
            myAlert(sym,"print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));

           bot.SendMessage(ChatID,"Order"+ordername_+" not sent, invalid price for pending order");

            Sleep(OrderWait*1000);
           }
         retries++;
        }
      if(ticket < 0)
        {
         myAlert(sym,"error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
           bot.SendMessage(ChatID, "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));

         return(-1);
        }
      string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
      myAlert(sym,"order", "Order sent"+ordername_+": "+typestr[type]+" "+sym+" Magic #"+IntegerToString(MagicNumber));
      bot.SendMessage(ChatID,"Order sent"+ordername_+": "+typestr[type]+sym+" "+ (string)MagicNumber+" "+IntegerToString(MagicNumber));
      return(ticket);
     }

   int myOrderModify(string sym,int ticket, double SL, double TP) //modify SL and TP (absolute price), zero targets do not modify
     {
      if(!IsTradeAllowed()) return(-1);
      bool success = false;
      int retries = 0;
      int err = 0;
      SL=stoploss;
      TP=takeprofit;
      SL = NormalizeDouble(SL, (int)MarketInfo(sym,MODE_DIGITS));
      TP =  NormalizeDouble(TP, (int)MarketInfo(sym,MODE_DIGITS));
      if(SL < 0) SL = 0;
      if(TP < 0) TP = 0;
      //prepare to select order
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
        {
         err = GetLastError();
         myAlert(sym,"error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));

        bot.SendMessage(ChatID, "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));


         return(-1);
        }
      //prepare to modify order
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
      if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
      if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
      while(!success && retries < OrderRetry+1)
        {
         success = OrderModify(ticket,
          NormalizeDouble(OrderOpenPrice(),
          (int) MarketInfo(sym,MODE_DIGITS)),
           NormalizeDouble(SL, (int) MarketInfo(sym,MODE_DIGITS)),


          NormalizeDouble(TP, (int) MarketInfo(sym,MODE_DIGITS)), OrderExpiration(), CLR_NONE);
         if(!success)
           {
            err = GetLastError();
            myAlert(sym,"print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));

         bot.SendMessage(ChatID, "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
            Sleep(OrderWait*1000);
           }
         retries++;
        }
      if(!success)
        {
         myAlert(sym,"error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));

       bot.SendMessage(ChatID, "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
         return(-1);
        }
      string alertstr = "Order modified: ticket="+IntegerToString(ticket);
      if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
      if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
      myAlert(sym,"modify", alertstr);

      bot.SendMessage(ChatID,"Modify "+alertstr);
      return(0);
     }

   void myOrderClose(string sym,int type, double volumepercent, string ordername) //close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
     {
      if(!IsTradeAllowed()) return;
      if (type > 1)
        {
         myAlert(sym,"error", "Invalid type in myOrderClose");
         bot.SendMessage(ChatID,"Invalid type in myOrderClose");

         return;
        }
      bool success = false;
      int retries = 0;
      int err = 0;
      string ordername_ = ordername;
      if(ordername != "")
         ordername_ = "("+ordername+")";
      int total = OrdersTotal();
      ulong orderList[][2];
      int orderCount = 0;
      int i;
      for(i = 0; i < total; i++)
        {
         while(IsTradeContextBusy()) Sleep(100);
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
         if(OrderMagicNumber() != MagicNumber || OrderSymbol() != sym || OrderType() != type) continue;
         orderCount++;
         ArrayResize(orderList, orderCount);
         orderList[orderCount - 1][0] = OrderOpenTime();
         orderList[orderCount - 1][1] = OrderTicket();
        }
      if(orderCount > 0)
         ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
      for(i = 0; i < orderCount; i++)
        {
         if(!OrderSelect((int)orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
         while(IsTradeContextBusy()) Sleep(100);
         RefreshRates();
         double price = (type == OP_SELL) ? MarketInfo(sym,MODE_ASK) : MarketInfo(sym,MODE_BID);
         double volume = NormalizeDouble(OrderLots()*volumepercent * 1.0 / 100, LotDigits);
         if (NormalizeDouble(volume, LotDigits) == 0) continue;

         success = false; retries = 0;
         while(!success && retries < OrderRetry+1)
           {
            success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, (int)MarketInfo(sym,MODE_DIGITS)), MaxSlippage, clrWhite);
            if(!success)
              {
               err = GetLastError();
               myAlert(sym,"print", "OrderClose"+ordername_+" failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));

               bot.SendMessage(  ChatID, "OrderClose"+ordername_+" failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));




               Sleep(OrderWait*1000);
              }
            retries++;
           }
         if(!success)
           {


            myAlert(sym,"error", "OrderClose"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));

               bot.SendMessage(ChatID,"OrderClose"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));

               return;
          }
        }
      string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
      if(success) {myAlert(sym,"order", "Orders closed"+ordername_+": "+typestr[type]+" "+sym+" Magic #"+IntegerToString(MagicNumber));

     bot.SendMessage(ChatID,"Orders closed"+ordername_+": "+typestr[type]+" "+sym+" Magic #"+IntegerToString(MagicNumber));
     }}

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
         comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);
         comment.SetText(1,info.text1, LOSS_COLOR);
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
               if (Move_TP_to_Breakeven)timelockaction();
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

               CustomInfo info= {0};
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


   void OnTick(){



   int i=MathRand()%SymbolsTotal(false);
    if(i<SymbolsTotal(false)){
    //false is used to work with all symbols
   string sym=SymbolName(i,false);
   printf("sym :"+sym+(string)i);


   //MOVE TP AND SL

   double TradeSize =0,SL=stoploss,TP=takeprofit,price;
   int ticket=-1;
   for(i=0;i<=OrdersTotal();i++){
   if(OrdersTotal()>0 && OrderSelect(i,SELECT_BY_TICKET,MODE_TRADES) &&OrderType()==OP_BUY&& OrderSymbol()==sym){
    price=MarketInfo(sym,MODE_ASK);


         if(price - TP > MaxTP) TP = price - MaxTP;
         if(price - TP < MinTP) TP = price - MinTP;


          myOrderModify(sym,ticket, SL, 0);
         myOrderModify(sym,ticket, 0, TP);

   }
   if(OrdersTotal()>0 && OrderSelect(i,SELECT_BY_TICKET,MODE_TRADES) &&OrderType()==OP_SELL&&sym==OrderSymbol()){
    price = MarketInfo(sym,MODE_BID);
         if(price - TP < MinTP) TP = price - MinTP;
        //not autotrading => only send alert

         myOrderModify(sym,ticket, SL, 0);
         myOrderModify(sym,ticket, 0, TP);
   }


   }}












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
