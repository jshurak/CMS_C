using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;



namespace CMS_C
{
    class Program
    {
        static void Main(string[] args)
        {

            //InstanceJobs.ProcessInstances();
            CollectionLog log = new CollectionLog();
            long _ID = log.LogModule("TestLog");
            log.LogModule("TestLog",_ID);
        }
        
    }
}
