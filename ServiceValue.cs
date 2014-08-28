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
        public int exists;

        public ServiceValue(string ServiceName,int Exists)
        {
            serviceName = ServiceName;
            exists = Exists;
        }
    }
}
