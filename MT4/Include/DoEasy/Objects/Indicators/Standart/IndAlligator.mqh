//+------------------------------------------------------------------+
//|                                                 IndAlligator.mqh |
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
//| Alligator standard indicator                                     |
//+------------------------------------------------------------------+
class CIndAlligator : public CIndicatorDE 
  {
private:

public:
   //--- Constructor
                     CIndAlligator(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                        CIndicatorDE(IND_ALLIGATOR,symbol,timeframe,
                                     INDICATOR_STATUS_STANDART,
                                     INDICATOR_GROUP_TREND,
                                     "Alligator",
                                     "Alligator("+symbol+","+TimeframeDescription(timeframe)+")",mql_param) {}
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
bool CIndAlligator::SupportProperty(ENUM_INDICATOR_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if the indicator supports the passed               |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CIndAlligator::SupportProperty(ENUM_INDICATOR_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Display a short description of indicator object in the journal   |
//+------------------------------------------------------------------+
void CIndAlligator::PrintShort(void)
  {
   string id=(this.ID()>WRONG_VALUE ? ", id #"+(string)this.ID()+"]" : "]");
   ::Print(GetStatusDescription()," ",this.Name()," ",this.Symbol()," ",TimeframeDescription(this.Timeframe())," [handle ",this.Handle(),id);
  }
//+------------------------------------------------------------------+
//| Display parameter description of indicator object in the journal |
//+------------------------------------------------------------------+
void CIndAlligator::PrintParameters(void)
  {
   ::Print(" --- ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_IND_PARAMETERS)," --- ");
   //--- jaw_period
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_JAW_PERIOD),": ",(string)m_mql_param[0].integer_value);
   //--- jaw_shift
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_JAW_SHIFT),": ",(string)m_mql_param[1].integer_value);
   //--- teeth_period
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_TEETH_PERIOD),": ",(string)m_mql_param[2].integer_value);
   //--- teeth_shift
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_TEETH_SHIFT),": ",(string)m_mql_param[3].integer_value);
   //--- lips_period
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_LIPS_PERIOD),": ",(string)m_mql_param[4].integer_value);
   //--- lips_shift
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_LIPS_SHIFT),": ",(string)m_mql_param[5].integer_value);
   //--- ma_method
   ::Print(" - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_MA_METHOD),": ",AveragingMethodDescription((ENUM_MA_METHOD)m_mql_param[6].integer_value));
   //--- applied_price
   ::Print(
           " - ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_APPLIED_PRICE),": ",
           (m_mql_param[7].integer_value<10 ? AppliedPriceDescription((ENUM_APPLIED_PRICE)m_mql_param[7].integer_value) : (string)m_mql_param[7].integer_value)
          );
  }
//+------------------------------------------------------------------+
