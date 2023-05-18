//+------------------------------------------------------------------+
//|                                                     Coinbase.mqh |
//|                                 Copyright 2022, tradeexperts.org |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, tradeexperts.org"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict

#include <Arrays/List.mqh>

#define coinbaseApiUrl "https://api.coinbase.com/v2/"
#define  urlSpotPrice "prices/"
   //GET SPOT PRICE        :prices/BTC-USD/spot"

class
Transactions{
Transactions();~Transactions();
};
Transactions::Transactions(){};
Transactions::~Transactions(){};

class Users{

private:
    int id;
    string name,username,profile_location,profile_bio,profile_url,avatar_url,resource,resource_path;
    
    
    
      string email,
    time_zone,native_currency,bitcoin_unit,country_code,country_name,created_at;

    public :string getEmail() {
        return email;
    }

    public :void setEmail(string email) {
        this.email = email;
    }

    public: string getTime_zone() {
        return time_zone;
    }

    public: void setTime_zone(string time_zone) {
        this.time_zone = time_zone;
    }

    public :string getNative_currency() {
        return native_currency;
    }

    public :void setNative_currency(string native_currency) {
        this.native_currency = native_currency;
    }

    public: string getBitcoin_unit() {
        return bitcoin_unit;
    }

    public :void setBitcoin_unit(string bitcoin_unit) {
        this.bitcoin_unit = bitcoin_unit;
    }

    public: string getCountry_code() {
        return country_code;
    }

    public: void setCountry_code(string country_code) {
        this.country_code = country_code;
    }

    public: string getCountry_name() {
        return country_name;
    }

    public :void setCountry_name(string country_name) {
        this.country_name = country_name;
    }

    public :string getCreated_at() {
        return created_at;
    }

    public: void setCreated_at(string created_at) {
        this.created_at = created_at;
    }

    public: string toString() {
        return "Users{" +
                "email=" + email +
                ", time_zone=" + time_zone +
                ", native_currency=" + native_currency +
                ", bitcoin_unit=" + bitcoin_unit +
                ", country_code=" + country_code +
                ", country_name=" + country_name +
                ", created_at=" + created_at +
                '}';
    }

  public :int getId() {
        return id;
    }

    public :void setId(int id) {
        this.id = id;
    }

    public :string getName() {
        return name;
    }

    public :void setName(string name) {
        this.name = name;
    }

    public: string getUsername() {
        return username;
    }

    public :void setUsername(string username) {
        this.username = username;
    }

    public :string getProfile_location() {
        return profile_location;
    }

    public :void setProfile_location(string profile_location) {
        this.profile_location = profile_location;
    }

    public :string getProfile_bio() {
        return profile_bio;
    }

    public :void setProfile_bio(string profile_bio) {
        this.profile_bio = profile_bio;
    }

    public: string getProfile_url() {
        return profile_url;
    }

    public: void setProfile_url(string profile_url) {
        this.profile_url = profile_url;
    }

    public :string getAvatar_url() {
        return avatar_url;
    }

    public :void setAvatar_url(string avatar_url) {
        this.avatar_url = avatar_url;
    }

    public: string getResource() {
        return resource;
    }

    public :void setResource(string resource) {
        this.resource = resource;
    }

    public: string getResource_path() {
        return resource_path;
    }

    public :void setResource_path(string resource_path) {
        this.resource_path = resource_path;
    }


    public: string toStrings() {
        return "Users{" +
                "id=" + id +
                ", name=" + name +
                ", username=" + username +
                ", profile_location=" + profile_location +
                ", profile_bio=" + profile_bio +
                ", profile_url=" + profile_url +
                ", avatar_url=" + avatar_url +
                ", resource=" + resource +
                ", resource_path=" + resource_path +
                '}';
    }


Users();~Users();


};
Users::Users(){};
class Account {


private:
 int   id;
    string name;
    string primary;
    
    int type;
    string currency;
    double balance;
    double amount;
    string created_at;
    string updated_at;
    string resource;
    string esource_path;

   public :int getId() {
        return id;
    }

    public :void setId(int id) {
        this.id = id;
    }

