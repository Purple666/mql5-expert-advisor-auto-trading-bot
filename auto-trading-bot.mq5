//+------------------------------------------------------------------+
//|                                             auto-trading-bot.mq5 |
//|                           Copyright 2018-2019, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018-2019, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"
#property version   "1.00"
//--- input parameters
input double      default_stop_loss;
input double      default_pips;

#include<Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
  
  /*
  
  void OpenBuyOrder()
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_BUY;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = 50;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
   void OpenSellOrder(double Ask)
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_SELL;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = (_Point * 30) + Ask ;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
  */
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   //Create arrays for several prices
   
   double myMovingAverageArray1[], myMovingAverageArray2[];
   
   //define the properties of the Moving Average 1
   int movingAverageDefination1 = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //define the properties of the Moving Average 2
   int movingAverageDefination2 = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //Sorting the price array 1 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray1, true);
   
   //Sorting the price array 2 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray2, true);
   
   //Defined MA1, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination1,0,0,3,myMovingAverageArray1);
   
   //Defined MA2, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination2,0,0,3,myMovingAverageArray2);
   
   //Check if the 20 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] > myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] < myMovingAverageArray2[1]) )
   {
      
      trade.Buy(0.10,_Symbol,ask,0,(ask + 40 * _Point),"Initiating Buy");
      
      Print("BUY!!!!!");
      
      
   }
   
   //Check if the 50 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] < myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] > myMovingAverageArray2[1]) )
   {
      trade.Sell(0.10,_Symbol,ask,0,(ask + 40 * _Point),"Initiating Buy");
      
       Print("BUY!!!!!");
   }
   
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
