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
            Instance instance = new Instance("RDGPRSQLC06\\PRS0802",68,56);
            instance.GatherInstance();
            //InstanceJobs.ProcessInstances();
        }
        
    }
}
