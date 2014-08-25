using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace CMS_C
{
    class Program
    {
        static void Main(string[] args)
        {
            string RepositoryServer = ConfigurationManager.AppSettings["RepositoryServer"];
            string RepositoryDatabase = ConfigurationManager.AppSettings["RepositoryDatabase"];
            InstanceJobs.ProcessInstances();
        }
    }
}
