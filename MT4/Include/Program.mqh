//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\WndCreate.mqh>
//+------------------------------------------------------------------+
//| GUI creation class                                               |
//+------------------------------------------------------------------+
class CProgram : public CWndCreate
  {
protected:
   //--- Main window
   CWindow           m_window;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Calendars
   CCalendar         m_calendar1;
   CCalendar         m_calendar2;
   //--- Separation lines
   CSeparateLine     m_sep_line1;
   CSeparateLine     m_sep_line2;
   CSeparateLine     m_sep_line3;
   //--- Button
   CButton           m_reset;
   //--- Text labels
   CTextLabel        m_txt_from;
   CTextLabel        m_txt_to;
   //--- Combo boxes
   CComboBox         m_currency;
   CComboBox         m_broker;
   CComboBox         m_author;
   CComboBox         m_signal_id;
   CComboBox         m_parameters;
   //--- Edits
   CTextEdit         m_equity_from;
   CTextEdit         m_equity_to;
   CTextEdit         m_gain_from;
   CTextEdit         m_gain_to;
   CTextEdit         m_drawdown_from;
   CTextEdit         m_drawdown_to;
   CTextEdit         m_subscribers_from;
   CTextEdit         m_subscribers_to;
   //--- Graph
   CGraph            m_graph1;
   //--- Arrays of data for output to the chart
   double            x_buf[];
   double            y_buf[];
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/deinitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- Create the graphical interface of the program
   bool              CreateGUI(void);
   //---
protected:
   //--- Graph
   bool              CreateGraph1(const int x_gap,const int y_gap);
   //--- Calendar
   bool              CreateCalendar1(const int x_gap,const int y_gap);
   bool              CreateCalendar2(const int x_gap,const int y_gap);
   //--- Calls for GUI	events
   virtual void      OnChangeCurrency(void)   {}
   virtual void      OnChangeBroker(void)     {}
   virtual void      OnChangeAuthor(void)     {}
   virtual void      OnChangeSignalId(void)   {}
   virtual void      OnChangeEquity(void)     {}
   virtual void      OnChangeDrawdown(void)   {}
   virtual void      OnChangeGain(void)       {}
   virtual void      OnChangeSubscribers(void) {}
   virtual void      OnChangeParameter(void)  {}
   virtual void      OnChangeDateRange(void)  {}
   virtual void      ResetFilters(void)       {}
   virtual void      OnStart(void)            {}
   virtual void      OnTimer(void)            {}
   //--- Methods of receiving selected combo box values
   string            Currency(void);
   void              Currency(string &items[]);
   string            Broker(void);
   void              Broker(string &items[]);
   string            Author(void);
   void              Author(string &items[]);
   string            SignalId(void);
   void              SignalId(string &items[]);
   string            Parameter(void);
   //--- Get calendar values
   datetime          TimeFrom(void);
   datetime          TimeTo(void);
   //--- Set extreme values of a pair of input fields ("from","to")
   bool              SetTextEditRange(CTextEdit &obj_from,CTextEdit &obj_to,string min, string max);
   //--- Handle clicking checkboxes
   bool              CheckBoxOnClickHandler(const long &lparam,CTextEdit &from,CTextEdit &to);
   bool              FiltersTextEditHandler(const long &lparam);
   //--- Set and update series on the chart
   void              UpdateSeries(void);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
   OnStart();
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Remove the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//---
   OnTimer();
  }
//+------------------------------------------------------------------+
//| Handle clicking a checkbox                                       |
//+------------------------------------------------------------------+
bool CProgram::CheckBoxOnClickHandler(const long &lparam,CTextEdit &from,CTextEdit &to)
  {
   if(lparam==from.Id())
     {
      if(from.IsPressed()==false)
        {
         from.GetTextBoxPointer().IsLocked(true);
         to.GetTextBoxPointer().IsLocked(true);
        }
      else
        {
         from.GetTextBoxPointer().IsLocked(false);
         to.GetTextBoxPointer().IsLocked(false);
        }
      return true;   // handled
     }
   return false;     // not handled
  }
