﻿using System;
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
            cache.BuildCache();

            foreach(AgentJob _aj in cache.AgentJobCache)
            {
                Console.WriteLine(_aj.InstanceID + " " + _aj.JobName + " " + _aj.JobGUID);
            }
        }
    }
}
