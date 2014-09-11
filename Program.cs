using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.ServiceProcess;


namespace CMS_C
{
    class Program
    {
        static void Main(string[] args)
        {

            Jobs.ProcessServers();
            //Server server = new Server("KMHPSQLPA22");
            //server.GatherServer();
           


            //Instance instance = new Instance("PHLDVWSSQL002\\DVS1201", 8);
            //instance.GatherWaitStats();

            //InstanceJobs.ProcessWaitStats();
        }
    }
}
