//+------------------------------------------------------------------+
//|                                                   test_mysql.mq5 |
//|                                         Copyright 2019, Decanium |
//|                           https://www.mql5.com/en/users/decanium |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Decanium"
#property link      "https://www.mql5.com/en/users/decanium"
#property version   "1.00"
#property script_show_inputs
//--- input parameters
input string   inp_server     = "127.0.0.1";          // MySQL server address
input uint     inp_port       = 3306;                 // TCP port
input string   inp_login      = "admin";              // Login
input string   inp_password   = "12345";              // Password
input string   inp_db         = "world";              // Database name

//--- Connect MySQL transaction class
#include  <MySQL\MySQLTransaction.mqh>
CMySQLTransaction mysqlt;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Configure MySQL transaction class
   mysqlt.Config(inp_server,inp_port,inp_login,inp_password);
//--- Make a query
   string q = "select `Name`,`SurfaceArea` "+
              "from `"+inp_db+"`.`country` "+
              "where `Continent`='Oceania' "+
              "order by `SurfaceArea` desc limit 10";
   if(mysqlt.Query(q)==true)
     {
      if(mysqlt.Responses()!=1)
         return;
      CMySQLResponse *r = mysqlt.Response();
      if(r==NULL)
         return;
      Print("Name: ","Surface Area");
      uint rows = r.Rows();
      for(uint i=0; i<rows; i++)
        {
         double area;
         if(r.Row(i).Double("SurfaceArea",area)==false)
            break;
         PrintFormat("%s: %.0f",r.Row(i)["Name"],area);
        }
     }
   else
      if(GetLastError()==(ERR_USER_ERROR_FIRST+MYSQL_ERR_SERVER_ERROR))
        {
         // in case of a server error
         Print("MySQL Server Error: ",mysqlt.GetServerError().code," (",mysqlt.GetServerError().message,")");
        }
      else
        {
         if(GetLastError()>=ERR_USER_ERROR_FIRST)
            Print("Transaction Error: ",EnumToString(ENUM_TRANSACTION_ERROR(GetLastError()-ERR_USER_ERROR_FIRST)));
         else
            Print("Error: ",GetLastError());
        }
  }
//+------------------------------------------------------------------+
