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

            Instance instance = new Instance("PHLSTWSSQL001");
            instance.GatherServices();
            instance.CheckServices();
        }
        
    }
}
