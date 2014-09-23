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

        static void Main()
        {
            // Uncomment this to start the services
            //ServiceBase.Run(new Service()); 

            CMSCache cache = new CMSCache();
            cache.BuildDatabaseCache();

            Instance instance = new Instance("PHLDVWSSQL002\\DVS1201", 6,8);
            instance.CheckDeletedDatabases(cache.DatabaseCache);

            
        }
    }
}
