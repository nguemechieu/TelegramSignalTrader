//+------------------------------------------------------------------+
//|                                                         Chat.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

 
 
 
#include <Object.mqh>

#include <Arrays/List.mqh>

 
class Cchat  :public CObject
  {
bool m_state;
public: CList  m_chats;
 private:   string last_name;
    string type;
  
  datetime m_time;
    
   bool done; 
   
   string  from_first_name;
    string first_name;string from_last_name; int  from_id;
   

    public: void setFrom_first_name(string from_first_name1){this.from_first_name=from_first_name1;}
    string getFrom_first_name(){return from_first_name;
    }
void setFrom_last_name(string from_last_name1){
this.from_last_name=from_last_name1;
}
 string message_text;
    
string getFrom_last_name(){return from_last_name;}
    
string getLast_name() {
        return last_name;
}


 void setDone(bool done1){
 
 this.done=done1;
 }
 
 
 bool getDone(){return done;}
 void setLast_name(string last_name1) {
        this.last_name = last_name1;
    }
int getFrom_id(){return from_id;}
  

    int getM_state() {
        return m_state;
    }

    void setM_state(int m_state1) {
        this.m_state = m_state1;
    }

     datetime getM_time() {
        return m_time;
    };

    void setM_time(datetime m_time1) {
        this.m_time = m_time1;
    }

    string getFirst_name() {
        return first_name;
    }

    void setFirst_name(string first_name1) {
        this.first_name = first_name1;
    }
                    
   Cchat(){};   ~Cchat();           
  };
  
  
  Cchat::~Cchat(){//default constructor
  
  };
  
  