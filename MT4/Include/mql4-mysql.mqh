//+----------------------------------------------------------------------------+
//|                                                             mql4-mysql.mqh |
//+----------------------------------------------------------------------------+
//|                                                      Built by Sergey Lukin |
//|                                                    contact@sergeylukin.com |
//|                                                                            |
//| This libary is highly based on following:                                  |
//|                                                                            |
//| - MySQL wrapper by "russel": http://codebase.mql4.com/5040                 |
//| - MySQL wrapper modification by "vedroid": http://codebase.mql4.com/8122   |
//| - EAX Mysql: http://www.mql5.com/en/code/855                               |
//| - This thread: http://forum.mql4.com/60708 (Cheers to user "gchrmt4" for   |
//|   expanded explanations on how to deal with ANSI <-> UNICODE hell in MQL4  |
//|                                                                            |
//+----------------------------------------------------------------------------+
#property copyright "Unlicense"
#property link      "http://unlicense.org/"

#import "kernel32.dll"
int lstrlenA(int);
void RtlMoveMemory(uchar  &arr[],int,int);
int LocalFree(int); // May need to be changed depending on how the DLL allocates memory  
int LocalAlloc(int,int); // added by InfiniteLoop
#import

#import "msvcrt.dll"
// TODO extend/handle 32/64 bit codewise
int memcpy(char &Destination[],int Source,int Length);
int memcpy(char &Destination[],long Source,int Length);
int memcpy(int &dst,int src,int cnt);
int memcpy(long &dst,long src,int cnt);
int malloc(int size);
int memcpy(int &dst,int &src,int cnt);
#import

#import "libmysql.dll"

int     mysql_init(int dbConnectId);
int     mysql_errno(int dbConnectId);
int     mysql_error(int dbConnectId);
int     mysql_real_connect(int dbConnectId,uchar  &host[],uchar  &user[],uchar  &password[],uchar  &db[],int port,int socket,int clientflag);
int     mysql_real_query(int dbConnectId,uchar  &query[],int length);
int     mysql_query(int dbConnectId,uchar  &query[]);
void    mysql_close(int dbConnectId);
int     mysql_store_result(int dbConnectId);
int     mysql_use_result(int dbConnectId);
int     mysql_insert_id(int dbConnectId);

int     mysql_fetch_row(int resultStruct);
int     mysql_fetch_field(int resultStruct);
int     mysql_fetch_lengths(int resultStruct);
int     mysql_num_fields(int resultStruct);
int     mysql_num_rows(int resultStruct);
void    mysql_free_result(int resultStruct);
#import
//+----------------------------------------------------------------------------+
//| Connect to MySQL and write connection ID to the first argument             |
//| Probably not the most elegant way but it works well for simple purposes    |
//| and is flexible enough to allow multiple connections                       |
//+----------------------------------------------------------------------------+
bool init_MySQL(int dbConnectIdj, string &hosts,string &users,string &passl,string &dbNamel,int port,int &sockets,int clientk)
  {
   uchar hostChar[];
   StringToCharArray(hosts,hostChar);
   uchar userChar[];
   StringToCharArray(users,userChar);
   uchar passChar[];
   StringToCharArray(passl,passChar);
   uchar dbNameChar[];
   StringToCharArray(dbNamel,dbNameChar);
    dbConnectIdj=mysql_init(dbConnectIdj);

   if(dbConnectIdj==0)
     {
     Comment("init_MySQL: mysql_init failed. There was insufficient memory to allocate a new object");
    
      Print("init_MySQL: mysql_init failed. There was insufficient memory to allocate a new object");
      return (false);
     }
   int result=mysql_real_connect(dbConnectIdj,hostChar,userChar,passChar,dbNameChar,port,sockets,clientk);

   if(result!=dbConnectIdj)
     {
      int errno=mysql_errno(dbConnectIdj);
      string error=mql4_mysql_ansi2unicode(mysql_error(dbConnectIdj));

      Print("init_MySQL: mysql_errno: ",errno,"; mysql_error: ",error);
      return (false);
     }

   return (true);
  }
//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
void deinit_MySQL(int dbConnectIdh)
  {
   mysql_close(dbConnectIdh);
  }
//+----------------------------------------------------------------------------+
//| Check whether there was an error with last query                           |
//|                                                                            |
//| return (true): no error; (false): there was an error;                      |
//+----------------------------------------------------------------------------+
bool MySQL_NoError(int dbConnectIdk)
  {
   int errno=mysql_errno(dbConnectIdk);
   string error=mql4_mysql_ansi2unicode(mysql_error(dbConnectIdk));

   if(errno>0)
     {
      Print("MySQL_NoError: mysql_errno: ",errno,"; mysql_error: ",error);
      return (false);
     }
   return (true);
  }
