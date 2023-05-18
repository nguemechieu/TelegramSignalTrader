//+------------------------------------------------------------------+
//|                                                       Circle.mqh |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
#include <DiscordTelegram/Object.mqh>
class CCircle : public CObject
  {
  
    double perimeter;
    double arc;
    double diameter;
    double radius;
    double angle;
     double  pi;

   public :double getDiameter() {
        return diameter;
    }

   void setDiameter() {
        this.diameter = 2*radius;
    }

    double getRadius() {
        return radius;
    }

    void setRadius(double radius1) {
        this.radius = radius1;
    }

    double getAngle() {
        return angle;
    }

   void setAngle(double angle1) {
        this.angle = angle1;
    }

   double getPi() {
        return pi;
    }

     void setPi() {
        this.pi = 3.14159;
    }

    public: double getPerimeter() {
        return perimeter;
    }

    public: void setPerimeter() {
        this.perimeter = 2*radius;
    }

    public :double getArc() {
        return arc;
    }

    public :void setArc(double arc1) {
        this.arc = arc1;
    }
  public: CCircle(double radius1) {
        this.radius = radius1;
    }

    
    public:CCircle(double diameter1, double radius1, double angle1, double pi1, double perimeter1, double arc1) {
    
        this.diameter = diameter1;
        this.radius = radius1;
        this.angle = angle1;
        this.pi = pi1;
        this.perimeter = perimeter1;
        this.arc = arc1;
    }

  
    

                  
                    ~CCircle();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCircle::~CCircle()
  {
  }
//+------------------------------------------------------------------+
