
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



 

#include <DiscordTelegram/Chat.mqh>

class CCustomChat :public Cchat
{
public:
   int             m_id;
   Cchat   m_last;
  Cchat  m_new_one;

   int               m_state;
   datetime          m_time;

   string from_first_name;
    int getM_state() {
        return m_state;
    }

     void setM_state(int m_state1) {
        this.m_state = m_state1;
    }

     datetime getM_time() {
        return m_time;
    }

    void setM_time(datetime m_time1) {
        this.m_time = m_time1;
    }




    int getM_id() {
        return m_id;
    }

   

    void setM_id(int m_id1) {
        this.m_id = m_id1;
    }
  
void setFrom_first_name(string from_first_name1){this .from_first_name=from_first_name1;}
string getFrom_first_name(){return from_first_name;};
   
   



   CCustomChat(){};
   
   ~CCustomChat();
};
   
 
 
 
 
 CCustomChat::~CCustomChat(){};
 
 