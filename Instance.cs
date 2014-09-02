using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.ServiceProcess;
using System.Linq;
using System.Configuration;
using System.IO;
using System.Resources;
using System.Reflection;



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
        private ServiceValue ssasservice;
        private ServiceValue ssrsservice;
        private ServiceValue agentservice;
        private ServiceValue sqlservice;
        private Dictionary<string, ServiceValue> _serviceDictionary;
        private int _serverID;
        private int _instanceID;

        Assembly _assembly;
        StreamReader _textStreamReader;

        public Instance(string InstanceName, int InstanceID)
        {
            instanceName = InstanceName;
            _instanceID = InstanceID;
        }


        public Instance(string InstanceName, int ServerID, int InstanceID)
        {
            // This constructor is called only when the SSAS SSRS values are unknown.
            _serverID = ServerID;
            _instanceID = InstanceID;
            BuildServices(InstanceName);
            GatherServices();
        }

        private void BuildServices(string InstanceName)
        {
            instanceName = InstanceName;
            _serverName = instanceName;
            _SSASService = "MSSQLServerOLAPService";
            _SSRSService = "ReportServer";
            _AgentService = "SQLSERVERAGENT";
            _SQLService = "MSSQLSERVER";
            if (instanceName.Contains("\\"))
            {
                string stub = instanceName.Substring(instanceName.IndexOf("\\") + 1);
                _serverName = instanceName.Substring(0, instanceName.Length - (stub.Length + 1));
                _SSASService = "MSOLAP$" + stub;
                _SSRSService = "ReportServer$" + stub;
                _AgentService = "SQLAgent$" + stub;
                _SQLService = "MSSQL$" + stub;
            }
            ssasservice = new ServiceValue(_SSASService, 0, "Stopped", "");
            ssrsservice = new ServiceValue(_SSRSService, 0, "Stopped", "");
            agentservice = new ServiceValue(_AgentService, 1, "Running", "");
            sqlservice = new ServiceValue(_SQLService, 1, "Running", "");

            _serviceDictionary = new Dictionary<string, ServiceValue> { };
            _serviceDictionary.Add("SSAS", ssasservice);
            _serviceDictionary.Add("SSRS", ssrsservice);
            _serviceDictionary.Add("Agent", agentservice);
            _serviceDictionary.Add("MSSQL", sqlservice);

        }

        public Instance(string InstanceName, int ServerID, int InstanceID, bool SSAS, bool SSRS)
        {
            _serverID = ServerID;
            _instanceID = InstanceID;
            instanceName = InstanceName;
            BuildServices(instanceName);

            if (SSAS)
            {
                ssasservice.Exists = 1;
            }
            if (SSRS)
            {
                ssrsservice.Exists = 1;
            }


        }
        public bool TestConnection()
        {

            SqlConnection conn = BuildConnection();
            using (SqlCommand instanceCheckCmd = new SqlCommand("SELECT @@SERVERNAME", conn))
            {
                try
                {
                    conn.Open();
                    instanceCheckCmd.ExecuteScalar();
                    conn.Close();
                    return true;
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                    return false;

                }
            }
        }

        public void GatherInstance()
        {
            SqlConnection conn = BuildConnection();
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
                                                        ) as output", conn);
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
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                {
                    using (SqlCommand cmd = new SqlCommand("dbo.MonitoredInstances_SetInstance", repConn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                        cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                        cmd.Parameters.Add("@InstanceName", SqlDbType.VarChar).Value = instanceName;
                        cmd.Parameters.Add("@Edition", SqlDbType.VarChar).Value = edition;
                        cmd.Parameters.Add("@Version", SqlDbType.VarChar).Value = version;
                        cmd.Parameters.Add("@IsClustered", SqlDbType.Bit).Value = isClustered;
                        cmd.Parameters.Add("@MaxMemory", SqlDbType.BigInt).Value = maxMemory;
                        cmd.Parameters.Add("@MinMemory", SqlDbType.BigInt).Value = minMemory;
                        cmd.Parameters.Add("@ServiceAccount", SqlDbType.VarChar).Value = "TestServiceAccount";
                        cmd.Parameters.Add("@ProductLevel", SqlDbType.VarChar).Value = productLevel;
                        cmd.Parameters.Add("@SSAS", SqlDbType.Bit).Value = ssasservice.Exists;
                        cmd.Parameters.Add("@SSRS", SqlDbType.Bit).Value = ssrsservice.Exists;

                        repConn.Open();
                        cmd.ExecuteNonQuery();
                        repConn.Close();
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private SqlConnection BuildConnection()
        {
            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = instanceName;
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 3;

            SqlConnection conn = new SqlConnection(connectionstring.ConnectionString);
            return conn;
        }
        public void CheckServices()
        {
            foreach (KeyValuePair<string, ServiceValue> service in _serviceDictionary)
            {
                if (service.Value.Exists == 1)
                {
                    try
                    {
                        if (service.Key == "MSSQL")
                        {
                            service.Value.status = TestConnection().ToString();
                        }
                        else
                        {
                            ServiceController sc = new ServiceController(service.Value.serviceName, _serverName);
                            service.Value.status = sc.Status.ToString();
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                    }
                }

            }
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
            using (SqlConnection repConn = new SqlConnection(repository))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredInstances_SetInstance", repConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                    cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                    cmd.Parameters.Add("@InstanceName", SqlDbType.VarChar).Value = instanceName;
                    cmd.Parameters.Add("@PingTest", SqlDbType.Bit).Value = 1;
                    cmd.Parameters.Add("@PingStatus", SqlDbType.Bit).Value = sqlservice.status;
                    cmd.Parameters.Add("@SSASStatus", SqlDbType.VarChar).Value = ssasservice.status;
                    cmd.Parameters.Add("@SSRSStatus", SqlDbType.VarChar).Value = ssrsservice.status;
                    cmd.Parameters.Add("@AgentStatus", SqlDbType.VarChar).Value = agentservice.status;



                    //Console.WriteLine("exec dbo.MonitoredInstances_SetInstance @ServerID = {0},@InstanceID={1},@PingTest={2},@PingStatus={3},@SSASStatus='{4}',@SSRSStatus='{5}',@AgentStatus='{6}'", _serverID,_instanceID, 1, sqlservice.status,ssasservice.status,ssrsservice.status,agentservice.status);
                    repConn.Open();
                    cmd.ExecuteNonQuery();
                    repConn.Close();
                }
            }

        }
        public void GatherServices()
        {
            foreach (KeyValuePair<string, ServiceValue> service in _serviceDictionary)
            {
                if (service.Key == "SSAS" || service.Key == "SSRS")
                {
                    try
                    {
                        if (DoesServiceExist(service.Value.serviceName, _serverName))
                        {
                            service.Value.Exists = 1;
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                    }
                }
            }
        }

        bool DoesServiceExist(string serviceName, string machineName)
        {
            ServiceController[] services = ServiceController.GetServices(machineName);
            var service = services.FirstOrDefault(s => s.ServiceName == serviceName);
            return service != null;
        }

        public void GatherDatabases()
        {
            try
            {
                ResourceManager rm = Queries.ResourceManager;
                string query = rm.GetString("GatherDatabases");
            }
            catch (Exception)
            {
                
                throw;
            }
        }
    }
}
