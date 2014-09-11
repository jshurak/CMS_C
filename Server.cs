using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Net.NetworkInformation;
using System.Net;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;

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
        public ulong totalMemory { get; set; }
        public string manufacturer { get; set; }
        public string model { get; set; }
        public string ipAddress { get; set; }
        public string operatingSystem { get; set; }
        public string bitLevel { get; set; }
        public DateTime dateInstalled { get; set; }
        public int numProcessors { get; set; }
        public UInt32 numCores { get; set; }
        public DateTime dateLastBoot { get; set; }
        public bool pingStatus { get; set; }
        public bool isVirtualServerName { get; set; }
        public UInt32 clockSpeed;
        private ManagementScope _scope;
        static string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
        SqlConnection repConn = new SqlConnection(repository);
        
        public void GatherServer()
        {
            try
            {
                IPAddress[] addresslist = Dns.GetHostAddresses(serverName);
                ManagementObjectCollection _osCollection = GatherServerInfo("SELECT * FROM Win32_OperatingSystem", _scope);
                ManagementObjectCollection _csCollection = GatherServerInfo("SELECT * FROM Win32_ComputerSystem", _scope);
                ManagementObjectCollection _cpuCollection = GatherServerInfo("SELECT * FROM Win32_processor", _scope);

                foreach(IPAddress ip in addresslist)
                {
                    ipAddress = ip.ToString();
                }
                foreach (ManagementObject _os in _osCollection)
                {
                    operatingSystem = _os["Caption"].ToString();
                    dateInstalled = ManagementDateTimeConverter.ToDateTime(_os["InstallDate"].ToString());
                    dateLastBoot = ManagementDateTimeConverter.ToDateTime(_os["LastBootUpTime"].ToString());
                    bitLevel = _os["OSArchitecture"].ToString().Substring(0, 2);
                }
                foreach (ManagementObject _cs in _csCollection)
                {
                    manufacturer = _cs["Manufacturer"].ToString();
                    model = _cs["Model"].ToString();
                    totalMemory = (ulong)_cs["TotalPhysicalMemory"];
                }

                numProcessors = _cpuCollection.Count;
                foreach (ManagementObject _cpu in _cpuCollection)
                {
                    numCores = (UInt32)_cpu["NumberOfCores"];
                    clockSpeed = (UInt32)_cpu["CurrentClockSpeed"];
                }

                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredServers_SetServer", repConn))
                {
                    
                    cmd.Parameters.Clear();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ServerName",SqlDbType.VarChar).Value = serverName;
                    cmd.Parameters.Add("@Manufacturer", SqlDbType.VarChar).Value = manufacturer;
                    cmd.Parameters.Add("@Model", SqlDbType.VarChar).Value = model;
                    cmd.Parameters.Add("@IPAddress", SqlDbType.VarChar).Value = ipAddress;
                    cmd.Parameters.Add("@OperatingSystem", SqlDbType.VarChar).Value = operatingSystem;
                    cmd.Parameters.Add("@BitLevel", SqlDbType.Char).Value = bitLevel;
                    cmd.Parameters.Add("@TotalMemory", SqlDbType.BigInt).Value = totalMemory;
                    cmd.Parameters.Add("@DateInstalled", SqlDbType.DateTime).Value = dateInstalled;
                    cmd.Parameters.Add("@DateLastBoot", SqlDbType.DateTime).Value = dateLastBoot;
                    cmd.Parameters.Add("@NumberOfProcessors", SqlDbType.TinyInt).Value = numProcessors;
                    cmd.Parameters.Add("@NumberOfProcessorCores", SqlDbType.TinyInt).Value = numCores;

                    repConn.Open();
                    cmd.ExecuteNonQuery();
                }

            }
            catch (Exception e)
            {
                EventLogger.LogEvent(e.ToString(), "Error");
            }
            finally
            {
                repConn.Close();
            }

        }

        private ManagementObjectCollection GatherServerInfo(string Query, ManagementScope Scope)
        {
            ManagementScope _scope = Scope;
            ObjectQuery _query = new ObjectQuery(Query);
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(_scope, _query);

            _scope.Connect();
            ManagementObjectCollection queryCollection = searcher.Get();

            return queryCollection;

        }
        
    }
}
