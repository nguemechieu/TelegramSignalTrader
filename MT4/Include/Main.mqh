//+------------------------------------------------------------------+
//|                                                         Main.mqh |
//|                                         Copyright 2019, Decanium |
//|                           https://www.mql5.com/en/users/decanium |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Decanium"
#property link      "https://www.mql5.com/en/users/decanium"
#property version   "1.00"

//--- Include MySQL transaction class
#include  <MySQL\MySQLTransaction.mqh>
#include "Program.mqh"

//+------------------------------------------------------------------+
//| Application class                                                |
//+------------------------------------------------------------------+
class CMain : public CProgram
  {
private:
   //--- MySQL transaction class
   CMySQLTransaction *mysqlt;
   //--- MySQL transaction parameters
   string            m_mysql_server;
   uint              m_mysql_port;
   string            m_mysql_login;
   string            m_mysql_password;
   string            m_mysql_db;
   string            m_mysql_table;
   //--- Request duration in milliseconds
   ulong             m_duration;
   //--- GUI calls
   virtual void      OnChangeCurrency(void);
   virtual void      OnChangeBroker(void);
   virtual void      OnChangeAuthor(void);
   virtual void      OnChangeSignalId(void);
   virtual void      OnChangeEquity(void);
   virtual void      OnChangeDrawdown(void);
   virtual void      OnChangeGain(void);
   virtual void      OnChangeSubscribers(void);
   virtual void      OnChangeParameter(void);
   virtual void      OnChangeDateRange(void);
   virtual void      ResetFilters(void);
   virtual void      OnStart(void);
   virtual void      OnTimer(void);
   //--- Get data for lists in combo boxes and extreme values for input fields
   void              GetData(void);
   //--- Get the array to construct a graph
   void              GetSeries(void);
   //--- Update extreme values in input fields
   bool              UpdateTextEditRange(CTextEdit &obj_from,CTextEdit &obj_to, CMySQLResponse *p, string name);
   //--- Update lists in combo boxes
   bool              UpdateComboBox(CComboBox &object, CMySQLResponse *p, string name, string set_value="");
   //--- Select a point in a combo box list
   void              ComboSelectItem(CComboBox &object,int idx);
   //--- Update the status bar
   bool              UpdateStatusBar(bool result);
   //--- Form part of a query ("where" condition)
   string            Condition(void);
   //---
public:
                     CMain();
                    ~CMain();
   //--- Set transaction parameters
   void              ConfigMySQL(string server,uint port,string login,string password,string db,string table)
     {
      m_mysql_server = server;
      m_mysql_port = port;
      m_mysql_login = login;
      m_mysql_password = password;
      m_mysql_db = db;
      m_mysql_table = table;
     }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMain::CMain() : m_duration(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMain::~CMain()
  {
   if(CheckPointer(mysqlt)==POINTER_DYNAMIC)
      delete mysqlt;
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Currency" combo box    |
//+------------------------------------------------------------------+
void CMain::OnChangeCurrency(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Broker" combo box      |
//+------------------------------------------------------------------+
void CMain::OnChangeBroker(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Author" combo box      |
//+------------------------------------------------------------------+
void CMain::OnChangeAuthor(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "SignalID" combo box    |
//+------------------------------------------------------------------+
void CMain::OnChangeSignalId(void)
  {
   m_duration=0;
   GetSeries();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Equity" input fields   |
//+------------------------------------------------------------------+
void CMain::OnChangeEquity(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Drawdown" input fields |
//+------------------------------------------------------------------+
void CMain::OnChangeDrawdown(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Gain" input fields     |
//+------------------------------------------------------------------+
void CMain::OnChangeGain(void)
  {
   m_duration=0;
   GetData();
  }
//+---------------------------------------------------------------------+
//| Handler of the value change event in the "Subscribers" input fields |
//+---------------------------------------------------------------------+
void CMain::OnChangeSubscribers(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Handler of the value change event in the "Parameter" combo box   |
//+------------------------------------------------------------------+
void CMain::OnChangeParameter(void)
  {
   m_duration=0;
   GetSeries();
  }
//+------------------------------------------------------------------+
//| Handler of changing dates in the calendars                       |
//+------------------------------------------------------------------+
void CMain::OnChangeDateRange(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Application initialization handler                               |
//+------------------------------------------------------------------+
void CMain::OnStart(void)
  {
   m_duration=0;
   GetData();
  }
//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void CMain::OnTimer(void)
  {
   if(CheckPointer(mysqlt)==POINTER_DYNAMIC)
      mysqlt.OnTimer();
  }
//+------------------------------------------------------------------+
//| Return a day start time (datetime) (00:00:00) for t              |
//+------------------------------------------------------------------+
string time_from(datetime t)
  {
   MqlDateTime dt_str;
   if(TimeToStruct(t,dt_str)==false)
      return "";
   dt_str.hour = 0;
   dt_str.min = 0;
   dt_str.sec = 0;
   return DatetimeToMySQL(StructToTime(dt_str));
  }
//+------------------------------------------------------------------+
//| Return a day end time (datetime) (23:59:59) for t                |
//+------------------------------------------------------------------+
string time_to(datetime t)
  {
   MqlDateTime dt_str;
   if(TimeToStruct(t,dt_str)==false)
      return "";
   dt_str.hour = 23;
   dt_str.min = 59;
   dt_str.sec = 59;
   return DatetimeToMySQL(StructToTime(dt_str));
  }
//+------------------------------------------------------------------+
//| Form part of a query with conditions for "where"                 |
//+------------------------------------------------------------------+
string CMain::Condition(void)
  {
//--- Add the time interval
   string s = "`TimeInsert`>='"+time_from(TimeFrom())+"' AND `TimeInsert`<='"+time_to(TimeTo())+"' ";
//--- Add the remaining conditions if required
//--- For drop-down lists, the current value should not be equal to All
   if(Currency()!="All")
      s+= "AND `Currency`='"+Currency()+"' ";
   if(Broker()!="All")
     {
      string broker = Broker();
      //--- the names of some brokers contain characters that should be escaped
      StringReplace(broker,"'","\\'");
      s+= "AND `Broker`='"+broker+"' ";
     }
   if(Author()!="All")
      s+= "AND `AuthorLogin`='"+Author()+"' ";
//--- A checkbox should be set for input fields
   if(m_equity_from.IsPressed()==true)
      s+= "AND `Equity`>='"+m_equity_from.GetValue()+"' AND `Equity`<='"+m_equity_to.GetValue()+"' ";
   if(m_gain_from.IsPressed()==true)
      s+= "AND `Gain`>='"+m_gain_from.GetValue()+"' AND `Gain`<='"+m_gain_to.GetValue()+"' ";
   if(m_drawdown_from.IsPressed()==true)
      s+= "AND `Drawdown`>='"+m_drawdown_from.GetValue()+"' AND `Drawdown`<='"+m_drawdown_to.GetValue()+"' ";
   if(m_subscribers_from.IsPressed()==true)
      s+= "AND `Subscribers`>='"+m_subscribers_from.GetValue()+"' AND `Subscribers`<='"+m_subscribers_to.GetValue()+"' ";
   return s;
  }
//+------------------------------------------------------------------+
//| Send a query for receiving the buffer to plot a graph            |
//+------------------------------------------------------------------+
void CMain::GetSeries(void)
  {
   if(SignalId()=="Select...")
     {
      // if a signal is not selected
      ArrayFree(x_buf);
      ArrayFree(y_buf);
      UpdateSeries();
      return;
     }
   if(CheckPointer(mysqlt)==POINTER_INVALID)
     {
      mysqlt = new CMySQLTransaction;
      mysqlt.Config(m_mysql_server,m_mysql_port,m_mysql_login,m_mysql_password,60000);
      mysqlt.PingPeriod(10000);
     }
   string   q = "select `"+Parameter()+"` ";
   q+= "from `"+m_mysql_db+"`.`"+m_mysql_table+"` ";
   q+= "where `TimeInsert`>='"+time_from(TimeFrom())+"' AND `TimeInsert`<='"+time_to(TimeTo())+"' ";
   q+= "AND `Id`='"+SignalId()+"' order by `TimeInsert` asc";
//--- Send a query
   if(UpdateStatusBar(mysqlt.Query(q))==false)
      return;
//--- Check the number of responses
   if(mysqlt.Responses()<1)
      return;
   CMySQLResponse *r = mysqlt.Response(0);
   uint rows = r.Rows();
   if(rows<1)
      return;
//--- copy the column to the graph data buffer (false - do not check the types)
   if(r.ColumnToArray(Parameter(),y_buf,false)<1)
      return;
//--- form X axis labels
   if(ArrayResize(x_buf,rows)!=rows)
      return;
   for(uint i=0; i<rows; i++)
      x_buf[i] = i;
//--- Update the graph
   UpdateSeries();
  }
//+------------------------------------------------------------------+
//| Send a query for receiving data for lists and input fields       |
//+------------------------------------------------------------------+
void CMain::GetData(void)
  {
   if(CheckPointer(mysqlt)==POINTER_INVALID)
     {
      mysqlt = new CMySQLTransaction;
      mysqlt.Config(m_mysql_server,m_mysql_port,m_mysql_login,m_mysql_password,60000);
      mysqlt.PingPeriod(10000);
     }
//--- save signal id
   string signal_id = SignalId();
   if(signal_id=="Select...")
      signal_id="";
//---
   string   q = "";
   if(Currency()=="All")
     {
      q+= "select `Currency` from `"+m_mysql_db+"`.`"+m_mysql_table+"` where "+Condition()+" group by `Currency`; ";
     }
   if(Broker()=="All")
     {
      q+= "select `Broker` from `"+m_mysql_db+"`.`"+m_mysql_table+"` where "+Condition()+" group by `Broker`; ";
     }
   if(Author()=="All")
     {
      q+= "select `AuthorLogin` from `"+m_mysql_db+"`.`"+m_mysql_table+"` where "+Condition()+" group by `AuthorLogin`; ";
     }
   q+= "select `Id` from `"+m_mysql_db+"`.`"+m_mysql_table+"` where "+Condition()+" group by `Id`; ";
   q+= "select Min(`Equity`) as EquityMin, Max(`Equity`) as EquityMax";
   q+= ", Min(`Gain`) as GainMin, Max(`Gain`) as GainMax";
   q+= ", Min(`Drawdown`) as DrawdownMin, Max(`Drawdown`) as DrawdownMax";
   q+= ", Min(`Subscribers`) as SubscribersMin, Max(`Subscribers`) as SubscribersMax from `"+m_mysql_db+"`.`"+m_mysql_table+"` where "+Condition();
//--- Display the transaction result in the status bar
   if(UpdateStatusBar(mysqlt.Query(q))==false)
      return;
//--- Set accepted values in the combo box lists and extreme values of the input fields
   uint responses = mysqlt.Responses();
   for(uint j=0; j<responses; j++)
     {
      if(mysqlt.Response(j).Fields()<1)
         continue;
      if(UpdateComboBox(m_currency,mysqlt.Response(j),"Currency")==true)
         continue;
      if(UpdateComboBox(m_broker,mysqlt.Response(j),"Broker")==true)
         continue;
      if(UpdateComboBox(m_author,mysqlt.Response(j),"AuthorLogin")==true)
         continue;
      if(UpdateComboBox(m_signal_id,mysqlt.Response(j),"Id",signal_id)==true)
         continue;
      //
      UpdateTextEditRange(m_equity_from,m_equity_to,mysqlt.Response(j),"Equity");
      UpdateTextEditRange(m_gain_from,m_gain_to,mysqlt.Response(j),"Gain");
      UpdateTextEditRange(m_drawdown_from,m_drawdown_to,mysqlt.Response(j),"Drawdown");
      UpdateTextEditRange(m_subscribers_from,m_subscribers_to,mysqlt.Response(j),"Subscribers");
     }
   GetSeries();
  }
//+------------------------------------------------------------------+
//| Select an element in the list by index                           |
//+------------------------------------------------------------------+
void CMain::ComboSelectItem(CComboBox &object,int idx)
  {
   object.GetListViewPointer().SelectItem(idx,true);
   object.GetButtonPointer().LabelText(object.GetListViewPointer().GetValue(idx));
   object.GetButtonPointer().Update(true);
   object.Update(true);
  }
//+------------------------------------------------------------------+
//| Reset all filters (except dates)                                 |
//+------------------------------------------------------------------+
void CMain::ResetFilters(void)
  {
//--- reset the filters
   m_equity_from.IsPressed(false);
   m_equity_from.GetTextBoxPointer().IsLocked(true);
   m_equity_to.GetTextBoxPointer().IsLocked(true);
//
   m_gain_from.IsPressed(false);
   m_gain_from.GetTextBoxPointer().IsLocked(true);
   m_gain_to.GetTextBoxPointer().IsLocked(true);
//
   m_drawdown_from.IsPressed(false);
   m_drawdown_from.GetTextBoxPointer().IsLocked(true);
   m_drawdown_to.GetTextBoxPointer().IsLocked(true);
//
   m_subscribers_from.IsPressed(false);
   m_subscribers_from.GetTextBoxPointer().IsLocked(true);
   m_subscribers_to.GetTextBoxPointer().IsLocked(true);
//---
   ComboSelectItem(m_currency,0);
   ComboSelectItem(m_author,0);
   ComboSelectItem(m_broker,0);
   ComboSelectItem(m_signal_id,0);
//--- After that, update the lists of combo boxes and extreme values of the input fields
   GetData();
  }
//+------------------------------------------------------------------+
//| Update the status bar                                            |
//+------------------------------------------------------------------+
bool CMain::UpdateStatusBar(bool result)
  {
   if(result==true)
     {
      //--- get the query execution time
      m_duration+= mysqlt.RequestDuration();
      string dstr = "";
      if(m_duration>1000)
         dstr = IntegerToString(m_duration/1000)+" ms";
      else
         dstr = IntegerToString(m_duration)+" us";
      m_status_bar.GetItemPointer(0).LabelText("Request has been successfully completed in "+dstr);
     }
   else
     {
      if(GetLastError()==(ERR_USER_ERROR_FIRST+MYSQL_ERR_SERVER_ERROR))
        {
         // in case of a server error
         MySQLServerError err = mysqlt.GetServerError();
         m_status_bar.GetItemPointer(0).LabelText("ERROR: "+IntegerToString(err.code)+", read the message in the \"experts\" tab");
         Print(err.message);
        }
      else
        {
         if(GetLastError()>=ERR_USER_ERROR_FIRST)
            m_status_bar.GetItemPointer(0).LabelText("Transaction Error: "+EnumToString(ENUM_TRANSACTION_ERROR(GetLastError()-ERR_USER_ERROR_FIRST)));
         else
            m_status_bar.GetItemPointer(0).LabelText("Error: "+IntegerToString(GetLastError()));
        }
     }
   m_status_bar.GetItemPointer(0).Update(true);
   m_status_bar.GetItemPointer(1).LabelText("Rx: "+IntegerToString(mysqlt.RxBytesTotal())+", Tx: "+IntegerToString(mysqlt.TxBytesTotal()));
   m_status_bar.GetItemPointer(1).Update(true);
   return result;
  }
//+------------------------------------------------------------------+
//| Update extreme values for the input fields                       |
//+------------------------------------------------------------------+
bool CMain::UpdateTextEditRange(CTextEdit &obj_from,CTextEdit &obj_to, CMySQLResponse *p, string name)
  {
   if(p.Rows()<1)
      return false;
   else
      return SetTextEditRange(obj_from,obj_to,p.Value(0,name+"Min"),p.Value(0,name+"Max"));
  }
//+------------------------------------------------------------------+
//| Update values in the combo box list                              |
//+------------------------------------------------------------------+
bool CMain::UpdateComboBox(CComboBox &object, CMySQLResponse *p, string name, string set_value="")
  {
   int col_idx = p.Field(name);
   if(col_idx<0)
      return false;
   uint total = p.Rows()+1;
   if(total!=object.GetListViewPointer().ItemsTotal())
     {
      string tmp = object.GetListViewPointer().GetValue(0);
      object.GetListViewPointer().Clear();
      object.ItemsTotal(total);
      object.SetValue(0,tmp);
      object.GetListViewPointer().YSize(18*((total>16)?16:total)+3);
     }
   uint set_val_idx = 0;
   for(uint i=1; i<total; i++)
     {
      string value = p.Value(i-1,col_idx);
      object.SetValue(i,value);
      if(set_value!="" && value==set_value)
         set_val_idx = i;
     }
//--- if there is no specified value, but there are others, select the topmost one
   if(set_value!="" && set_val_idx==0 && total>1)
      set_val_idx=1;
//---
   ComboSelectItem(object,set_val_idx);
//---
   return true;
  }
//+------------------------------------------------------------------+