//+------------------------------------------------------------------+
//| Handler of editing the input fields                              |
//+------------------------------------------------------------------+
bool CProgram::FiltersTextEditHandler(const long &lparam)
  {
// Equity
   if(lparam==m_equity_from.Id())
     {
      OnChangeEquity();
      return true;
     }
   if(lparam==m_equity_to.Id())
     {
      OnChangeEquity();
      return true;
     }
// Gain
   if(lparam==m_gain_from.Id())
     {
      OnChangeGain();
      return true;
     }
   if(lparam==m_gain_to.Id())
     {
      OnChangeGain();
      return true;
     }
// Drawdown
   if(lparam==m_drawdown_from.Id())
     {
      OnChangeDrawdown();
      return true;
     }
   if(lparam==m_drawdown_to.Id())
     {
      OnChangeDrawdown();
      return true;
     }
// Subscribers
   if(lparam==m_subscribers_from.Id())
     {
      OnChangeSubscribers();
      return true;
     }
   if(lparam==m_subscribers_to.Id())
     {
      OnChangeSubscribers();
      return true;
     }
   return false;     // not handled
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Event of changing the date in the calendar
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_DATE)
     {
      if(lparam==m_calendar1.Id() || lparam==m_calendar2.Id())
        {
         OnChangeDateRange();
         return;
        }
      return;
     }
//--- Event of changing the checkbox state
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
     {
      if(CheckBoxOnClickHandler(lparam,m_equity_from,m_equity_to)==true)
        {
         OnChangeEquity();
         return;
        }
      if(CheckBoxOnClickHandler(lparam,m_gain_from,m_gain_to)==true)
        {
         OnChangeGain();
         return;
        }
      if(CheckBoxOnClickHandler(lparam,m_drawdown_from,m_drawdown_to)==true)
        {
         OnChangeDrawdown();
         return;
        }
      if(CheckBoxOnClickHandler(lparam,m_subscribers_from,m_subscribers_to)==true)
        {
         OnChangeSubscribers();
         return;
        }
      return;
     }
//--- Selection of an item in a combo box
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      if(lparam==m_currency.Id())
        {
         OnChangeCurrency();
         return;
        }
      if(lparam==m_author.Id())
        {
         OnChangeAuthor();
         return;
        }
      if(lparam==m_broker.Id())
        {
         OnChangeBroker();
         return;
        }
      if(lparam==m_signal_id.Id())
        {
         OnChangeSignalId();
         return;
        }
      if(lparam==m_parameters.Id())
        {
         OnChangeParameter();
         return;
        }
      return;
     }
//--- Entering a new value in the input field
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      if(FiltersTextEditHandler(lparam)==true)
         return;
      return;
     }
//--- Clicking input field switching buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==m_reset.Id())
        {
         //--- reset the filters and execute the query
         ResetFilters();
         return;
        }
      if(FiltersTextEditHandler(lparam)==true)
         return;
      return;
     }
  }
//+------------------------------------------------------------------+
//| Read time from the start date calendar                           |
//+------------------------------------------------------------------+
datetime CProgram::TimeFrom(void)
  {
   return m_calendar1.SelectedDate();
  }
//+------------------------------------------------------------------+
//| Read time from the end date calendar                             |
//+------------------------------------------------------------------+
datetime CProgram::TimeTo(void)
  {
   return m_calendar2.SelectedDate();
  }
//+------------------------------------------------------------------+
//| Read the name of a selected currency                             |
//+------------------------------------------------------------------+
string CProgram::Currency(void)
  {
   return m_currency.GetValue();
  }
