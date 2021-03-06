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
input double candleStickPatternBidAmount;
input double candleStickPatternTP;
input double candleStickPatternBidSL;

#include<Trade\Trade.mqh>
#include<MC_CandleStick.mqh>
#include<candlesticktype.mqh>

CTrade trade;

#property indicator_chart_window

//--- plot 1
#property indicator_label1  ""
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_buffers 5
#property indicator_plots   1

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
 
void OnTick()
  {
//---
   
   //Print("Account Company:",ACCOUNT_COMPANY);
   
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID),_Digits);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   //Print("Account balance = ",balance);
   
   MqlRates priceData[]; //create a price array
   
   //sort the array from the current candle downwards
   ArraySetAsSeries(priceData, true);
   
   //copy candle prices for 5 candles into array
   CopyRates(_Symbol, _Period, 0,6, priceData);
   
   //Candle Counter
   //static int candleCounter;
   bool isCandleClose=false;
   
   //create Datetime variable for the last time stamp
   static datetime timeStampLastCheck;
   static datetime timeStamp2CandlesAgo;
   static CANDLE_STRUCTURE cas_static;
   
   //create Datetime variable for current candle
   datetime timeStampCurrentCandle;
   
   //Read time stamp for current candle in array
   timeStampCurrentCandle=priceData[0].time;
   timeStamp2CandlesAgo=priceData[1].time;
   
   
   CANDLE_STRUCTURE cas;
   
   //EMA Based Trading
   
   static int buyCandleCounter;
   
   int ema8 = iMA(_Symbol, _Period, 8, 0, MODE_EMA, PRICE_CLOSE);
   int ema21 = iMA(_Symbol, _Period, 21, 0, MODE_EMA, PRICE_CLOSE);
   
   //Arrays to store EMAs
   double ema8Array[], ema21Array[];
   
   
   //Sorting EMAs fot the current candle downwards 
   ArraySetAsSeries(ema8Array, true);
   ArraySetAsSeries(ema21Array, true);
   
   //Defined EMA8, one line, current candle, 5 candles, store result
   CopyBuffer(ema8,0,0,5,ema8Array);
   
   //Defined EMA21, one line, current candle, 5 candles, store result
   CopyBuffer(ema21,0,0,5,ema21Array);
   
   //Print(priceData[1].close);
   
   if(ema8Array[0] > ema21Array[0])
   {
      //Print("EMA 8 > EMA21");
      
      if(
      (ema8Array[0] >= priceData[1].close) 
      && 
      (priceData[1].close < ema21Array[0]))
      {
        //Print("Chance To Buy"); 
        
        double closePrices[5];
        
        closePrices[0]=priceData[1].close;
        closePrices[1]=priceData[2].close;
        closePrices[2]=priceData[3].close;
        closePrices[3]=priceData[4].close;
        closePrices[4]=priceData[5].close;
        //Counting Buy Orders
        int
         OpenBuyOrders=0,
         OpenBuyPositions=0;
         
         //Print("Buy Candle Counter");
         //Print(buyCandleCounter);
         //Count Pending Stop Orders
         
         for(int i=0;i < OrdersTotal();i++)
           {
              ulong ticket=OrderGetTicket(i);
              
              if(OrderGetString(ORDER_COMMENT) == "EMA Buy Order")
              {
               OpenBuyOrders++;
               
               buyCandleCounter++;
               
               Print("Buy Order Opened");
               
               Print("Candle Count:");
               Print(buyCandleCounter);
               
               if(buyCandleCounter == 10)
               {
                  trade.OrderDelete(ticket);
                  buyCandleCounter =0;
               }
               
               
              }
               
              
            
           }
           
            for(int j=0;j < PositionsTotal();j++)
           {
              ulong ticketp=PositionGetTicket(j);
              
              if( PositionGetString(POSITION_COMMENT) == "EMA Buy Order")
              {
               OpenBuyPositions++;
                             
               
               
              }
               
              
            
           }
            
         
        
        if((OpenBuyPositions == 0) && (OpenBuyOrders == 0))
        {
         int maxValue=ArrayMaximum(closePrices,0,WHOLE_ARRAY);
         //Print("Close Price:");
         //Print(priceData[5].close); 
        
         //Print("ASK Price");
         //Print(ask);
         //Print("STOPS LEVEL:");
         
         double buyStop= NormalizeDouble(closePrices[maxValue],_Digits) ;//+0.00003;
         
         Print(buyStop);//NormalizeDouble(SYMBOL_TRADE_STOPS_LEVEL,_Digits)); 
         
         
         
         ////Print("Buy/Ask Difference:");
         double difference= buyStop-ask;
         double stopLevelInDouble=SYMBOL_TRADE_STOPS_LEVEL;
         //Print(difference); 
         //Print(stopLevelInDouble/100000);
         //Print((_Digits*10));
         
         if( difference <= stopLevelInDouble/100000)
         {
            buyStop=buyStop+(stopLevelInDouble/100000)+0.00003;
         }
         double stopLoss=priceData[1].close-0.00003;
         
         double takeProfit=buyStop+0.00100;//(buyStop-stopLoss) ; //Recheck 
         //Print("Buy Stop:");
         //Print(buyStop);
         //Print("Buying!!!");
         trade.BuyStop(1.00,buyStop,_Symbol,stopLoss,takeProfit,ORDER_TIME_GTC,0,"EMA Buy Order");
        }
      }
      
   }
   //When EMA8<EMA21
   if(ema8Array[0] < ema21Array[0])
   {
      //Print("EMA 8 < EMA21");
      if(
      (priceData[1].close >= ema8Array[0]) 
      && 
      (priceData[1].close < ema21Array[0]))
      {
        //Print("Chance To Sell"); 
        
        double closePricesSell[5];
        
        closePricesSell[0]=priceData[1].low;
        closePricesSell[1]=priceData[2].low;
        closePricesSell[2]=priceData[3].low;
        closePricesSell[3]=priceData[4].low;
        closePricesSell[4]=priceData[5].low;
        
        //Print("Price Datas");
        //Print(closePricesSell[0]);
        //Print(closePricesSell[1]);
        //Print(closePricesSell[2]);
        //Print(closePricesSell[3]);
        //Counting Buy Orders
        int
         OpenSellOrders=0,
         OpenSellPositions=0;
          
         //Count Pending Stop Orders
         
         for(int ii=0;ii < OrdersTotal();ii++)
           {
              ulong ticketb=OrderGetTicket(ii);
              
              if(OrderGetString(ORDER_COMMENT) == "EMA Sell Order")
              {
               OpenSellOrders++;
               
              }
               
              
            
           }
           
            for(int jj=0;jj < PositionsTotal();jj++)
           {
              ulong ticketbp=PositionGetTicket(jj);
              
              if( PositionGetString(POSITION_COMMENT) == "EMA Sell Order")
              {
               OpenSellPositions++;
               
              }
               
              
            
           }
        
         
        
        if((OpenSellPositions == 0) && (OpenSellOrders == 0))
        {
         int minValue=ArrayMinimum(closePricesSell,0,WHOLE_ARRAY);
         /*
         Print("Min Value");
         Print(minValue);
         Print("Bid Price:");
         Print(bid);
         Print("Min Value");
         Print(closePricesSell[minValue]);
         */
         double sellStop= NormalizeDouble(closePricesSell[minValue],_Digits) -0.00003;
         double stopLoss=priceData[1].close+0.00003;
         double takeProfit=sellStop+(sellStop-stopLoss); //Recheck
         //Print("Buy Stop:");
         //Print(buyStop);
         //Print("Buying!!!");
         //trade.SellStop(0.10,sellStop,_Symbol,stopLoss,takeProfit,ORDER_TIME_GTC,0,"EMA Sell Order");
        }
      }
      
      
   }
   
   
   if(timeStampCurrentCandle != timeStampLastCheck)
   {
      //Calls the candle indicate function to recognize candlestick patterns
      int candle_stick_indicator_points=candleStickIndicate(timeStampLastCheck,timeStamp2CandlesAgo,PERIOD_M15); 
      
      if(candle_stick_indicator_points != 0)
      {
         //Print("Candle Stick Indicator Points:", candle_stick_indicator_points);
         
         if(candle_stick_indicator_points == 1)
         {
            //trade.Buy(0.10,_Symbol,ask,(ask - 100 * _Point),(ask + 100 * _Point),"Initiating Buy");
         }
         if(candle_stick_indicator_points == -1)
         {
            //trade.Sell(0.10,_Symbol,ask,(ask - 100 * _Point),(ask + 100 * _Point),"Initiating Sell");
         }
         if(candle_stick_indicator_points == 2)
         {
            //trade.Buy(0.20,_Symbol,ask,(ask - 100 * _Point),(ask + 200 * _Point),"Initiating Buy");
         }
         if(candle_stick_indicator_points == -2)
         {
            //trade.Sell(0.20,_Symbol,ask,(ask - 100 * _Point),(ask + 200 * _Point),"Initiating Sell");
         }
      }     
      timeStampLastCheck=timeStampCurrentCandle;

          
      //add 1 to candleCounter
      //candleCounter=candleCounter+1;
      
      
      
     
     
   }
   
   //Chart Output
   
   //Comment("\nCounted candles since start: ", candleCounter, "\nDate: ", priceData[0].time);
   //Comment();
   
   //Create arrays for several prices
   
