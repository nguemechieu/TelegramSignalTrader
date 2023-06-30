//+------------------------------------------------------------------+
//|                                                    urlencode.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string hex(int i)
  {
   static string h="0123456789ABCDEF";
   string ret="";
   int a = i % 16;
   int b = (i-a)/16;
   if(b>15)
      StringConcatenate(ret,ret,hex(b),StringSubstr(h,a,1));
   else
      StringConcatenate(ret,ret,StringSubstr(h,b,1),StringSubstr(h,a,1));
   return (ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string URLEncode(string toCode)
  {
   int max=StringLen(toCode);

   string RetStr="";
   for(int i=0; i<max; i++)
     {
      string c = StringSubstr(toCode,i,1);
      ushort asc = StringGetCharacter(c, 0);

      if((asc >= '0' && asc <= '9')
         || (asc >= 'a' && asc <= 'z')
         || (asc >= 'A' && asc <= 'Z')
         || (asc == '-')
         || (asc == '.')
         || (asc == '_')
         || (asc == '~'))
         StringAdd(RetStr,c);
      else
        {
         StringConcatenate(RetStr,RetStr,"%",hex(asc));
        }
     }
   return (RetStr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string arrayEncode(string &array[][2])
  {
   string ret="";
   string key,val;
   int l=ArrayRange(array,0);
   for(int i=0; i<l; i++)
     {
      key = URLEncode(array[i,0]);
      val = URLEncode(array[i,1]);
      StringConcatenate(ret,ret,key,"=",val);
      if(i+1<l)
         StringConcatenate(ret,ret,"&");
     }
   return (ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sortParam(string&arr[][2])
  {
   string k1, k2;
   string v1, v2;
   int n = ArrayRange(arr,0);

// bubble sort
   int i, j;
   for(i = 0; i < n-1; i++)
     {
      // Last i elements are already in place
      for(j = 0; j < n-i-1; j++)
        {
         int x = j+1;
         k1 = arr[j][0];
         k2 = arr[x][0];
         if(k1 > k2)
           {
            // swap values
            v1 = arr[j][1];
            v2 = arr[x][1];
            arr[j][1] = v2;
            arr[x][1] = v1;
            // swap keys
            arr[j][0] = k2;
            arr[x][0] = k1;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void addParam(string key,string val,string&array[][2])
  {
   int x=ArrayRange(array,0);
   if(ArrayResize(array,x+1)>-1)
     {
      array[x][0]=key;
      array[x][1]=val;
     }
  }
//+------------------------------------------------------------------+
