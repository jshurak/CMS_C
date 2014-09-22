using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CMS_C
{
    public struct Database
    {
        private string _databaseName;
        private int _databaseID;
        private int _instanceID;
        private string _guid;

        public string DatabaseName
        { 
            get
            {
                return _databaseName;
            }
        }
        public int DatabaseID 
        { 
            get
            {
                return _databaseID;
            }
        }
        public int InstanceID 
        { 
            get
            {
                return _instanceID;
            }
        }
        public string DatabaseGUID 
        {
            get 
            {
                return _guid;
            }
        
        }

        public Database(int DatabaseID,int InstanceID,string Name,string GUID)
        {
            _databaseID = DatabaseID;
            _instanceID = InstanceID;
            _databaseName = Name;
            _guid = GUID;
        }

    }
}
