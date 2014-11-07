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
using System.Diagnostics;

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

            CMSCache cache = new CMSCache();
            cache.BuildCache();

            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();

            Jobs.ProcessServers(cache.ServerCache, cache.InstanceCache);
            
            stopWatch.Stop();
            TimeSpan ts = stopWatch.Elapsed;
            string elaspedTime = String.Format("{0:00}:{1:00}:{2:00}.{3:00}",ts.Hours,ts.Minutes,ts.Seconds,ts.Milliseconds/10);


            Console.WriteLine("Duration " + elaspedTime);
            Console.ReadLine();
 
        }

    }
}
