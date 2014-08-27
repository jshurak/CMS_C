using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.ServiceProcess;
using System.Linq;

namespace CMS_C
{
    class Instance
    {
        public string instanceName { get; set; }
        public string edition { get; set; }
        public string version { get; set; }
        public bool isClustered { get; set; }
        public long maxMemory { get; set; }
        public int minMemory { get; set; }
        public string productLevel { get; set; }
        public bool pingStatus { get; set; }
        private string _serverName;
        private string _SQLService;
        private string _SSASService;
        private string _SSRSService;
        private string _AgentService;
        private List<string> _services;
        private Dictionary<string, string> _serviceNameDictionary;
        private Dictionary<string, int> _serviceResultDictionary;

        public Instance(string InstanceName)
        {
           instanceName = InstanceName;
           _serverName = instanceName;
           _SSASService = "MSSQLServerOLAPService";
           _SSRSService = "ReportServer";
           if (instanceName.Contains("\\"))
           {
               string stub = instanceName.Substring(instanceName.IndexOf("\\") + 1);
               _serverName = instanceName.Substring(0, instanceName.Length - (stub.Length + 1));
               _SSASService = "MSOLAP$" + stub;
               _SSRSService = "ReportServer$" + stub;
           }
           _serviceNameDictionary = new Dictionary<string,string>();
           _serviceNameDictionary.Add("SSAS", _SSASService);
           _serviceNameDictionary.Add("SSRS", _SSRSService);
           _serviceResultDictionary = new Dictionary<string, int>();
           _serviceResultDictionary.Add("SSAS", 0);
           _serviceResultDictionary.Add("SSRS", 0);
        }
        public Instance(string InstanceName,bool SSAS,bool SSRS)
        {
            instanceName = InstanceName;
            _serverName = instanceName;
            _SQLService = "MSSQLSERVER";
            _SSASService = "MSSQLServerOLAPService";
            _SSRSService = "ReportServer";
            _AgentService = "SQLSERVERAGENT";
            if (instanceName.Contains("\\"))
            {
                string stub = instanceName.Substring(instanceName.IndexOf("\\") + 1);
                _serverName = instanceName.Substring(0, instanceName.Length - (stub.Length + 1));
                _SQLService = "MSSQL$" + stub;
                _SSASService = "MSOLAP$" + stub;
                _SSRSService = "ReportServer$" + stub;
                _AgentService = "SQLAgent$" + stub;
            }
            _services = new List<string>();
            _services.Add(_SQLService);
            _services.Add(_AgentService);
            if (SSAS)
            {
                _services.Add(_SSASService);
            }
            if(SSRS)
            {
                _services.Add(_SSRSService);
            }
            
            
        }

        public bool TestConnection()
        {

            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = instanceName;
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 3;

            SqlConnection conn = new SqlConnection(connectionstring.ConnectionString);

            try
            {
                conn.Open();
                if(conn.State == ConnectionState.Open)
                {
                    conn.Close();
                    return true;
                }

            }
            catch (Exception)
            {
                return false;
                throw;
                
            }
            return false;
            
        }

        public void GatherInstance()
        {
            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = instanceName;
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 3;

            SqlConnection conn = new SqlConnection(connectionstring.ConnectionString);
            try
            {
                SqlDataReader myReader = null;
                SqlCommand myCommand = new SqlCommand(@"select @@SERVERNAME AS InstanceName,SERVERPROPERTY('Edition') AS Edition,SERVERPROPERTY('ProductVersion') AS Version,CAST(SERVERPROPERTY('isClustered') as BIT) AS isClustered ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                                                        ,[Min] as minMemory,CAST([Max] AS BIGINT) as maxMemory
                                                        FROM
                                                        (SELECT left(name,3) as name, value_in_use
                                                        FROM sys.configurations
                                                        where name like '%server memory%') as s
                                                        PIVOT
                                                        (
	                                                        max(value_in_use)
	                                                        FOR name in ([min],[max])
                                                        ) as output",conn);
                conn.Open();
                myReader = myCommand.ExecuteReader();
                while (myReader.Read())
                {
                    edition = myReader["Edition"].ToString();
                    version = myReader["Version"].ToString();
                    isClustered = (bool)myReader["isClustered"];
                    productLevel = myReader["ProductLevel"].ToString();
                    minMemory = (int)myReader["minMemory"];
                    maxMemory = (long)myReader["maxMemory"];
                }
                conn.Close();
                Console.WriteLine(instanceName);
                Console.WriteLine(edition);
                Console.WriteLine(version);
                Console.WriteLine(isClustered);
                Console.WriteLine(productLevel);
                Console.WriteLine(minMemory);
                Console.WriteLine(maxMemory);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }


        }
        public void CheckServices()
        {
            foreach(string service in _services)
            {
                try
                {
                ServiceController sc = new ServiceController(service,_serverName);
                Console.WriteLine(service + " on " + _serverName + " status is " + sc.Status);
                }
                catch (Exception e)
                {
                    
                    Console.WriteLine(e.ToString());
                }
            }
        }
        public void GatherServices()
        {
            foreach(KeyValuePair<string, string> service in _serviceNameDictionary)
            {
                try
                {
                    if(DoesServiceExist(service.Value, _serverName))
                    {
                        _serviceResultDictionary[service.Key] = 1;
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                }

            }
        }
        
        bool DoesServiceExist(string serviceName, string machineName)
        {
            ServiceController[] services = ServiceController.GetServices(machineName);
            var service = services.FirstOrDefault(s => s.ServiceName == serviceName);
            return service != null;
        }
    }
}
