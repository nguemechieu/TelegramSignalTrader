//+------------------------------------------------------------------+
//|                                                      BaseObj.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include "..\Services\DELib.mqh"
//+------------------------------------------------------------------+
//| Base object event class for all library objects                  |
//+------------------------------------------------------------------+
class CEventBaseObj : public CObject
  {
private:
   long              m_time;
   long              m_chart_id;
   ushort            m_event_id;
   long              m_lparam;
   double            m_dparam;
   string            m_sparam;
public:
   void              Time(const long time)               { this.m_time=time;           }
   long              Time(void)                    const { return this.m_time;         }
   void              ChartID(const long chart_id)        { this.m_chart_id=chart_id;   }
   long              ChartID(void)                 const { return this.m_chart_id;     }
   void              ID(const ushort id)                 { this.m_event_id=id;         }
   ushort            ID(void)                      const { return this.m_event_id;     }
   void              LParam(const long lparam)           { this.m_lparam=lparam;       }
   long              LParam(void)                  const { return this.m_lparam;       }
   void              DParam(const double dparam)         { this.m_dparam=dparam;       }
   double            DParam(void)                  const { return this.m_dparam;       }
   void              SParam(const string sparam)         { this.m_sparam=sparam;       }
   string            SParam(void)                  const { return this.m_sparam;       }
public:
//--- Constructor
                     CEventBaseObj(const ushort event_id,const long lparam,const double dparam,const string sparam) : m_chart_id(::ChartID()) 
                       { 
                        this.m_event_id=event_id;
                        this.m_lparam=lparam;
                        this.m_dparam=dparam;
                        this.m_sparam=sparam;
                       }
//--- Comparison method to search for identical event objects
   virtual int       Compare(const CObject *node,const int mode=0) const 
                       {   
                        const CEventBaseObj *compared=node;
                        return
                          (
                           this.ID()>compared.ID()          ?  1  :
                           this.ID()<compared.ID()          ? -1  :
                           this.LParam()>compared.LParam()  ?  1  :
                           this.LParam()<compared.LParam()  ? -1  :
                           this.DParam()>compared.DParam()  ?  1  :
                           this.DParam()<compared.DParam()  ? -1  :
                           this.SParam()>compared.SParam()  ?  1  :
                           this.SParam()<compared.SParam()  ? -1  :  0
                          );
                       } 
  };
//+------------------------------------------------------------------+
//| Base object class for all library objects                        |
//+------------------------------------------------------------------+
class CBaseObj : public CObject
  {
private:

protected:
   CArrayObj         m_list_events;                            // Object event list
   MqlTick           m_tick;                                   // Tick structure for receiving quote data
   double            m_hash_sum;                               // Object data hash sum
   double            m_hash_sum_prev;                          // Object data hash sum during the previous check
   int               m_digits_currency;                        // Number of decimal places in an account currency
   int               m_global_error;                           // Global error code
   long              m_chart_id;                               // Control program chart ID
   bool              m_is_event;                               // Object event flag
   int               m_event_code;                             // Object event code
   string            m_name;                                   // Object name
   string            m_folder_name;                            // Name of the folder storing CBaseObj descendant objects

//--- Return time in milliseconds from MqlTick
   long              TickTime(void)                            const { return #ifdef __MQL5__ this.m_tick.time_msc #else this.m_tick.time*1000 #endif ;}
//--- return the flag of the event code presence in the event object
   bool              IsPresentEventFlag(const int change_code) const { return (this.m_event_code & change_code)==change_code; }
//--- Return the number of decimal places of the account currency
   int               DigitsCurrency(void)                      const { return this.m_digits_currency; }
//--- Returns the number of decimal places in the 'double' value
   int               GetDigits(const double value)             const;
//--- Initialize the variables of (1) tracked, (2) controlled object data (implementation in the descendants)
   virtual void      InitChangesParams(void);
   virtual void      InitControlsParams(void);
//--- (1) Check the object change, return the change code, (2) set the event type and fill in the list of events (implementation in the descendants)
   virtual int       SetEventCode(void);
   virtual void      SetTypeEvent(void);
public:
//--- Add the event object to the list
   bool              EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam);
//--- Return the occurred event flag to the object data
   bool              IsEvent(void)                             const { return this.m_is_event;              }
//--- Return (1) the list of events, (2) the object event code and (3) the global error code
   CArrayObj        *GetListEvents(void)                             { return &this.m_list_events;          }
   int               GetEventCode(void)                        const { return this.m_event_code;            }
   int               GetError(void)                            const { return this.m_global_error;          }
//--- Return the event object by its number in the list
   CEventBaseObj    *GetEvent(const int shift=WRONG_VALUE,const bool check_out=true);
//--- Return the number of object events
   int               GetEventsTotal(void)                      const { return this.m_list_events.Total();   }
//--- (1) Set and (2) return the chart ID of the control program
   void              SetChartID(const long id)                       { this.m_chart_id=id;                  }
   long              GetChartID(void)                          const { return this.m_chart_id;              }
//--- (1) Set the sub-folder name, (2) return the folder name for storing descendant object files
   void              SetSubFolderName(const string name)             { this.m_folder_name=DIRECTORY+name;   }
   string            GetFolderName(void)                       const { return this.m_folder_name;           }
//--- Return the object name
   string            GetName(void)                             const { return this.m_name;                  }
//--- Update the object data (implementation in the descendants)
   virtual void      Refresh(void);
   
//--- Constructor
                     CBaseObj();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBaseObj::CBaseObj() : m_global_error(ERR_SUCCESS),
                       m_hash_sum(0),m_hash_sum_prev(0),
                       m_is_event(false),m_event_code(0),
                       m_chart_id(::ChartID()),
                       m_folder_name(DIRECTORY),
                       m_name("")
  {
   ::ZeroMemory(this.m_tick);
   this.m_digits_currency=(#ifdef __MQL5__ (int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS) #else 2 #endif);
   this.m_list_events.Clear();
   this.m_list_events.Sort();
  }
//+------------------------------------------------------------------+
//| Add the event object to the list                                 |
//+------------------------------------------------------------------+
bool CBaseObj::EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam)
  {
   CEventBaseObj *event=new CEventBaseObj(event_id,lparam,dparam,sparam);
   if(event==NULL)
      return false;
   this.m_list_events.Sort();
   if(this.m_list_events.Search(event)>WRONG_VALUE)
     {
      delete event;
      return false;
     }
   return this.m_list_events.Add(event);
  }
//+------------------------------------------------------------------+
//| Return the object event by its index in the list                 |
//+------------------------------------------------------------------+
CEventBaseObj *CBaseObj::GetEvent(const int shift=WRONG_VALUE,const bool check_out=true)
  {
   int total=this.m_list_events.Total();
   if(total==0 || (!check_out && shift>total-1))
      return NULL;   
   int index=(shift<=0 ? total-1 : shift>total-1 ? 0 : total-shift-1);
   CEventBaseObj *event=this.m_list_events.At(index);
   return(event!=NULL ? event : NULL);
  }
//+------------------------------------------------------------------+
//| Return the number of decimal places in the 'double' value        |
//+------------------------------------------------------------------+
int CBaseObj::GetDigits(const double value) const
  {
   string val_str=(string)value;
   int len=::StringLen(val_str);
   int n=len-::StringFind(val_str,".",0)-1;
   if(::StringSubstr(val_str,len-1,1)=="0")
      n--;
   return n;
  }
//+------------------------------------------------------------------+
