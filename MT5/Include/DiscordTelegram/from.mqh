//+------------------------------------------------------------------+
//|                                                         from.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
class Cfrom
  {
public:
int id;
bool is_bot;

string first_name;

string last_name;

string username;
string language_code;


    public :int getId() {
        return id;
    }

  void setId(int id1) {
        this.id = id1;
    }

    public :bool getIs_bot() {
        return is_bot;
    }

    public :void setIs_bot(bool is_bot1) {
        this.is_bot = is_bot1;
    }

    public :string getFirst_name() {
        return first_name;
    }

    public :void setFirst_name(string first_name1) {
        this.first_name = first_name1;
    }

    public :string getLast_name() {
        return last_name;
    }

    public :void setLast_name(string last_name1) {
        this.last_name = last_name1;
    }

    public: string getUsername() {
        return username;
    }

    public: void setUsername(string username1) {
        this.username = username1;
    }

    public: string getLanguage_code() {
        return language_code;
    }

    public :void setLanguage_code(string language_code1) {
        this.language_code = language_code1;
    }
    
    
       public :Cfrom(int id1, bool is_bot1, string first_name1, string last_name1, string username1, string language_code1) {
        this.id = id1;
        this.is_bot = is_bot1;
        this.first_name = first_name1;
        this.last_name = last_name1;
        this.username = username1;
        this.language_code = language_code1;
    }

    
    
    
    
    
    
    
    
       
       
                     Cfrom();
                    ~Cfrom();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Cfrom::Cfrom()
  {
  id=0;
 is_bot=false;

 first_name="ali";

 last_name="bernard";

username="tapi";
language_code="en";

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Cfrom::~Cfrom()
  {
  }
//+------------------------------------------------------------------+
