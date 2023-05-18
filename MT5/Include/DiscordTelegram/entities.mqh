//+------------------------------------------------------------------+
//|                                                     entities.mqh |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class Centities 
  {
 private:

    public :Centities(long offset1, long length1, string type1) {
        this.offset = offset1;
        this.length = length1;
        this.type = type1;
    }

    public :long getOffset() {
        return offset;
    }

    public: void setOffset(long offset1) {
        this.offset = offset1;
    }

    public: long getLength() {
        return length;
    }

    public :void setLength(long length1) {
        this.length = length1;
    }

    public :string getType() {
        return type;
    }

    public: void setType(string type1) {
        this.type = type1;
    }

    long offset;
    long length;
    string type;



    Centities();
                    ~Centities();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Centities::Centities()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Centities::~Centities()
  {
  }
//+------------------------------------------------------------------+