//+------------------------------------------------------------------+
//| Update the list of available currencies                          |
//+------------------------------------------------------------------+
void CProgram::Currency(string &items[])
  {
   int total=::ArraySize(items)+1;
   if(total!=m_currency.GetListViewPointer().ItemsTotal())
     {
      m_currency.ItemsTotal(total);
      m_currency.SetValue(0,"All");
     }
   for(int i=1; i<total; i++)
      m_currency.SetValue(i,items[i-1]);
   m_currency.GetListViewPointer().SelectItem(0,true);
   m_currency.Update(true);
  }
//+------------------------------------------------------------------+
//| Read the name of a selected broker                               |
//+------------------------------------------------------------------+
string CProgram::Broker(void)
  {
   return m_broker.GetValue();
  }
//+------------------------------------------------------------------+
//| Update the list of available brokers                             |
//+------------------------------------------------------------------+
void CProgram::Broker(string &items[])
  {
   int total=::ArraySize(items)+1;
   if(total!=m_broker.GetListViewPointer().ItemsTotal())
     {
      m_broker.ItemsTotal(total);
      m_broker.SetValue(0,"All");
     }
   for(int i=1; i<total; i++)
      m_broker.SetValue(i,items[i-1]);
   m_broker.GetListViewPointer().SelectItem(0,true);
   m_broker.Update(true);
  }
//+------------------------------------------------------------------+
//| Read the name of a selected provider                             |
//+------------------------------------------------------------------+
string CProgram::Author(void)
  {
   return m_author.GetValue();
  }
//+------------------------------------------------------------------+
//| Update the list of available providers                           |
//+------------------------------------------------------------------+
void CProgram::Author(string &items[])
  {
   int total=::ArraySize(items)+1;
   if(total!=m_author.GetListViewPointer().ItemsTotal())
     {
      m_author.ItemsTotal(total);
      m_author.SetValue(0,"All");
     }
   for(int i=1; i<total; i++)
      m_author.SetValue(i,items[i-1]);
   m_author.GetListViewPointer().SelectItem(0,true);
   m_author.Update(true);
  }
//+------------------------------------------------------------------+
//| Read a selected signal ID                                        |
//+------------------------------------------------------------------+
string CProgram::SignalId(void)
  {
   return m_signal_id.GetValue();
  }
//+------------------------------------------------------------------+
//| Read the value of a selected parameter                           |
//+------------------------------------------------------------------+
string CProgram::Parameter(void)
  {
   return m_parameters.GetValue();
  }
//+------------------------------------------------------------------+
//| Update the list of IDs of available signals                      |
//+------------------------------------------------------------------+
void CProgram::SignalId(string &items[])
  {
   int total=::ArraySize(items)+1;
   if(total!=m_signal_id.GetListViewPointer().ItemsTotal())
     {
      m_signal_id.ItemsTotal(total);
      m_signal_id.SetValue(0,"Any");
     }
   for(int i=1; i<total; i++)
      m_signal_id.SetValue(i,items[i-1]);
   m_signal_id.GetListViewPointer().SelectItem(0,true);
   m_signal_id.Update(true);
  }
//+--------------------------------------------------------------------------------+
//| Set the minimum and maximum values for the "from" and "to" input field pair    |
//+--------------------------------------------------------------------------------+
bool CProgram::SetTextEditRange(CTextEdit &obj_from,CTextEdit &obj_to,string min, string max)
  {
   double Min = MathFloor(StringToDouble(min));
   double Max = MathCeil(StringToDouble(max));
   obj_from.MinValue(Min);
   obj_from.MaxValue(Max);
   if(obj_from.IsPressed()==false || Min>StringToDouble(obj_from.GetValue()))
      obj_from.SetValue(DoubleToString(Min,0));
   obj_from.Update(true);
   obj_from.GetTextBoxPointer().Update(true);
   obj_to.MinValue(Min);
   obj_to.MaxValue(Max);
   if(obj_from.IsPressed()==false || Max<StringToDouble(obj_from.GetValue()))
      obj_to.SetValue(DoubleToString(Max,0));
   obj_to.Update(true);
   obj_to.GetTextBoxPointer().Update(true);
   return true;
  }
//+------------------------------------------------------------------+
