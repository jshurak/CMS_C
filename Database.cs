using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CMS_C
{
    class Database
    {
        private string _databaseName;
        private DateTime _creationDate;
        private int _instanceID;
        private int _serverID;
        private int _compatibilityLevel;
        private string _collation;
        private float _size;
        private float _dataSpaceUsage;
        private float _indexSpaceUsage;
        private float _spaceAvailable;
        private string _recoveryModel;
        private bool _autoClose;
        private bool _autoShrink;
        private bool _readOnly;
        private string _pageVerify;
        private string _owner;
        private string _status;
        private string _guid;
        private bool _deleted;

        public string Owner 
        { 
            get
            {
                return _owner;
            }
        }
        public DateTime CreationDate
        { 
            get
            {
                return _creationDate;
            }
        }
        public string DatabaseName  
        { 
            get
            {
                return _databaseName;
            }
        }
        public int ServerID 
        {
            get 
            {
                return _serverID;
            }
        }
        public int InstanceID
        {
            get
            {
                return _instanceID;
            }
        }

    }
}