//+----------------------------------------------------------------------------+
//| Simply run a query, perfect for actions like INSERTs, UPDATEs, DELETEs     |
//+----------------------------------------------------------------------------+
bool MySQL_Query(int dbConnectId1,string query)
  {
   uchar queryChar[];
   StringToCharArray(query,queryChar);

// Performs a statement pointed to by the null terminate string query against the database. Contrary to mysql_real_query(), mysql_query() is not binary safe.
   mysql_query(dbConnectId1,queryChar);

   if(MySQL_NoError(dbConnectId1))
      return (true);

   return (false);
  }
//+----------------------------------------------------------------------------+
//| Fetch row(s) in a 2-dimansional array                                      |
//|                                                                            |
//| return (-1): error; (0): 0 rows selected; (1+): some rows selected;        |
//+----------------------------------------------------------------------------+
int MySQL_FetchArray(int dbConnectIdl,string query,string &data[][])
  {
   if(!MySQL_Query(dbConnectIdl,query))
      return (-1);

// Returns a buffered resultset from the last executed query.
   int resultStruct=mysql_store_result(dbConnectIdl);

// if error then aborts 
   if(!MySQL_NoError(dbConnectIdl))
     {
      Print("mysqlFetchArray: resultStruct: ",resultStruct);
      mysql_free_result(resultStruct);
      return (-1);
     }

   int num_rows=mysql_num_rows(resultStruct);
   int num_fields=mysql_num_fields(resultStruct);

   char byte[];

// 0 rows selected exits function;
   if(num_rows==0)
     {
      mysql_free_result(resultStruct);
      return (0);
     }

   ArrayResize(data,num_rows);

   for(int i=0; i<num_rows; i++)
     {
      // Retrieves the next row of a result set.  
      int row_ptr=mysql_fetch_row(resultStruct);

      //The PHP mysql_fetch_lengths function is used to returns the length of each output in a result (in bytes).
      //Returns the lengths of the columns of the current row within a result set.
      int len_ptr=mysql_fetch_lengths(resultStruct);

      for(int j=0; j<num_fields; j++)
        {
         /* void * memcpy ( void * destination, const void * source, size_t num );         
            destination -> Pointer to the destination array where the content is to be copied, type-casted to a pointer of type void*.            
            source -> Pointer to the source of data to be copied, type-casted to a pointer of type const void*.            
            num -> Number of bytes to copy. size_t is an unsigned integral type.            
            Example:
            using memcpy to copy structure: 
            memcpy ( &person_copy, &person, sizeof(person) );
         */

         // If the function succeeds, the return value is a handle to the newly allocated memory object.
         // 0x0000 == LMEM_FIXED Allocates fixed memory. The return value is a pointer to the memory object.      
         int leng=LocalAlloc(0x0000,sizeof(int));
         int change_1=leng; // writes pointer to a local variable, so that LocalFree function can release memory correctly               

         memcpy(leng,len_ptr+j*sizeof(int),sizeof(int));

         ArrayResize(byte,leng+1);

         // The function initializes a numeric array by a preset value.
         ArrayInitialize(byte,0);

         int row_ptr_pos=LocalAlloc(0x0000,sizeof(int));;
         int change_2=row_ptr_pos; // writes pointer to a local variable, so that LocalFree function can release memory correctly  

         memcpy(row_ptr_pos,row_ptr+j*sizeof(int),sizeof(int));
         memcpy(byte,row_ptr_pos,leng);

         string s=CharArrayToString(byte);
         data[i][j]=s;

         // Frees the specified local memory object and invalidates its handle.         
         LocalFree(change_1);
         // LocalFree(leng);
         LocalFree(change_2);
         //LocalFree(row_ptr_pos);
        }
     }

// function to free the memory allocated for storing the results set
   mysql_free_result(resultStruct);

// free memory of dynamic array just in case if doesn't happen automaticly
   ArrayFree(byte);

   if(MySQL_NoError(dbConnectIdl))
      return (num_rows);
//return (1);

   return (-1);
  }
//+----------------------------------------------------------------------------+
//| Lovely function that helps us to get ANSI strings from DLLs to our UNICODE |
//| format                                                                     |
//| http://forum.mql4.com/60708                                                |
//+----------------------------------------------------------------------------+
string mql4_mysql_ansi2unicode(int ptrStringMemory)
  {
// Determines the length of the specified string (not including the terminating null character).
   int szString=lstrlenA(ptrStringMemory);

   uchar ucValue[];

   ArrayResize(ucValue,szString+1);

// The RtlMoveMemory routine copies the contents of a source memory block to a destination memory block, and supports overlapping source and destination memory blocks.
   RtlMoveMemory(ucValue,ptrStringMemory,szString+1);

   string str=CharArrayToString(ucValue);

// doesn't release memory, but manual release of memory isn't required for this variable, it should be done automaticly by MT4
   LocalFree(ptrStringMemory);

   return str;
  }
//+------------------------------------------------------------------+
