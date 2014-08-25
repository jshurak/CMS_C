using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.ServiceProcess;

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
        private string serverName;
        private string SQLService;
        private string SSASService;
        private string SSRSService;
        private string AgentService;
        private List<string> services;
        

        public Instance(string InstanceName)
        {
           instanceName = InstanceName;
           serverName = instanceName;
           SQLService = "MSSQLSERVER";
           SSASService = "MSSQLServerOLAPService";
           SSRSService = "ReportServer";
           AgentService = "SQLSERVERAGENT";
           if (instanceName.Contains("\\"))
           {
               string stub = instanceName.Substring(instanceName.IndexOf("\\") + 1);
               serverName = instanceName.Substring(0, instanceName.Length - (stub.Length + 1));
               SQLService = "MSSQL$" + stub;
               SSASService = "MSOLAP$" + stub;
               SSRSService = "ReportServer$" + stub;
               AgentService = "SQLAgent$" + stub;
           }
           services = new List<string>();
           services.Add(SQLService);
           services.Add(AgentService);
           services.Add(SSASService);
           services.Add(SSRSService);
        }
        public Instance(string InstanceName,bool SSAS,bool SSRS)
        {
            instanceName = InstanceName;
            serverName = instanceName;
            SQLService = "MSSQLSERVER";
            SSASService = "MSSQLServerOLAPService";
            SSRSService = "ReportServer";
            AgentService = "SQLSERVERAGENT";
            if (instanceName.Contains("\\"))
            {
                string stub = instanceName.Substring(instanceName.IndexOf("\\") + 1);
                serverName = instanceName.Substring(0, instanceName.Length - (stub.Length + 1));
                SQLService = "MSSQL$" + stub;
                SSASService = "MSOLAP$" + stub;
                SSRSService = "ReportServer$" + stub;
                AgentService = "SQLAgent$" + stub;
            }
            services = new List<string>();
            services.Add(SQLService);
            services.Add(AgentService);
            if (SSAS)
            {
                services.Add(SSASService);
            }
            if(SSRS)
            {
                services.Add(SSRSService);
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
            foreach(string service in services)
            {
                try
                {
                ServiceController sc = new ServiceController(service,serverName);
                Console.WriteLine(service + " on " + serverName + " status is " + sc.Status);
                }
                catch (Exception e)
                {
                    
                    Console.WriteLine(e.ToString());
                }
            }
        }
    }
}
