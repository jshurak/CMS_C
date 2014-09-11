using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Net.NetworkInformation;

namespace CMS_C
{
    class Server
    {
        public Server(string Name)
        {
            serverName = Name;       
            _scope = new ManagementScope("\\\\" + serverName + "\\root\\cimv2");
        }

        public string serverName { get; set; }
        public long totalMemory { get; set; }
        public string manufacturer { get; set; }
        public string model { get; set; }
        public string ipAddress { get; set; }
        public string operatingSystem { get; set; }
        public int bitLevel { get; set; }
        public DateTime dateInstalled { get; set; }
        public int numProcessors { get; set; }
        public int numCores { get; set; }
        public DateTime dateLastBoot { get; set; }
        public bool pingStatus { get; set; }
        public bool isVirtualServerName { get; set; }
        private ManagementScope _scope;
        
        
        public void GatherOSInfo()
        {
            
            ObjectQuery _query = new ObjectQuery("SELECT * FROM Win32_OperatingSystem");
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(_scope, _query);
            
            _scope.Connect();
            ManagementObjectCollection queryCollection = searcher.Get();
            
            foreach(ManagementObject _os in queryCollection)
            {
                Console.WriteLine("Computer Name : {0}",_os["csname"]);
                Console.WriteLine("Windows Directory : {0}",_os["WindowsDirectory"]);
                Console.WriteLine("Operating System: {0}", _os["Caption"]);
                Console.WriteLine("Version: {0}", _os["Version"]);
                Console.WriteLine("Manufacturer : {0}", _os["Manufacturer"]);
            }
            
        }

            
        
    }
}
