
   #define CAPTION_COLOR   clrYellow
   #define LOSS_COLOR      clrOrangeRed
   #include <stdlib.mqh>
   #include <stderror.mqh>
   #include <DiscordTelegram\Comment.mqh>
   #include <DiscordTelegram\Telegram.mqh>
   
   const ENUM_TIMEFRAMES _periods[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
input ENUM_LANGUAGES InpLanguage;

string symbols[];


  
   enum EXECUTION_MODE{MARKET_ORDERS,LIMIT_ORDERS,STOPLOSS_ORDERS};
     

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
         void myAlert(string sym,string type, string message)
     {
      if(type == "print")
         Print(message);
      else if(type == "error")
        {
         Print(type+" | @  "+sym+","+IntegerToString(Period())+" | "+message);
         SendMessage(channel,type+" | @  "+sym+","+IntegerToString(Period())+" | "+message);
        }
      else if(type == "order")
        {
        }
      else if(type == "modify")
        {
        }
     }
   
   int myOrderSend(string sym,int type, double price, double volume, string ordername ) //send order, return ticket ("price" is irrelevant for market orders)
     {
     
     string chatId =channel;
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
         
         SendMessage(channel,"Order"+ordername_+ "not sent, hedging not allowed");
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
        SendMessage(chatId, "Order"+ordername_+" not sent, maximum reached");
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
         {price =  price = MarketInfo(sym,MODE_BID);
         
         SL= price +stoploss*MarketInfo(sym,MODE_POINT);
            
         TP= price -takeprofit*MarketInfo(sym,MODE_POINT);
         
         
         }
      else if(price < 0) //invalid price for pending order
        {
        // myAlert(sym,"order", "Order"+ordername_+" not sent, invalid price for pending order");
         SendMessage(channel,"Order"+ordername_+" not sent, invalid price for pending order");
   	  return(-1);
        }
      int clr = (type % 2 == 1) ? clrWhite : clrGold;
      while(ticket < 0 && retries < OrderRetry+1)
        {
        LotDigits=(int)MarketInfo(sym,MODE_LOTSIZE);
        
         ticket = OrderSend(sym, type,
          NormalizeDouble(volume, LotDigits),
          NormalizeDouble(price,  (int)MarketInfo(sym,MODE_DIGITS))
           ,
           
          0, 
          SL, TP,
           ordername, 
           2234,
            0, clr);
         if(ticket < 0)
           {
            err = GetLastError();
            myAlert(sym,"print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
                Sleep(OrderWait*1000);
           }
           
       
       if(ticket < 0)
        {
           myAlert(sym,"error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
           SendMessage(channel, "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
   
         return(-1);
        }
      string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
    
          myAlert(sym,"order", "Order sent"+ordername_+": "+typestr[type]+" "+sym+" Magic #"+IntegerToString(MagicNumber));
         SendMessage(channel,"Order sent"+ordername_+": "+typestr[type]+sym+" "+ (string)MagicNumber+" "+IntegerToString(MagicNumber));

         retries++;
        }
        return ticket;
     
   }
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
            
            SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);
   
            //--- waitng 30 sec for save screenshot
            wait=60;
            while(!FileIsExist(filename) && --wait>0)
               Sleep(500);
   
            //---
            if(FileIsExist(filename))
            {
               string screen_id;
               result=SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
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
   #define  TRADE_SYMBOLS "[[\""+EMOJI_TOP+"\",\"BUY\",\"SELL\",\"BUYLIMIT\"],[\""+EMOJI_BACK+"\",\"SELLLIMIT\",\"BUYSTOP\",\"SELLSTOP\"]]"
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
   

  