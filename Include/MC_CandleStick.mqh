//+------------------------------------------------------------------+
//|                                               MC_CandleStick.mqh |
//|                                Copyright 2018, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include<candlesticktype.mqh>
#include<Trade\Trade.mqh>

bool candleStickIndicate(datetime time_current_candle, datetime time_previous_candle, int period)
                {
                
                  //Print("Inside candleStickIndicate!");
                  
                  bool _forex=false;
                    
                    if(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_CALC_MODE)==(int)SYMBOL_CALC_MODE_FOREX) _forex=true;
                        
                    CANDLE_STRUCTURE cand1;
                    
                    RecognizeCandle(_Symbol,_Period,time_current_candle,period,cand1);
                    
                    // Inverted Hammer, the bullish model
                   if(cand1.trend==DOWN && // check direction of trend
                        cand1.type==CAND_INVERT_HAMMER) // the "Inverted Hammer" check
                       {
                        Print("Inverted Hammer (Bull) Inverted Hammer");
                        //DrawSignal(prefix+"Invert Hammer the bull model"+string(objcount++),cand1,InpColorBull,comment);
                   }
                   // Hanging Man, the bearish model
                  if(cand1.trend==UPPER && // check direction of trend
                     cand1.type==CAND_HAMMER) // the "Hammer" check
                    {
                     Print("Hanging Man (Bear) Hanging Man");
                     //DrawSignal(prefix+"Hanging Man the bear model"+string(objcount++),cand1,InpColorBear,comment);
                    }
                  //------      
                  // Hammer, the bullish model
                  if(cand1.trend==DOWN && // check direction of trend
                     cand1.type==CAND_HAMMER) // the "Hammer" check
                    {
                     Print("Hammer (Bull) Hammer");
                     //DrawSignal(prefix+"Hammer, the bull model"+string(objcount++),cand1,InpColorBull,comment);
                    }
                    
                  /* Check of patters with two candlesticks */
                  
                  CANDLE_STRUCTURE cand2;
                  cand2=cand1;  
                  RecognizeCandle(_Symbol,_Period,time_previous_candle,period,cand2);
                  
                  // Shooting Star, the bearish model
                  
                  if(cand1.trend==UPPER && cand2.trend==UPPER && // check direction of trend
                     cand2.type==CAND_INVERT_HAMMER) // the "Inverted Hammer" check
                    {
                     Print("Shooting Star (Bear) Shooting Star");
                     if(_forex)// if it's forex
                       {
                        if(cand1.close<=cand2.open) // close 1 is less than or equal to open 1
                          {
                           Print("Shooting Star the bear model");
                           //trade.Sell( candle_stick_bid ,_Symbol,ask,(ask - candle_stick_sl * _Point),(ask + candle_stick_tp * _Point),"Initiating Sell");
                          }
                       }
                     else
                       {
                        if(cand1.close<cand2.open && cand1.close<cand2.close) // 2 candlestick is cut off from 1
                          {
                           //trade.Sell( candle_stick_bid ,_Symbol,ask,(ask - candle_stick_sl * _Point),(ask + candle_stick_tp * _Point),"Initiating Sell");
                           Print("Shooting Star the bear model");
                          }
                       }
                    }
      // ------      
                  
    
                  
                  return(0);
                }

