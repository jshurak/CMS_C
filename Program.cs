using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.ServiceProcess;
using log4net;

[assembly: log4net.Config.XmlConfigurator(Watch = true)]
namespace CMS_C
{
    class Program
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod
().DeclaringType);
        

        static void Main()
        {
            // Uncomment this to start the services
            //ServiceBase.Run(new Service()); 

            log.Debug("Application Starting");
            CMSCache cache = new CMSCache();
            cache.BuildInstanceCache();

            Jobs.ProcessInstances(cache);

        }

    }
}