    public :string getName() {
        return name;
    }

    public :void setName(string name) {
        this.name = name;
    }

    public :string getPrimary() {
        return primary;
    }

    public :void setPrimary(string primary) {
        this.primary = primary;
    }

    public :int getType() {
        return type;
    }

    public :void setType(int type) {
        this.type = type;
    }

    public :string getCurrency() {
        return currency;
    }

    public :void setCurrency(string currency) {
        this.currency = currency;
    }

    public :double getBalance() {
        return balance;
    }

    public: void setBalance(double balance) {
        this.balance = balance;
    }

    public :double getAmount() {
        return amount;
    }

    public :void setAmount(double amount) {
        this.amount = amount;
    }

    public :string getCreated_at() {
        return created_at;
    }

    public :void setCreated_at(string created_at) {
        this.created_at = created_at;
    }

    public :string getUpdated_at() {
        return updated_at;
    }

    public: void setUpdated_at(string updated_at) {
        this.updated_at = updated_at;
    }

    public :string getResource() {
        return resource;
    }

    public :void setResource(string resource) {
        this.resource = resource;
    }

    public :string getEsource_path() {
        return esource_path;
    }

    public :void setEsource_path(string esource_path) {
        this.esource_path = esource_path;
    }



Account();~Account();




}
;

Account::Account(){};
Account::~Account(){};


class Deposit{

long id;
string status;
string payment_method_id,
payment_method_resource,payment_method_resource_path;
long transaction;
string transaction_resource,transaction_resource_path;
double amount;

string amount_currency;
double subtotal;
string subtotal_currency;
string created_at,updated_at,resource,resource_path,committed;
double fee;
string fee_currency;
datetime payout_at;

    public: long getId() {
        return id;
    }


    public :string toString() {
        return "CBinance{" +
                "id=" + id +
                ", status=" + status +
                ", payment_method_id=" + payment_method_id +
                ", transaction=" + transaction +
                ", transaction=" + transaction +
                ", amount=" + amount +
                ", amount=" + amount +
                ", subtotal=" + subtotal +
                ", subtotal=" + subtotal +
                ", created_at=" + created_at +
                ", updated_at=" + updated_at +
                ", resource=" + resource +
                ", resource_path=" + resource_path +
                ", committed=" + committed +
                ", fee=" + fee +
                ", fee=" + fee +
                ", payout_at=" + payout_at +
                '}';
    }

    public :void setId(long id) {
        this.id = id;
    }

    public :string getStatus() {
        return status;
    }

    public: void setStatus(string status) {
        this.status = status;
    }

    public :string getPayment_method_id() {
        return payment_method_id;
    }

    public :void setPayment_method_id(string payment_method_id) {
        this.payment_method_id = payment_method_id;
    }

    public: long getTransaction() {
        return transaction;
    }

    public: void setTransaction(string transaction) {
        this.transaction = transaction;
    }

    public :double getAmount() {
        return amount;
    }

    public :void setAmount(string amount) {
        this.amount = amount;
    }

    public: double getSubtotal() {
        return subtotal;
    }

    public :void setSubtotal(string subtotal) {
        this.subtotal = subtotal;
    }

    public :string getCreated_at() {
        return created_at;
    }

    public: void setCreated_at(string created_at) {
        this.created_at = created_at;
    }

    public :string getUpdated_at() {
        return updated_at;
    }

    public: void setUpdated_at(string updated_at) {
        this.updated_at = updated_at;
    }

    public :string getResource() {
        return resource;
    }

    public :void setResource(string resource) {
        this.resource = resource;
    }

    public: string getResource_path() {
        return resource_path;
    }

    public :void setResource_path(string resource_path) {
        this.resource_path = resource_path;
    }

    public :string getCommitted() {
        return committed;
    }

    public :void setCommitted(string committed) {
        this.committed = committed;
    }

    public: double getFee() {
        return fee;
    }

    public :void setFee(string fee) {
        this.fee = fee;
    }

    public: datetime getPayout_at() {
        return payout_at;
    }

    public: void setPayout_at(datetime payout_at) {
        this.payout_at = payout_at;
    }

