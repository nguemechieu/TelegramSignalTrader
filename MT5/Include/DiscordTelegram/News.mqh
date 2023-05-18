//+------------------------------------------------------------------+
//|                                                         News.mqh |
//|                         Copyright 2021, Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
class CNews
  {private:
    string title;//": "Monetary Base y/y",
    string  country;//": "JPY",
    string  date;//": "2022-04-03T19:50:00-04:00",
    string  impact;//": "Low",

    double forecast;//": "8.0%",
    double  previous;//": "7.6%"
    string sourceUrl;//SOURCE URL
    int minutes;//minutes;
    int hours;//hours;
    int secondes;   //secondes

public:  string getTitle() {
        return title;
    }

   
    string toString() {
        return  StringFormat( "\n----->>  News  <<----\n"+
        
        
        "Date :%s \n Title:%s\nCountry: %s\nImpact: %s\nForecast %2.4f \nPrevious :%2.4f\nSourceUrl :%s",(string)date,title,country,impact,forecast,previous,sourceUrl)+
        
                
                "\n============================\nMinutes :" +(string) minutes +"\n"+
                ", Hours=" + (string)hours +"\n"+
                ", Secondes :" + (string)secondes +
                "\n"
                ;
    }

   void setTitle(string title1) {
        this.title = title1;
    }

     string getCountry() {
        return country;
    }

     void setCountry(string country1) {
        this.country = country1;
    }

   string getDate() {
        return date;
    }

   void setDate(string date1) {
        this.date = date1;
    }

    string getImpact() {
        return impact;
    }

    void setImpact(string impact1) {
        this.impact = impact1;
    }

    double getForecast() {
        return forecast;
    }

   void setForecast(double forecast1) {
        this.forecast = forecast1;
    }

  double getPrevious() {
        return previous;
    }

 void setPrevious(double previous1) {
        this.previous = previous1;
    }

    string getSourceUrl() {
        return sourceUrl;
    }

     void setSourceUrl(string sourceUrl1) {
        this.sourceUrl = sourceUrl1;
    }

  int getMinutes() {
        return minutes;
    }

    void setMinutes(int minutes1) {
        this.minutes = minutes1;
    }

     int getHours() {
        return hours;
    }

   void setHours(int hours1) {
        this.hours = hours1;
    }

  int getSecondes() {
        return secondes;
    }

    void setSecondes(int secondes1) {
        this.secondes = secondes1;
    }

    public :CNews(string title1, string country1, string date1, string impact1, double forecast1,
                 double previous1, string sourceUrl1, int minutes1, int hours1, int secondes1) {
        this.title = title1;
        this.country = country1;
        this.date = date1;
        this.impact = impact1;
        this.forecast = forecast1;
        this.previous = previous1;
        this.sourceUrl = sourceUrl1;
        this.minutes = minutes1;
        this.hours = hours1;
        this.secondes = secondes1;
    }

                  CNews();
                    ~CNews();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNews::CNews()
  {
  
  minutes=0;
  hours=0;
  secondes=0;
  title=NULL;
    country= NULL;
    date= NULL;
    impact= NULL;
    forecast= 0;
    previous=0;
    sourceUrl=NULL;
  }
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNews::~CNews()
  {
  }
//+------------------------------------------------------------------+
