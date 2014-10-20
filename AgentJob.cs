using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CMS_C
{
    public struct AgentJob
    {
        
        private string _jobGUID;
        private int _instanceID;


        public string JobGUID
        {
            get
            {
                return _jobGUID;
            }
        }

        public int InstanceID
        {
            get
            {
                return _instanceID;
            }
        }

        public AgentJob(int InstanceID, string JobGUID)
        {
            _instanceID = InstanceID;
            _jobGUID = JobGUID;
        }

    }
}
