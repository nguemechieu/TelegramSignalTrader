//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Create the graphical interface of the program                    |
//+------------------------------------------------------------------+
bool CProgram::CreateGUI(void)
  {
//--- Create the form for control elements
   if(!CWndCreate::CreateWindow(m_window,"EXPERT PANEL",1,1,720,480,true,true,true,true))//640
      return(false);
//--- Status bar
   string text_items[2];
   text_items[0]="For Help, press F1";
   text_items[1]="Rx: 0, Tx: 0";
   int width_items[]= {0,130};
   if(!CWndCreate::CreateStatusBar(m_status_bar,m_window,1,23,22,text_items,width_items))
      return(false);
//--- Calendars
   if(!CreateCalendar1(9,56))
      return(false);
   if(!CreateCalendar2(9,250))
      return(false);
//--- Text labels
   if(!CWndCreate::CreateTextLabel(m_txt_from,"Date From",m_window,0,9,33,161))
      return(false);
   if(!CWndCreate::CreateTextLabel(m_txt_to,"Date To",m_window,0,9,227,161))
      return(false);
//--- Button
   if(!CWndCreate::CreateButton(m_reset,"Reset filters",m_window,0,9,416,161))
      return(false);
//--- Separation lines
   if(!CWndCreate::CreateSepLine(m_sep_line1,m_window,0, 178,28,2,421, C'150,150,150',clrWhite,V_SEP_LINE))
      return(false);
   if(!CWndCreate::CreateSepLine(m_sep_line2,m_window,0, 188,84,524,2, C'150,150,150',clrWhite,H_SEP_LINE))
      return(false);
   if(!CWndCreate::CreateSepLine(m_sep_line3,m_window,0, 188,150,524,2, C'150,150,150',clrWhite,H_SEP_LINE))
      return(false);
//--- Input fields ("from" and "to" pairs)
   if(!CWndCreate::CreateTextEdit(m_equity_from,"Equity from:",m_window,0,true, 188,94,156,78, 1,0,1,0,0))
      return(false);
   m_equity_from.GetTextBoxPointer().IsLocked(true);
   if(!CWndCreate::CreateTextEdit(m_equity_to," to:",m_window,0,false, 348,94,96,78, 1,0,1,0,0))
      return(false);
   m_equity_to.GetTextBoxPointer().IsLocked(true);
//
   if(!CWndCreate::CreateTextEdit(m_gain_from,"Gain from:",m_window,0,true, 188,122,156,78, 1,0,1,0,0))
      return(false);
   m_gain_from.GetTextBoxPointer().IsLocked(true);
   if(!CWndCreate::CreateTextEdit(m_gain_to," to:",m_window,0,false, 348,122,96,78, 1,0,1,0,0))
      return(false);
   m_gain_to.GetTextBoxPointer().IsLocked(true);
//
   if(!CWndCreate::CreateTextEdit(m_drawdown_from,"Drawdown from:",m_window,0,true, 454,94,170,65, 1,0,1,0,0))
      return(false);
   m_drawdown_from.GetTextBoxPointer().IsLocked(true);
   if(!CWndCreate::CreateTextEdit(m_drawdown_to," to:",m_window,0,false, 628,94,83,65, 1,0,1,0,0))
      return(false);
   m_drawdown_to.GetTextBoxPointer().IsLocked(true);
//
   if(!CWndCreate::CreateTextEdit(m_subscribers_from,"Subscribers from:",m_window,0,true, 454,122,170,65, 1,0,1,0,0))
      return(false);
   m_subscribers_from.GetTextBoxPointer().IsLocked(true);
   if(!CWndCreate::CreateTextEdit(m_subscribers_to," to:",m_window,0,false, 628,122,83,65, 1,0,1,0,0))
      return(false);
   m_subscribers_to.GetTextBoxPointer().IsLocked(true);
//--- Combo boxes
   string items1[]= {"All"};
   if(!CWndCreate::CreateCombobox(m_currency,"Currency:",m_window,0,false, 188,28,258,203, items1,39))
      return(false);
   if(!CWndCreate::CreateCombobox(m_broker,  "Broker:",  m_window,0,false, 188,56,524,469, items1,39))
      return(false);
   if(!CWndCreate::CreateCombobox(m_author,  "Author:",  m_window,0,false, 454,28,258,193, items1,39))
      return(false);
   string items2[]= {"Select..."};
   if(!CWndCreate::CreateCombobox(m_signal_id,"Signal ID:",m_window,0,false, 188,160,258,203, items2,39))
      return(false);
   string items3[]= {"Balance","Equity","Gain","Drawdown","Price","ROI","Leverage","Pips","Rating","Subscribers","Trades"};
   if(!CWndCreate::CreateCombobox(m_parameters,"Parameter:",m_window,0,false, 454,160,258,193, items3,201))
      return(false);
//--- Graph
   if(!CreateGraph1(188,188))
      return(false);
//--- Complete GUI creation
   CWndEvents::CompletedGUI();
   return(true);
  }
//+------------------------------------------------------------------+
//| Create calendar 1                                                |
//+------------------------------------------------------------------+
bool CProgram::CreateCalendar1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_calendar1.MainPointer(m_window);
//--- Create a control element
   if(!m_calendar1.CreateCalendar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_calendar1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create calendar 2                                                |
//+------------------------------------------------------------------+
bool CProgram::CreateCalendar2(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_calendar2.MainPointer(m_window);
//--- Create a control element
   if(!m_calendar2.CreateCalendar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_calendar2);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create graph 1                                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph1.MainPointer(m_window);
//--- Element properties
   m_graph1.AutoXResizeMode(true);
   m_graph1.AutoYResizeMode(true);
   m_graph1.AutoXResizeRightOffset(2);
   m_graph1.AutoYResizeBottomOffset(23);
//--- Create element
   if(!m_graph1.CreateGraph(x_gap,y_gap))
      return(false);
//--- Chart properties
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
   graph.HistoryNameWidth(0);
//--- Properties of the X axis
   CAxis *x_axis=graph.XAxis();
   x_axis.AutoScale(true);
//--- Properties of the Y axis
   CAxis *y_axis=graph.YAxis();
   y_axis.ValuesWidth(30);
   y_axis.AutoScale(true);
//--- Hide the graph
   m_graph1.Hide();
//--- Create a curve
   CCurve *curve1=graph.CurveAdd(x_buf,y_buf,::ColorToARGB(clrCornflowerBlue),CURVE_LINES);
//--- Plot the data on the graph
   graph.CurvePlotAll();
//--- Add a pointer to the element to the database
   CWndContainer::AddToElementsArray(0,m_graph1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Set and update series on the graph                               |
//+------------------------------------------------------------------+
void CProgram::UpdateSeries(void)
  {
//--- Get the pointer to the graph
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- Update all series of the chart
   int total=graph.CurvesTotal();
   if(total>0)
     {
      //--- Get the curve pointer
      CCurve *curve=graph.CurveGetByIndex(0);
      //--- Set data arrays
      curve.Update(x_buf,y_buf);
     }
//--- Apply
   graph.Redraw(true);
//--- Update the graph
   graph.Update();
  }
//+------------------------------------------------------------------+
