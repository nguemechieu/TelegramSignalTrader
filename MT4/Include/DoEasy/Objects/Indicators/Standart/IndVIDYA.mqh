//+------------------------------------------------------------------+
//|                                                     IndVIDYA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\\IndicatorDE.mqh"
//+------------------------------------------------------------------+
//| Variable Index Dynamic Average standard indicator                |
//+------------------------------------------------------------------+
class CIndVIDYA : public CIndicatorDE 
  {
private:

public:
   //--- Constructor
                     CIndVIDYA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                        CIndicatorDE(IND_VIDYA,symbol,timeframe,
                                     INDICATOR_STATUS_STANDART,
                                     INDICATOR_GROUP_TREND,
                                     "Variable Index Dynamic Average",
                                     "VIDYA("+symbol+","+TimeframeDescription(timeframe)+")",mql_param) {}
   //--- Supported indicator properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_INDICATOR_PROP_DOUBLE property); 
   virtual bool      SupportProperty(ENUM_INDICATOR_PROP_INTEGER property);

//--- Display (1) a short description, (2) description of indicator object parameters in the journal
   virtual void      PrintShort(void);
   virtual void      PrintParameters(void);
  };
//+------------------------------------------------------------------+
//| Return 'true' if the indicator supports the passed               |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CIndVIDYA::SupportProperty(ENUM_INDICATOR_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if the indicator supports the passed               |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CIndVIDYA::SupportProperty(ENUM_INDICATOR_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Display a short description of indicator object in the journal   |
//+------------------------------------------------------------------+
void CIndVIDYA::PrintShort(void)
  {
   string id=(this.ID()>WRONG_VALUE ? ", id #"+(string)this.ID()+"]" : "]");
   ::Print(GetStatusDescription()," ",this.Name()," ",this.Symbol()," ",TimeframeDescription(this.Timeframe())," [handle ",this.Handle(),id);
  }
//+------------------------------------------------------------------+
//| Display parameter description of indicator object in the journal |
//+------------------------------------------------------------------+
void CIndVIDYA::PrintParameters(void)
  {
   ::Print(" --- ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_IND_PARAMETERS)," --- ");
   //--- cmo_period
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_CMO_PERIOD),": ",(string)m_mql_param[0].integer_value);
   //--- ema_period
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_SMOOTHING_PERIOD),": ",(string)m_mql_param[1].integer_value);
   //--- ma_shift
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_SHIFT),": ",(string)m_mql_param[2].integer_value);
   //--- applied_price
   ::Print(
           " - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_APPLIED_PRICE),": ",
           (m_mql_param[3].integer_value<10 ? AppliedPriceDescription((ENUM_APPLIED_PRICE)m_mql_param[3].integer_value) : (string)m_mql_param[3].integer_value)
          );
  }
//+------------------------------------------------------------------+
