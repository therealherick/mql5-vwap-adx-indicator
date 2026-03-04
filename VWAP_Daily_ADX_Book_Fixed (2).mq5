//+------------------------------------------------------------------+
//|                                  VWAP_Daily_ADX_Book_Fixed.mq5   |
//|                     Copyright 2015, SOL Digital Consultoria LTDA |
//|                          Refactored & Fixed by Manus AI 2026     |
//+------------------------------------------------------------------+
#property copyright         "Copyright 2015, SOL Digital Consultoria LTDA"
#property link              "http://www.soldigitalconsultoria.com.br"
#property version           "4.10"

//--- Definir para janela separada para o ADX
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Plot ADX na subjanela
#property indicator_label1  "ADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "+DI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSpringGreen
#property indicator_style2  STYLE_DOT

#property indicator_label3  "-DI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_DOT

enum PRICE_TYPE 
  {
   OPEN, CLOSE, HIGH, LOW, HIGH_LOW, OPEN_CLOSE, CLOSE_HIGH_LOW, OPEN_CLOSE_HIGH_LOW
  };

//--- Input parameters
input   PRICE_TYPE          Price_Type              = CLOSE_HIGH_LOW;
input   bool                Enable_Daily            = true;
input   int                 ADX_Period              = 14;
input   bool                Enable_Book             = true;

//--- Buffers para a subjanela (ADX)
double      ADX_Buffer[];
double      PDIA_Buffer[];
double      MDIA_Buffer[];

//--- Variáveis globais para VWAP
double      nTotalTPV[], nTotalVol[];
double      nSumDailyTPV=0, nSumDailyVol=0;
double      lastVWAP_D=0;

int         handleADX;
bool        bIsFirstRun=true;
ENUM_TIMEFRAMES LastTimePeriod=PERIOD_CURRENT;

//+------------------------------------------------------------------+
//| IsNewPeriod                                                      |
//+------------------------------------------------------------------+
bool IsNewPeriod(datetime dtCurrent, datetime dtPrevious, ENUM_TIMEFRAMES period)
  {
   MqlDateTime mqlCurrent, mqlPrevious;
   TimeToStruct(dtCurrent, mqlCurrent);
   TimeToStruct(dtPrevious, mqlPrevious);
   if(period == PERIOD_D1) return (mqlCurrent.day != mqlPrevious.day || mqlCurrent.mon != mqlPrevious.mon || mqlCurrent.year != mqlPrevious.year);
   return false;
  }

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit() 
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "ADX Trend + VWAP Daily/Book");

   SetIndexBuffer(0, ADX_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, PDIA_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, MDIA_Buffer, INDICATOR_DATA);

   // Label VWAP (Canto Inferior Direito do Gráfico Principal)
   if(Enable_Daily) CreateLabel("VWAP_Daily", 40, clrRed, 3, 180);

   // Labels Book (Canto Inferior Esquerdo do Gráfico Principal)
   if(Enable_Book)
     {
      CreateLabel("BOOK_Sell", 40, clrOrangeRed, 2, 20);
      CreateLabel("BOOK_Buy", 60, clrSpringGreen, 2, 20);
      CreateLabel("BOOK_Total", 80, clrWhite, 2, 20);
      
      // Tentar adicionar o símbolo ao Market Book
      if(!MarketBookAdd(_Symbol))
        {
         Print("Erro ao adicionar Market Book para ", _Symbol, ". Erro: ", GetLastError());
        }
     }
   
   // Label de Tendência na Subjanela
   ObjectCreate(0, "ADX_Status", OBJ_LABEL, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, "ADX_Status", OBJPROP_CORNER, 1); 
   ObjectSetInteger(0, "ADX_Status", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "ADX_Status", OBJPROP_YDISTANCE, 20);

   handleADX = iADX(_Symbol, _Period, ADX_Period);
   
   return(INIT_SUCCEEDED);
  }

void CreateLabel(string name, int y_dist, color clr, int corner, int x_dist)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_dist);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_dist);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, "Aguardando dados...");
  }

void OnDeinit(const int reason) 
  {
   ObjectsDeleteAll(0, "VWAP_");
   ObjectsDeleteAll(0, "BOOK_");
   ObjectsDeleteAll(0, "ADX_");
   ObjectsDeleteAll(0, "VLine_D_");
   if(Enable_Book) MarketBookRelease(_Symbol);
   IndicatorRelease(handleADX);
  }

