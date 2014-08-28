using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CMS_C
{
    public class ServiceValue
    {
        public string serviceName;
        public string status;
        private int _exists;
        public int Exists 
        { get
            {
                return _exists;
            }
          set
            {
                if(value >= 0 && value <= 1)
                {
                    _exists = value;
                }
            }
        }
        
        public ServiceValue(string ServiceName,int Exists,string Status)
        {
            serviceName = ServiceName;
            _exists = Exists;
            status = Status;
        }
    }
}
