//+------------------------------------------------------------------+
//|                                                  OfirBlueAPI.mqh |
//|                                      Copyright 2022, Gad Benisty |
//|                                                https://ofir.blue |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Gad Benisty"
#property link      "https://ofir.blue"
#property strict
#property copyright "Copyright 2022, Gad Benisty"
#property link      "https://ofir.blue"
#property version   "1.00"
#property strict


input string BlueToken = "";  //Ofir Blue Token for this account

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCOfirBlueApi
  {
private:
   bool              isTop;
   double            Top;
   bool              isBottom;
   double            Bottom;
   string            m_token;
   string            m_name;

public:
   // Default constructor
                     CCOfirBlueApi(void) {};
   // Parametric constructor
                     CCOfirBlueApi(bool is_top, double top, bool is_bottom, double bottom)
     {
     };
   void              Init(string name="Untitled",string token="")
     {
      m_token=(token=="")?BlueToken:token;
      m_name=name;
      Print("Init name=",m_name," token=",m_token);
     };
   void              SendSignal(int type=-1,string symbol="",double price=0,double sl=0,double tp1=0,double tp2=0,double tp3=0,string message="")
     {
      if(m_token == "")
         return;
      if(type<0 || symbol=="")
        {
         Print("invalid order type or symbol");
         return;
        }
      string cmd=StringFormat("type=%s&symbol=%s&sl=%f&tp=%f&period=%i",strOpType(type),blueSimplify(symbol),sl,tp1,Period());
      if(message!="") cmd+="&message="+message;
      SendCommand("signal",cmd);
      return;
     };
   void              SendMessage(string text)
     {
      if(m_token == "")
         return;
      SendCommand("notify","text="+text);
      return;
     };
   void              SendCommand(string action="notify",string cmd="")
     {
      if(m_token == "")
         return;
      string fileName="OfirBlue\\"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\\inbox\\"+action+blueSimplify(Symbol())+getRef()+".txt";
      cmd="action="+action+"&token="+m_token+"&"+cmd+"&from="+m_name;
      saveStringFile(cmd,fileName);
      return;
     };
   void              SendChart(string text="",color clr=clrPowderBlue,int size=95)
     {
      if(m_token == "")
         return;
      Print("Send chart to Ofir Blue");
      string id="chart"+blueSimplify(Symbol())+getRef();
      string fileName="OfirBlue\\"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\\screens\\"+id+".png";
      int w = (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      int h = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      if(text!="") ShowChartMessage(text,clr,size);
      if(ChartScreenShot(0,fileName,w,h))
        {
         fileName="OfirBlue\\"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\\inbox\\chart"+id+".txt";
         string cmd="action=chart&token="+m_token+"&file="+id+".png";
         saveStringFile(cmd,fileName);
        }
      if(text!="") ObjectDelete("blueChartMessage");
      return;
     };
   void              ShowChartMessage(string text,color clr=clrPowderBlue,int size=110)
     {
     
      int         width=300;       // width,
      int         height=300;        // widtho
      int wBox=650;

//      int x=(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)/2)-width;
//
//      int y=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)/2;
      //x=ChartMiddleX()-(wBox/2);
      //y=ChartMiddleY();
      int x=50;
      int y=100;
      blueLabelCreate(0,"blueChartMessage",0,x,y,CORNER_LEFT_UPPER,text,"Arial Black",size,clr,0,ANCHOR_LEFT,true,false,true,-5);
      //LabelCreate(0,OPRX+"PeriodBack",0,x,(int)(y+SymbolSize+5),CORNER_LEFT_UPPER,strPeriod(Period()),"Arial Black",(int)(SymbolSize/1.6),clrBack,0,ANCHOR_LEFT,true,false,true,-5);
     };
  };
CCOfirBlueApi blue;
//+------------------------------------------------------------------+

bool saveStringFile(string s,string fileName)
  {
   FileDelete(fileName);
   int handle=FileOpen(fileName,FILE_WRITE|FILE_TXT);
   if(handle==INVALID_HANDLE)
      return(false);
   FileWriteString(handle,s);
   FileClose(handle);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getRef()
  {
   static string ref="";
   static int n=0;
   string cref=StringRight("0"+(string)(TimeHour(TimeLocal())),2)+StringRight("0"+(string)(TimeMinute(TimeLocal())),2)+StringRight("0"+(string)(TimeSeconds(TimeLocal())),2);
   if(cref!=ref)
     {
      ref=cref;
      n=0;
     }
   else
     {
      n++;
      cref+=(string)n;
     }
   return(cref);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  StringRight(
   string  s,     // string
   int     l=0          // length of extracted string
)
  {
   return (StringSubstr(s,StringLen(s)-l));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string blueSimplify(string s)
  {
   static bool first=true;
   static string fmt="";
   if(first)
     {
      string sN,f="GBPUSD";
      for(int i=0; i<SymbolsTotal(true); i++)
        {
         sN=SymbolName(i,true);
         if(StringFind(sN,"GBPUSD",0)>-1 &&sN!="GBPUSD")
            f=sN;
        }
      fmt=strRep(f,"GBPUSD","");
      first=false;
     }
   if(fmt=="")
      return(s);
   if(s=="")
      return(Symbol());
   return(strRep(s,fmt,""));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string blueFlag(string s)
  {
//return("f"+s+"."+aOut(s));
   if(s=="")
      return("");
   s=blueSimplify(s);
   if(StringLen(s)!=6)
      return(":"+s+":");
   return ":"+StringSubstr(s,0,3)+": :"+StringSubstr(s,3,3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strRep(string a,string b,string c)
  {
   StringReplace(a,b,c);
   return(a);
  }
//+------------------------------------------------------------------+
string strOpType(int type)
  {
   switch(type)
     {
      case OP_BUY:
         return("Buy");
         break;
      case OP_SELL:
         return("Sell");
         break;
      case OP_BUYLIMIT:
         return("Buy Limit");
         break;
      case OP_SELLLIMIT:
         return("Sell Limit");
         break;
      case OP_BUYSTOP:
         return("Buy Stop");
         break;
      case OP_SELLSTOP:
         return("Sell Stop");
         break;
      default:
         return("-");
         break;
     }
  }
//+------------------------------------------------------------------+
string strPeriod(int period=0)
  {
   if(period==0)
      period=Period();
   if(period==PERIOD_M1)
      return("M1");
   if(period==PERIOD_M5)
      return("M5");
   if(period==PERIOD_M15)
      return("M15");
   if(period==PERIOD_M30)
      return("M30");
   if(period==PERIOD_H1)
      return("H1");
   if(period==PERIOD_H4)
      return("H4");
   if(period==PERIOD_D1)
      return("D1");
   if(period==PERIOD_MN1)
      return("MN1");
   return (IntegerToString(period));
  }
//+------------------------------------------------------------------+
bool blueLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0,                // priority for mouse click
                 const string            tooltip="\n",             // tooltip for mouse hover
                 const bool              tester=true)              // create object in the strategy tester
  {
//--- reset the error value
   int subWindow=sub_window;
   if(IsTesting() && WindowExpertName() == "Ofir")
      subWindow=1;
//Print("LabelCreate ",name," ",x," ",y);
   if(sub_window==-1)
      subWindow=0;
   ResetLastError();
//--- CheckTester
   if(!tester && MQLInfoInteger(MQL_TESTER))
      return(false);
//---
   ObjectDelete(chart_ID,name);
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,subWindow,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create text label! Error code = ",_LastError);
         return(false);
        }
      //--- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,clrGray);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,2);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//---
   return(true);
  }