//+------------------------------------------------------------------+
//|                                                   EasyAccess.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Select.mqh"
#include "..\Engine.mqh"
//+------------------------------------------------------------------+
//| Class of a simplified access to collection properties            |
//+------------------------------------------------------------------+
class CEasyAccess
  {
private:

public:
   CHistoryCollection  *History;
   CMarketCollection   *Market;
   CAccountsCollection *Account;
   CSymbolsCollection  *Symbol;
   void              Test(void);
//--- Constructor/destructor
                     CEasyAccess() {}
                    ~CEasyAccess() {}
//+------------------------------------------------------------------+
//| Get the lists                                                    |
//+------------------------------------------------------------------+

  };
//+------------------------------------------------------------------+
//| Test                                                             |
//+------------------------------------------------------------------+
void CEasyAccess::Test(void)
  {
   CArrayObj *history=History.GetList();
   CArrayObj *market=Market.GetList();
   CArrayObj *account=Account.GetList();
   CArrayObj *symbol=Symbol.GetList();
  }
//+------------------------------------------------------------------+
