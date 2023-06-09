//+------------------------------------------------------------------+
//|                                                    EAX_mysql.mqh |
//|          Copyright 2012, Michael Schoen <michael@schoen-hahn.de> |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Michael Schoen"
#property version   "1.02"

/**
+------------------------------------------------------------------+
Version History
25/05/2012 MS | Fix on 64 bit
26/05/2012 MN | Alert Box for Error Handling of SQL added
01/06/2012 MN | Fix for inserting / updating difference
+------------------------------------------------------------------+
**/


#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayInt.mqh>


#import "libmysql.dll"
    int mysql_init(int mysql);
    int mysql_real_connect(int mysql, string& host, string& user, string& password,
                           string& DB,int port,int socket,int clientflag);    
    int mysql_real_query(int mysql,string& query,int lenght);                        
    int mysql_errno(int mysql);
    int mysql_fetch_row(int mysql);
    int mysql_fetch_field(int mysql);
    int mysql_fetch_lengths(int mysql);
    int mysql_store_result(int mysql);
    int mysql_field_count(int mysql);
    int mysql_num_rows(int mysql);
    int mysql_num_fields(int mysql);
    int mysql_free_result(int mysql);
    int mysql_insert_id(int mysql);
    
    void mysql_close(int mysql);                        
    string mysql_error(int mysql);
    int mysql_get_client_info();
    int mysql_get_host_info(int mysql);
    int mysql_get_host_info(int mysql);
    int mysql_get_server_info(int mysql);
    int mysql_character_set_name(int mysql);
    int mysql_stat(int mysql);      
#import "msvcrt.dll"
  // TODO extend/handle 32/64 bit codewise
  int memcpy(char &Destination[], int Source, int Length);
  int memcpy(char &Destination[], long Source, int Length);
  int memcpy(int &dst,  int src, int cnt);
  int memcpy(long &dst,  long src, int cnt);  
#import

static int __db_mysql_global;

class EAX_Mysql {

    private:

        class EAX_MysqlField : public CObject {
            public:
                 string key;
                 string value;
                 int modified;
                 EAX_MysqlField() { modified=0; };
        };
        
        class EAX_MysqlRow : public CObject {
           public:
               CArrayObj* fields;
               int changed;
               int updated;
               EAX_MysqlRow() { fields = new CArrayObj(); changed =0; updated = 0; };
               ~EAX_MysqlRow() { delete(fields); };
              
        };

        CArrayObj* m_rows;
        
        string hostname;
        string username;
        string password;
        string database;
        string tablename;            
        int results;        
        
        int db;
        void clear();
        string implode(string, CArrayString* pString);
        string escape(string);
        string get_primary_key(string);
        void error();
        void error(string sqlin);
        string ANSI2UNICODE(string);
        string UNICODE2ANSI(string);
        bool is64;
    public:        
        void EAX_Mysql();
        void ~EAX_Mysql();
        void connect(string hostname, string username, string password, string database, string table);
        int read_rows(string);
        string get(string, int);        
        void AddNew(string);
        void set(string, string);
        void select(string);
        int read(string);
        int write();
        
};

EAX_Mysql::EAX_Mysql() {    
  
    if(MQLInfoInteger(MQL_DLLS_ALLOWED)==0) {
        Alert("DLL calling not allowed. Allow and try again!");
    }
    
    m_rows = new CArrayObj();
    
    if (__db_mysql_global != 0) {
        this.db = __db_mysql_global;
    }
    
    is64 = TerminalInfoInteger(TERMINAL_X64);
}