    public: void setFee(double fee) {
        this.fee = fee;
    }

    public: void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public :void setAmount(double amount) {
        this.amount = amount;
    }

    public :void setTransaction(long transaction) {
        this.transaction = transaction;
    }


Deposit();~Deposit();


};

Deposit::Deposit(){};

Deposit::~Deposit(){};

class Address {
private:
  int  id;
    string address,name,created_at,updated_at,network,resource,resource_path;


    public :int getId() {
        return id;
    }

    public: void setId(int id) {
        this.id = id;
    }

    public :string getAddress() {
        return address;
    }

    public :void setAddress(string address) {
        this.address = address;
    }

    public :string getName() {
        return name;
    }

    public: void setName(string name) {
        this.name = name;
    }

    public :string getCreated_at() {
        return created_at;
    }

    public :void setCreated_at(string created_at) {
        this.created_at = created_at;
    }

    public :string getUpdated_at() {
        return updated_at;
    }

    public :void setUpdated_at(string updated_at) {
        this.updated_at = updated_at;
    }

    public :string getNetwork() {
        return network;
    }

    public :void setNetwork(string network) {
        this.network = network;
    }

    public :string getResource() {
        return resource;
    }

    public :void setResource(string resourcex) {
        this.resource = resourcex;
    }

    public :string getResource_path() {
        return resource_path;
    }

    public :void setResource_path(string resource_pathx) {
        this.resource_path = resource_pathx;
    }










Address();~Address();
};
Address::Address(){};
Address::~Address(){};

class CCoinbase : public CList
  {



private:
int price;
string currency;



public :string SendRequest(string method="GET",string paramsx="",string urlx=""){
      char resultx[],data[];
      string header;
      int res =WebRequest(method,urlx,"",paramsx,5000,data,0,resultx,header);
      
      if(res==200){
      printf( CharArrayToString(resultx,0,WHOLE_ARRAY));
       return CharArrayToString(resultx,0,WHOLE_ARRAY);     
      }else {
      
      
       if(res==-1)
         {
            return((string)_LastError);return((string)_LastError);
         }
         else
         {
            //--- HTTP errors
            if(res>=100 && res<=511)
            {
               string out2=CharArrayToString(resultx,0,WHOLE_ARRAY);
               Print(out2);
              return  (string )("ERR_HTTP_ERROR_FIRST "+(string)res);
            }
            return (string ) res;
         }
      
      return (string )res;
      } return (string ) res;
     }

 
string GetServerDetails(){
 string data=9;

return data;



}
//var buyPriceThreshold  = 200;
//var sellPriceThreshold = 500;
//
//client.getAccount('primary', function(err, account) {
//
//  client.getSellPrice({'currency': 'USD'}, function(err, sellPrice) {
//    if (parseFloat(sellPrice['amount']) <= sellPriceThreshold) {
//      account.sell({'amount': '1',
//                    'currency': 'BTC'}, function(err, sell) {
//        console.log(sell);
//      });
//    }
//  });
//
//  client.getBuyPrice({'currency': 'USD'}, function(err, buyPrice) {
//    if (parseFloat(buyPrice['amount']) <= buyPriceThreshold) {
//      account.buy({'amount': '1',
//                   'currency': 'BTC'}, function(err, buy) {
//        console.log(buy);
//      });
//    }
//  });
//
//});
 
 
 double GetLivepotPrice(string symbolx){
 

string outx;
 outx= SendRequest("GET","","https://api.coinbase.com/v2/prices/"+symbolx);
  CJAVal js(NULL,outx),items;
  printf(outx);
  js.Deserialize(outx);
  
  for(int jk=0;jk<ArraySize(js.m_e);jk++){
  
  items=js.m_e[jk];
  
    price= items["amount"].ToDbl();
    currency=items["currency"].ToStr();
    string symbolf=items["base"].ToStr()+currency;
      Comment(symbolf+ currency+"  "+price); 
   
      
 printf(symbolf+"  "+ currency+"  "+price); 
   
  if(symbolx==symbolf)return price;
  

   }
   return price;
   
   }
   

CCoinbase(){};~CCoinbase(){};
};