         //+------------------------------------------------------------------+
         //|                                                    BinanceUs.mqh |
         //|                                 Copyright 2022, tradeexperts.org |
         //|                       https://github.com/nguemechieu/TradeExpert |
         //+------------------------------------------------------------------+
         #property copyright "Copyright 2022, tradeexperts.org"
         #property link      "https://github.com/nguemechieu/TradeExpert"
         #property version   "1.00"
         #property strict
         #include <Arrays/List.mqh>
         
         #include <jason.mqh>
       enum TRADING_STATUS
       {PRE_TRADING,
   TRADING,
   POST_TRADING,
   END_OF_DAY,
   HALT,
   AUCTION_MATCH,
   BREAK,
   };
   enum SYMBOL_TYPE
      {
         LEVERAGE,
         SPOT
         ,DERIVATIVE
         };
         
         enum ORDER_STATUS{
       ACCEPTED,
   PARTIALLY_FILLED	,
   FILLED	,
   CANCELED	,
   PENDING_CANCEL,
   REJECTED,
   EXPIRED
         };
         
         #define apiBinUS "https://api.binance.us/"
         class CBinanceUs : public CList
           {
         private:
         string  api_key;
          string api;
          string  username;
          string password;
          string token;
          string coin;
          string symbol;
          string balance;
          
             string  recvWindow;
          long timestamp;
          
         double price;
         string side;
         int type;
         
          int quantity;
             string  timeInForce	;
             char data[];
             char resultx[];
             string header;
          
            string SendRequest(string method="GET",string paramsx="",string urlx=""){
            
            int res =WebRequest(method,urlx,"",paramsx,5000,data,0,resultx,header);
            
            if(res==200){
              return CharArrayToString(resultx,0,WHOLE_ARRAY);     
            }
            
            
             printf( CharArrayToString(resultx,0,WHOLE_ARRAY));
          
            return  CharArrayToString(resultx,0,WHOLE_ARRAY);    
          
          
          
           }
      
       
      
                            
            public :double getPrice() {
              return price;
          }
      
          public :void setPrice(double xprice) {
              this.price = xprice;
          }
      
       public:   string getSide() {
              return side;
          }
      
          public :void setSide(string xside) {
              this.side = xside;
          }
      
          public :int getType() {
              return type;
          }
      
          public :void setType(int xtype) {
              this.type = xtype;
          }
      
          public :string getTimeInForce() {
              return timeInForce;
          }
      
          public :void setTimeInForce(string xtimeInForce) {
              this.timeInForce = xtimeInForce;
          }
      
          public: int getQuantity() {
              return quantity;
          }
      
          public :void setQuantity(int xquantity) {
              this.quantity = xquantity;
          }
      
          public :string getRecvWindow() {
              return recvWindow;
          }
      
          public :void setRecvWindow(string xrecvWindow) {
              this.recvWindow = xrecvWindow;
          }
      
          public :long getTimestamp() {
              return timestamp;
          }
      
          public :void setTimestamp(long xtimestamp) {
              this.timestamp = xtimestamp;
          }
      
      
      
              
          bool deposit(double amount){return false;};
         bool    withdraw(double amount){
              return false;
           }
                  
                   
       void wallet(double amounts){// operate wallet actions
                
                
                if(deposit(amounts)){
                printf("DEPOSIT SUCCESS!");
                }else   { printf("DEPOSIT FAILED!");}
                if(withdraw(amounts)){
                printf("WHITDRAWAL SUCCESS!");
                }else   { printf("WHITDRAWAL FAILED!");
                
                } 
                
                
                
         }       
      
      
      ////////////////// GET NETWORK CONNECTIVITIES ///////////////////////
      //------Use this endpoint to test connectivity to the exchange.
      //curl 'https://api.binance.us/api/v3/ping'
      
     string GetNetworkConnectivity(){
      
      const string urlNetwork="https://api.binance.us/api/v3/ping";
      
      string messageNetwork="POOR NETWORK CONNECTIVITY";
      
            string requestResponses="";
        
        
      
       string method="GET";string paramsx="";string urlx="";
            
        int res =WebRequest(method,urlx,"",paramsx,5000,data,0,resultx,header);
            
            
          requestResponses= CharArrayToString(resultx,0,WHOLE_ARRAY);     
            
            
            
         printf( CharArrayToString(resultx,0,WHOLE_ARRAY));
          
      
            
        CJAVal js(NULL,requestResponses),item;
        js.Deserialize(resultx);
        
        
        
        
    string ghd="{}";
        string anss;
        for(int jk=0;jk<ArraySize(js.m_e);jk++){
        
        item=js.m_e[jk];
      
                    anss=item["Parameters"].ToStr();
                 anss=item[""].ToStr();
                    
       }
           Alert("connectivity  " +    anss);
        if(anss==ghd){ Alert("server GOOD CONNECTION"); Comment("Message:       GOOD CONNECTION");
        
         return messageNetwork;
       }
        
        return messageNetwork;
      }
      
      
      
      
        string GetServerTime(){
      
      const string urlNetworkh="https://api.binance.us/api/v3/time";
        string requestResponses="";
        
        
      string messageNetwork="SERVER TIME ERROR!";
      
       string method="GET";string paramsx="";string urlx="";
            
        int res =WebRequest(method,urlx,"",paramsx,5000,data,0,resultx,header);
            
            
          requestResponses= CharArrayToString(resultx,0,WHOLE_ARRAY);     
            
            
            
         printf( CharArrayToString(resultx,0,WHOLE_ARRAY));
          
         
        CJAVal js(NULL,requestResponses),item;
        
        js.Deserialize(resultx,0);
        long ans;
        for(int jk=0;jk<ArraySize(js.m_e);jk++){
        
       item=js.m_e[jk];
       
           ans=(datetime)item["serverTime"].ToStr();
            
        }
      return ans;
        
      }
      
      
       
      
      
      
      
      
      
      
      
      
      
      
      
      
      
                
         
      double GetLivePrice(string xsymbol){//return live Market  prices
       
      string apiBinance="https://api.binance.us/api/v3/trades?symbol="+xsymbol;
      
       string outx;
       outx= SendRequest("GET","",apiBinance);
        CJAVal js(NULL,outx),item;
        
        js.Deserialize(resultx);
        
        for(int jk=0;jk<ArraySize(js.m_e);jk++){
        
        item=js.m_e[jk];
        string symbolf=item["symbol"].ToStr();
        price=item["price"].ToDbl();
        if(symbol==symbolf)return price;
        }
         return price;
       
        }
                 
        bool OrderMarketOrder(){//open market order
              
              
                return false;
              
              }    
                   
                   
       bool OrderCloses(){
              
              
              
              
              
              
              
              
              return false;
              
              }    
                     
                   
       bool OrderClosePrices(){
              
              
              
              
              
              
              
              
              return false;
              
              }    
                 
                   
                   
                   
      bool OrderOpenPrices(){
              
              
              
              
              
              
              
              
              return false;
              
              }    
                 
                   
       bool OpenPendingOrder(){
              
              
              
              
              
              
              
              
              return false;
              
              }    
                 
                   
      bool OpenLimitOrder(){
              
              
              
              
              
              
              
              
              return false;
              
              }    
             bool OpenStopOrder(){
            
              return false;
              
              }    
                  
                        
                   
                   
                   
            
      
          public :string getApi_key() {
              return api_key;
          }
      
          void setApi_key(string xapi_key) {
              this.api_key = xapi_key;
          }
      
          public: string getApi() {
              return api;
          }
      
               void setApi(string apix) {
              this.api = apix;
          }
      
           string getUsername() {
              return username;
          }
      
           void setUsername(string usernamec) {
              this.username = usernamec;
          }
      
          public: string getPassword() {
              return password;
          }
      
          public: void setPassword(string passwordc) {
              this.password = passwordc;
          }
      
          public :string getToken() {
              return token;
          }
      
          public :void setToken(string tokenc) {
              this.token = tokenc;
          }
      
          public :string getCoin() {
              return coin;
          }
      
          public :void setCoin(string coinx) {
              this.coin = coinx;
          }
      
          public :string getSymbol() {
              return symbol;
          }
      
          public :void setSymbol(string symbolx) {
              this.symbol = symbolx;
          }
      
          public :string getBalance() {
              return balance;
          }
      
          public :void setBalance(string balancex) {
              this.balance = balancex;
          }
      
             
                   
                   
                   
                   
               CBinanceUs();
                             ~CBinanceUs();      
                   
                   
                   
                             
                             
           };
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         CBinanceUs::CBinanceUs()
           {
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         CBinanceUs::~CBinanceUs()
           {
           }
         //+------------------------------------------------------------------+
