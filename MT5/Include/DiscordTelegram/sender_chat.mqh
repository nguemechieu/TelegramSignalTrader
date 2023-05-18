//+------------------------------------------------------------------+
//|                                                  sender_chat.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class Csender_chat  
  
  {
  private:int  id;//sender_chat  id
    string title;//sender_chat title
    string type;//sender_chat  type
    string username;//sender_chat user_na
    

    public:int  getId() {
        return id;
    }

     void setId(int  id1) {
        this.id = id1;
    }

     string getTitle() {
        return title;
    }

     void setTitle(string title1) {
        this.title = title1;
    }

    public: string getType() {
        return type;
    }

    void setType(string type1) {
        this.type = type1;
    }

    string getUsername() {
        return username;}
    void setUsername(string username1) {
        this.username = username1;
    }

 

    
    public :string toString() {
        return "Csender_chat " +
                "id=" + (string)id +
                ", title=' " + title  +
                ", type= '" + (string)type + 
                ", username='" + username  
                ;
    }


              Csender_chat();~Csender_chat();
  };
  

Csender_chat::~Csender_chat(){



}
Csender_chat::Csender_chat(){};