int EAX_Mysql::read_rows(string strSQL) {
    
    string _strSQL = UNICODE2ANSI(strSQL);
    mysql_real_query(db, _strSQL, StringLen(strSQL));
    
    if (mysql_errno(db)) {
        this.error(strSQL);
    }
    
    this.clear();
  
    int result=mysql_store_result(db);
    int num_rows = 0;    

    if (result>0) {
        num_rows=mysql_num_rows(result);
        int num_fields=mysql_num_fields(result);    
        
        // prepare datastructure to receive memcopy values
        char byte[];
        
        // Datastructure to receive complete resultset        

        
        string fields[];
        ArrayResize(fields,num_fields);
        // iterate over all arrays
        for (int i=0; i < num_rows; i++) {            
        
            int row_ptr = mysql_fetch_row(result);
            int len_ptr = mysql_fetch_lengths(result);
            
            // Zeiger auf internes Strukture
            //CArrayObj* m_row = new CArrayObj();
            //m_rows[i].m_row;    
            EAX_MysqlRow* pRow = new EAX_MysqlRow();            
                      
            // Nun iteriere über alle Werte
                        
            for (int j=0; j< num_fields; j++) {
            
                if (i==0) {
                    int field_ptr = mysql_fetch_field(result);
                    int field_ptr_name=0;
                    memcpy(field_ptr_name, field_ptr, sizeof(int));
                    int field_ptr_len;
                    if (is64) {                    
                       memcpy(field_ptr_len,field_ptr + 8*sizeof(long),sizeof(int));                    
                    } else {
                       memcpy(field_ptr_len,field_ptr + 8*sizeof(int),sizeof(int));
                    }
                    ArrayResize(byte, field_ptr_len);
                    ArrayInitialize(byte, 0);
                    memcpy(byte,field_ptr_name, field_ptr_len);                    
                    fields[j] = ANSI2UNICODE(CharArrayToString(byte));
                }
            
                // get leng
                int leng;
                memcpy(leng, len_ptr + j*sizeof(int), sizeof(int));
                
                ArrayResize(byte,leng+1);
                ArrayInitialize(byte,0);
                // get row_ptr_pos

                if (is64) {
                   long row_ptr_pos;
                   memcpy(row_ptr_pos, row_ptr + j*sizeof(long), sizeof(long));
                   memcpy(byte, row_ptr_pos, leng);
                } else {
                   int row_ptr_pos;
                   memcpy(row_ptr_pos, row_ptr + j*sizeof(int), sizeof(int));
                   memcpy(byte, row_ptr_pos, leng);
                }
                
                string s = ANSI2UNICODE(CharArrayToString(byte));                              
                // Print ("Field: " + fields[j], " ~ String: " + s);
                
                EAX_MysqlField* pField = new EAX_MysqlField();
                pField.key = fields[j];
                pField.value = s;
                pField.modified = 0;              
                pRow.fields.Add(pField);
                pRow.updated = 1;
            }
            m_rows.Add(pRow);
            
                                      
        }
        mysql_free_result(result);
    }  
    return (int) num_rows;
}
    
void EAX_Mysql::error() {
     string s = mysql_error(db);
     Alert("Error: ",ANSI2UNICODE(s));
}

void EAX_Mysql::error(string sqlin) {
     string s = mysql_error(db);
     Alert("Error: ",ANSI2UNICODE(s));
     Alert("SQL Input: ",sqlin);
}

string EAX_Mysql::get(string strKey, int iValue) {

    
    if (m_rows.Total() >= iValue+1) {
       EAX_MysqlRow* pRow = m_rows.At(iValue);
       CArrayObj* pFields = pRow.fields;
    
       for (int i=0; i< pFields.Total(); i++) {
           EAX_MysqlField *pField = pFields.At(i);
           if (pField.key == strKey) {
               return pField.value;
           }        
       }
    }
    
    return "";      
}

void EAX_Mysql::clear() {

    // "complex" structures need memory cleaning    
    
    for (int i=0; i<m_rows.Total(); i++) {
         EAX_MysqlRow *pRow = m_rows.At(i);
         delete pRow;        
    }    
    m_rows.Clear();
    
}

void EAX_Mysql::AddNew(string strTable) {
    this.clear();
    this.tablename = strTable;        
}

string EAX_Mysql::implode(string parm, CArrayString* pString) {

   string ret = "";
   int iTotal = pString.Total();
   for (int i=0; i< pString.Total(); i++) {
      ret = ret + parm + escape(pString.At(i)) + parm;
      if (i < (iTotal-1)) {
         ret = ret + ", ";
      }    
   }
   return ret;
}

/*
*
*
*/
void EAX_Mysql::set(string strKey, string strValue) {

    EAX_MysqlRow* pRow;
    if (m_rows.Total()==0) {
       pRow = new EAX_MysqlRow();
       m_rows.Add(pRow);
    }
    
    pRow = m_rows.At(0);
    pRow.changed = 1;
    
    CArrayObj* pFields = pRow.fields;    
    for (int i=0; i< pFields.Total(); i++) {
        EAX_MysqlField *pField = pFields.At(i);
        if (pField.key == strKey) {
            pField.value = strValue;
            pField.modified = 1;            
            return;
        }        
    }
    
    EAX_MysqlField* pField = new EAX_MysqlField();
    pField.key = strKey;
    pField.value = strValue;
    pField.modified = 2;
    
    pRow.fields.Add(pField);
  
    return;
    
}

void EAX_Mysql::select(string tablename) {
   this.tablename = tablename;
}

string EAX_Mysql::escape(string strInput) {
    // Ensure to add slashes before texting into mysql
    StringReplace(strInput, "'","\'");
    return strInput;
}

string EAX_Mysql::get_primary_key(string strTable) {

   EAX_Mysql *__db_int = new EAX_Mysql();
   string strSQL = "SHOW KEYS FROM `"+strTable+"` WHERE Key_name='PRIMARY'";
   __db_int.read_rows(strSQL);
   string ret = __db_int.get("Column_name",0);
   delete __db_int;
  
   return ret;

}