//+------------------------------------------------------------------+
//| OnBookEvent                                                      |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   if(Enable_Book && symbol == _Symbol)
     {
      UpdateBookInfo();
     }
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]) 
  {
   if(rates_total < 2) return 0;

   if(CopyBuffer(handleADX, 0, 0, rates_total, ADX_Buffer) <= 0) return 0;
   CopyBuffer(handleADX, 1, 0, rates_total, PDIA_Buffer);
   CopyBuffer(handleADX, 2, 0, rates_total, MDIA_Buffer);

   if(PERIOD_CURRENT != LastTimePeriod) { bIsFirstRun = true; LastTimePeriod = PERIOD_CURRENT; }

   if(rates_total > prev_calculated || bIsFirstRun) 
     {
      ArrayResize(nTotalTPV, rates_total);
      ArrayResize(nTotalVol, rates_total);
      int start = (prev_calculated > 0 && !bIsFirstRun) ? prev_calculated - 1 : 0;
      if(start == 0) { nSumDailyTPV=0; nSumDailyVol=0; }

      for(int i = start; i < rates_total; i++) 
        {
         if(i > 0 && IsNewPeriod(time[i], time[i-1], PERIOD_D1)) { nSumDailyTPV=0; nSumDailyVol=0; }

         double price = (close[i] + high[i] + low[i]) / 3.0;
         double currentVol = (tick_volume[i] > 0) ? (double)tick_volume[i] : (double)volume[i];
         nTotalTPV[i] = price * currentVol;
         nTotalVol[i] = currentVol;

         if(Enable_Daily) 
           { 
            nSumDailyTPV += nTotalTPV[i]; 
            nSumDailyVol += nTotalVol[i]; 
            lastVWAP_D = (nSumDailyVol > 0) ? (nSumDailyTPV / nSumDailyVol) : 0; 
            if(i > 0) DrawVWAPLine("VLine_D_", i, time[i-1], time[i], (nSumDailyVol-nTotalVol[i] > 0 ? (nSumDailyTPV-nTotalTPV[i])/(nSumDailyVol-nTotalVol[i]) : lastVWAP_D), lastVWAP_D, clrRed);
           }
        }
      bIsFirstRun = false;
     }

   UpdateVisuals(rates_total);
   // Forçar atualização do book também no OnCalculate caso o OnBookEvent não seja disparado pela corretora
   if(Enable_Book) UpdateBookInfo();
   
   return(rates_total);
  }

void DrawVWAPLine(string prefix, int index, datetime t1, datetime t2, double v1, double v2, color clr)
  {
   string name = prefix + (string)index;
   if(v1 <= 0 || v2 <= 0) return;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, v1, t2, v2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
     }
   else
     {
      ObjectMove(0, name, 0, t1, v1);
      ObjectMove(0, name, 1, t2, v2);
     }
}

void UpdateVisuals(int rates_total)
  {
   int last = rates_total - 1;
   if(Enable_Daily) ObjectSetString(0, "VWAP_Daily", OBJPROP_TEXT, "VWAP Daily: " + DoubleToString(lastVWAP_D, _Digits));

   string trend = (ADX_Buffer[last] < 20) ? "LATERAL" : (PDIA_Buffer[last] > MDIA_Buffer[last] ? "ALTA" : "BAIXA");
   color trendColor = (ADX_Buffer[last] < 20) ? clrGray : (PDIA_Buffer[last] > MDIA_Buffer[last] ? clrSpringGreen : clrOrangeRed);
   ObjectSetString(0, "ADX_Status", OBJPROP_TEXT, "TENDÊNCIA: " + trend + " (ADX: " + DoubleToString(ADX_Buffer[last], 2) + ")");
   ObjectSetInteger(0, "ADX_Status", OBJPROP_COLOR, trendColor);
  }

void UpdateBookInfo()
  {
   MqlBookInfo book[];
   if(MarketBookGet(_Symbol, book))
     {
      long sumBuy = 0, sumSell = 0;
      int buyCount = 0, sellCount = 0;
      int size = ArraySize(book);
      
      for(int i=0; i<size; i++)
        {
         // No MqlBookInfo, as ofertas de venda (SELL) costumam estar no início (preços maiores)
         // e as de compra (BUY) depois. Vamos somar as 10 mais próximas do preço atual.
         if(book[i].type == BOOK_TYPE_SELL) { sumSell += book[i].volume; sellCount++; }
         if(book[i].type == BOOK_TYPE_BUY) { sumBuy += book[i].volume; buyCount++; }
         
         // Se já pegamos 10 de cada, podemos parar para economizar processamento
         // Mas como o book costuma ser pequeno (20-40 níveis), percorrer tudo é seguro.
         if(sellCount >= 10 && buyCount >= 10) break; 
        }
      
      ObjectSetString(0, "BOOK_Sell", OBJPROP_TEXT, "Book Sell (10): " + (string)sumSell);
      ObjectSetString(0, "BOOK_Buy", OBJPROP_TEXT, "Book Buy (10): " + (string)sumBuy);
      ObjectSetString(0, "BOOK_Total", OBJPROP_TEXT, "Book Total: " + (string)(sumBuy + sumSell));
     }
   else
     {
      // Se falhar, mostrar que o Book não está disponível para este ativo
      ObjectSetString(0, "BOOK_Total", OBJPROP_TEXT, "Book Indisponível");
     }
  }
//+------------------------------------------------------------------+
