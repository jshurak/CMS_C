using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Net.NetworkInformation;

namespace CMS_C
{
    class Server
    {
        public Server(string Name)
        {
            serverName = Name;
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
        

    }
}
