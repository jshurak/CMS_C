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
            Instance instance = new Instance("PHLDVWSSQL002\\DVS1201", 1, 1);
            instance.CheckServices();
            //InstanceJobs.CheckServices();
        }
        
    }
}