//   double myMovingAverageArray1[], myMovingAverageArray2[];
//   
//   //define the properties of the Moving Average 1
//   int movingAverageDefination1 = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
//   
//   //define the properties of the Moving Average 2
//   int movingAverageDefination2 = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
//   
//   //Sorting the price array 1 for the current candle downwards
//   ArraySetAsSeries(myMovingAverageArray1, true);
//   
//   //Sorting the price array 2 for the current candle downwards
//   ArraySetAsSeries(myMovingAverageArray2, true);
//   
//   //Defined MA1, one line, current candle, 3 candles, store result
//   CopyBuffer(movingAverageDefination1,0,0,3,myMovingAverageArray1);
//   
//   //Defined MA2, one line, current candle, 3 candles, store result
//   CopyBuffer(movingAverageDefination2,0,0,3,myMovingAverageArray2);
//   
//   //Check if the 20 candle EA is above the 50 candle EA
//   if( (myMovingAverageArray1[0] > myMovingAverageArray2[0]) 
//   && ( myMovingAverageArray1[1] < myMovingAverageArray2[1]) )
//   {
//      
//      //trade.Buy(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating Buy");
//      
//      //Print("BUY!!!!!");
//      
//      
//   }
//   
//   //Check if the 50 candle EA is above the 50 candle EA
//   if( (myMovingAverageArray1[0] < myMovingAverageArray2[0]) 
//   && ( myMovingAverageArray1[1] > myMovingAverageArray2[1]) )
//   {
//      //trade.Sell(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating SELL");
//      
//       //Print("SELL!!!!!");
//   }
   
   
   
   
  } //End of onTick()
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