int EAX_Mysql::write() {

    // Iterate over the current resultset
    for (int i=0; i< m_rows.Total(); i++) {
        EAX_MysqlRow* pRow = m_rows.At(i);
        
        // nothing to do, if row not modified        
        if (pRow.changed != 1) {
           continue;
        }

        CArrayObj* pFields = pRow.fields;
        
        if (pRow.updated == 1) {
            
            string strFields;
            string strValues;
            for (int k=0; k<pFields.Total(); k++) {
                EAX_MysqlField* pField = pFields.At(k);
                              
                if (pField.modified == 2) {
                    strFields = strFields + "`" + pField.key   + "`,";
                    strValues = strValues + "'" + escape(pField.value) + "',";
                }
            }
            strFields = StringSubstr(strFields,0,StringLen(strFields)-1);
            strValues = StringSubstr(strValues,0,StringLen(strValues)-1);
          
            string strSQL;
            strSQL  = "INSERT INTO `" + this.tablename + "`";
            strSQL += " ( "+ strFields + ")";
            strSQL += " VALUES (" + strValues + ");";
            string _strSQL = UNICODE2ANSI(strSQL);
            mysql_real_query(db, _strSQL, StringLen(strSQL));
  
            if (mysql_errno(db)) {
               this.error(strSQL);
            }
            //
            //return -1;
            //}  else {
            ///return mysql_insert_id(db);
        } else {
            string pk = this.get_primary_key(this.tablename);
            // Print ("Primary Key = " + pk);
            string strData = "";
            string strWhere = "";
            for (int k=0; k<pFields.Total(); k++) {                
                EAX_MysqlField* pField = pFields.At(k);
                
                if (pField.key == pk) {
                    strWhere = "`" + pk + "`='" + escape(pField.value) + "'";
                }
                
                if (pField.modified == 1) {
                    strData = strData + "`" + pField.key + "`='" + escape(pField.value)+"',";
                }                
            }
            strData = StringSubstr(strData,0,StringLen(strData)-1);
            string strSQL = "UPDATE `" + this.tablename + "` SET " + strData + " WHERE " + strWhere;
            string _strSQL = UNICODE2ANSI(strSQL);
            mysql_real_query(db, _strSQL, StringLen(strSQL));
            if (mysql_errno(db)) {
                this.error(strSQL);
            }
        }
    }
    return 0;
}

int EAX_Mysql::read(string strValue) {
    string pk = this.get_primary_key(this.tablename);
    string where = "`" + pk + "`='"+escape(strValue)+"'";
    string strSQL = "SELECT * FROM `" + this.tablename + "` WHERE " + where;    
    return read_rows(strSQL);
}

void EAX_Mysql::connect(string hostname, string username, string password, string database, string table) {

    if (__db_mysql_global == 0) {
        db=mysql_init(0);
    
        int port = 3306;
        string host=UNICODE2ANSI(hostname);
        string user=UNICODE2ANSI(username);
        string pass=UNICODE2ANSI(password);
        string DB=UNICODE2ANSI(database);
        int res=mysql_real_connect(db,host,user,pass,DB,port, NULL, 0);
    
        if (mysql_errno(db)) {
            this.error();
        }        
    }    
    __db_mysql_global = db;
}

string EAX_Mysql::ANSI2UNICODE(string s) {
    ushort mychar;
    long m,d;
    double mm,dd;
    string img;    
    string res="";
    if (StringLen(s)>0) {
       string g=" ";
       for (int i=0;i<StringLen(s);i++) {          
          string f="  ";          
          mychar=ushort(StringGetCharacter(s,i));
          mm=MathMod(mychar,256);
          img=DoubleToString(mm,0);
          m=StringToInteger(img);
          dd=(double) (mychar-m)/256;
          img=DoubleToString(dd,0);
          d=StringToInteger(img);
          if (m!=0) {
             StringSetCharacter(f,0,ushort(m));
             StringSetCharacter(f,1,ushort(d));
             StringConcatenate(res,res,f);
          } else {
            break;                      
          }
       }
   }
   return(res);
  }

string EAX_Mysql::UNICODE2ANSI(string s) {
   int leng,ipos;
   uchar m,d;
   ulong big;
   leng=StringLen(s);
   string unichar;
   string res="";
   if (leng!=0)
     {    
      unichar=" ";
      ipos=0;      
      while (ipos<leng)
        { //uchar typecasted because each double byte char is actually one byte
         m=uchar(StringGetCharacter(s,ipos));
         if (ipos+1<leng)
           d=uchar(StringGetCharacter(s,ipos+1));
         else
           d=0;
         big=d*256+m;                
         StringSetCharacter(unichar,0,ushort(big));        
         StringConcatenate(res,res,unichar);    
         ipos=ipos+2;
        }
     }
   return(res);
  }

EAX_Mysql::~EAX_Mysql() {
  
   this.clear();
   delete m_rows;
  
}

