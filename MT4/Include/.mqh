//+------------------------------------------------------------------+
//|                                                     pipValue.mqh |
//|                                        Copyright 2021 NOEL M NGUEMECHIEU |
//|                                              
//+-----------------------------------------------------------------



//+---------------------------------------------------------------------------------------------+
//| dpipPos function - Return the pip position of a symbol                                      |
//+---------------------------------------------------------------------------------------------+
double dpipPos(string sSymbol) {

   double dpipPosition;

   //--- If this is a Forex Market return Characteristics in number of pips
   if(MarketInfo(sSymbol,MODE_PROFITCALCMODE)==0) {

      if (MarketInfo(sSymbol,MODE_DIGITS)==1 || MarketInfo(sSymbol,MODE_DIGITS)==3 || MarketInfo(sSymbol,MODE_DIGITS)==5)
         dpipPosition = MarketInfo(sSymbol,MODE_POINT)*10;
      else
         dpipPosition = MarketInfo(sSymbol,MODE_POINT);

   //--- If this is not a Forex Market, then return 1 to calculate in terms of amount of money
   } else {

      dpipPosition=1;

   }

   return dpipPosition;

}


//+---------------------------------------------------------------------------------------------+
//| dNbPips function - Return the number of pips between dPrice1 and dPrice2                    |
//+---------------------------------------------------------------------------------------------+
double dNbPips(string sSymbol, double dPrice1, double dPrice2) {
   
   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

	//--- Return the total number of pips risked
	return NormalizeDouble(MathAbs((dPrice1-dPrice2)/dpipPosition),5);

}


//+---------------------------------------------------------------------------------------------+
//| dValuePips function - Return the value of pips between dPrice1 and dPrice2 W.R.T volume     |
//+---------------------------------------------------------------------------------------------+
double dValuePips(string sSymbol, double dPrice1, double dPrice2, double dVolume) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Get the number of pips between dPrice1 and dPrice2
	double dNbPips = dNbPips(sSymbol, dPrice1, dPrice2);

   //--- Get the value of 1 pip in currency for 0.01 volume
   double dPipValue = MarketInfo(sSymbol,MODE_TICKVALUE)*dpipPosition/MarketInfo(sSymbol,MODE_TICKSIZE);

	//--- Return the value of pips between dPrice1 and dPrice2 W.R.T volume 
	return NormalizeDouble(dNbPips*dPipValue*dVolume,2);

}

//+---------------------------------------------------------------------------------------------+
//| dPriceSL function - Return the price of SL based on number of pips                          |
//+---------------------------------------------------------------------------------------------+
double dPriceSL(string sSymbol, double dPrice, int iTradeType, double dnbPips) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Type of the order
   int iType = 1;
   
   //--- If order type is Buy, Buy Limit or Buy Stop
   if (iTradeType==0 || iTradeType==2 || iTradeType==4)
      iType = -1;
   //--- If order type is Sell, Sell Limit or Sell Stop
   else if (iTradeType==1 || iTradeType==3 || iTradeType==5)
      iType = 1;
  
	// Return the price of StopLoss
	return NormalizeDouble(dPrice+(iType)*dnbPips*dpipPosition,5);

}


//+---------------------------------------------------------------------------------------------+
//| dPriceTP function - Return the price of TP based on number of pips                          |
//+---------------------------------------------------------------------------------------------+
double dPriceTP(string sSymbol, double dPrice, int iTradeType, double dnbPips) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Type of the order
   int iType = 1;
   
   //--- If order type is Buy, Buy Limit or Buy Stop
   if (iTradeType==0 || iTradeType==2 || iTradeType==4)
      iType = 1;
   //--- If order type is Sell, Sell Limit or Sell Stop
   else if (iTradeType==1 || iTradeType==3 || iTradeType==5)
      iType = -1;
  
	// Return the price of StopLoss
	return NormalizeDouble(dPrice+(iType)*dnbPips*dpipPosition,5);

}


//+---------------------------------------------------------------------------------------------+
//| dPercentSL function - Return the price of SL based on percentage                            |
//+---------------------------------------------------------------------------------------------+
double dPercentSL (string sSymbol, double dPrice, int iTradeType, double dVol, double dPercent) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Get the value of 1 pip in currency for 0.01 volume
   double dPipValue = MarketInfo(sSymbol,MODE_TICKVALUE)*dpipPosition/MarketInfo(sSymbol,MODE_TICKSIZE);

   // Convert $ risk to amount of money
   double dAmtPerPercentRisk = AccountInfoDouble(ACCOUNT_BALANCE)*dPercent/100;
   
   // AMOUNT OF dPercent IN NUMBER OF PIPS
	double ndNbPips = dAmtPerPercentRisk/(dPipValue*dVol);

   //--- If order type is Buy, Buy Limit or Buy Stop
   if (iTradeType==0 || iTradeType==2 || iTradeType==4)
      return dPrice-ndNbPips*dpipPosition;
   //--- If order type is Sell, Sell Limit or Sell Stop
   else if (iTradeType==1 || iTradeType==3 || iTradeType==5)
      return dPrice+ndNbPips*dpipPosition;
   
   return (false);
   
}


//+---------------------------------------------------------------------------------------------+
//| dPercentTP function - Return the price of TP based on percentage                            |
//+---------------------------------------------------------------------------------------------+
double dPercentTP(string sSymbol, double dPrice, int iTradeType, double dVol, double dPercent) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Get the value of 1 pip in currency for 0.01 volume
   double dPipValue = MarketInfo(sSymbol,MODE_TICKVALUE)*dpipPosition/MarketInfo(sSymbol,MODE_TICKSIZE);

   // Convert $ risk to amount of money
   double dAmtPerPercentRisk = AccountInfoDouble(ACCOUNT_BALANCE)*dPercent/100;

   // AMOUNT OF dPercent IN NUMBER OF PIPS
	double ndNbPips = dAmtPerPercentRisk/(dPipValue*dVol);

   //--- If order type is Buy, Buy Limit or Buy Stop
   if (iTradeType==0 || iTradeType==2 || iTradeType==4)
      return dPrice+ndNbPips*dpipPosition;
   //--- If order type is Sell, Sell Limit or Sell Stop
   else if (iTradeType==1 || iTradeType==3 || iTradeType==5)
      return dPrice-ndNbPips*dpipPosition;

   return (false);

}


//+---------------------------------------------------------------------------------------------+
//| dPercentVol function - Return the volume of the trade based on Price of SL and % risk       |
//+---------------------------------------------------------------------------------------------+
double dPercentVol (string sSymbol, double dPrice, double dPriceSL, double dPercent) {

   //--- Get the position of the pip of it is a Forex Market; Otherwise dpipPosition=1 to calculate in terms of amount of money
   double dpipPosition = dpipPos(sSymbol);

   //--- Get the number of pips between dPrice1 and dPrice2
	double dNumberPips = dNbPips(sSymbol, dPrice, dPriceSL);

   //--- Get the value of 1 pip in currency for 0.01 volume
   double dPipValue = MarketInfo(sSymbol,MODE_TICKVALUE)*dpipPosition/MarketInfo(sSymbol,MODE_TICKSIZE);

   // Convert $ risk to amount of money
   double dAmtPerPercentRisk = AccountInfoDouble(ACCOUNT_BALANCE)*dPercent/100;
   
   // Return the volume of the trade based on Price of SL and % risk
   return dAmtPerPercentRisk/(dNumberPips*dPipValue); 
   
}