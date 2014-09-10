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
            InstanceJobs.ProcessDatabaseFiles();
        }
    }
}
