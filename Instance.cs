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
using System.Collections;
using System.Runtime.CompilerServices;


namespace CMS_C
{
    public class Instance
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
            instanceName = InstanceName;
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
                    EventLogger.LogEvent(e.ToString(), "Warning");
                    return false;

                }
            }
        }

        public void GatherInstance()
        {
            DataSet _instances = GatherData();
            if (Jobs.TestDataSet(_instances))
            {
                try
                {
                    string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                    using (SqlConnection repConn = new SqlConnection(repository))
                    using (SqlCommand cmd = new SqlCommand("dbo.MonitoredInstances_SetInstance", repConn))
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _instances.Tables[0].Rows)
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@InstanceName", SqlDbType.VarChar).Value = pRow["InstanceName"].ToString();
                            cmd.Parameters.Add("@Edition", SqlDbType.VarChar).Value = pRow["Edition"].ToString();
                            cmd.Parameters.Add("@Version", SqlDbType.VarChar).Value = pRow["Version"].ToString();
                            cmd.Parameters.Add("@IsClustered", SqlDbType.Bit).Value = (bool)pRow["isClustered"];
                            cmd.Parameters.Add("@MaxMemory", SqlDbType.BigInt).Value = (long)pRow["maxMemory"];
                            cmd.Parameters.Add("@MinMemory", SqlDbType.BigInt).Value = (int)pRow["minMemory"];
                            cmd.Parameters.Add("@ServiceAccount", SqlDbType.VarChar).Value = "TestServiceAccount";
                            cmd.Parameters.Add("@ProductLevel", SqlDbType.VarChar).Value = pRow["ProductLevel"].ToString();
                            cmd.Parameters.Add("@SSAS", SqlDbType.Bit).Value = ssasservice.Exists;
                            cmd.Parameters.Add("@SSRS", SqlDbType.Bit).Value = ssrsservice.Exists;
                        }
                        cmd.ExecuteNonQuery();
                        repConn.Close();
                    }
                }
                catch (Exception e)
                {
                    EventLogger.LogEvent(e.ToString(), "Error");
                }
            }
            
        }

        private SqlConnection BuildConnection()
        {
            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = instanceName;
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 15;

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
                        EventLogger.LogEvent(e.ToString(), "Warning");
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

                    repConn.Open();
                    cmd.ExecuteNonQuery();
                    repConn.Close();
                }
            }

        }
        public void GatherServices()
        {
            BuildServices(instanceName);
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

        private string GetQuery(string Query)
        {
            try
            {
                ResourceManager rm = Queries.ResourceManager;
                string query = rm.GetString(Query);
                return query;
            }
            catch (Exception)
            {
                
                throw;
            }
        }

        public void GatherBackups()
        {
            DataSet _dbs = GatherData();
            if (Jobs.TestDataSet(_dbs))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredDatabases_SetBackups", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _dbs.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@DatabaseGUID", SqlDbType.VarChar).Value = pRow["DatabaseGUID"].ToString();
                            cmd.Parameters.Add("@RecoveryModel", SqlDbType.VarChar).Value = pRow["RecoveryModel"].ToString();
                            cmd.Parameters.Add("@LastFullBackupDate", SqlDbType.DateTime).Value = pRow["LastBackupDate"];
                            cmd.Parameters.Add("@LastDifferentialBackupDate", SqlDbType.DateTime).Value = pRow["LastDifferentialBackupDate"];
                            cmd.Parameters.Add("@LastLogBackupDate", SqlDbType.DateTime).Value = pRow["LastLogBackupDate"];

                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }
        }
        public void GatherDatabaseFiles()
        {
            DataSet _files = GatherData();
            if(Jobs.TestDataSet(_files))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredDatabaseFiles_SetDatabaseFiles", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _files.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@DatabaseGUID", SqlDbType.VarChar).Value = pRow["DatabaseGUID"].ToString();
                            cmd.Parameters.Add("@LogicalName", SqlDbType.VarChar).Value = pRow["LogicalName"].ToString();
                            cmd.Parameters.Add("@PhysicalName", SqlDbType.VarChar).Value = pRow["PhysicalName"].ToString();
                            cmd.Parameters.Add("@Directory", SqlDbType.VarChar).Value = pRow["Directory"].ToString();
                            cmd.Parameters.Add("@FileType", SqlDbType.VarChar).Value = pRow["FileType"].ToString();
                            cmd.Parameters.Add("@FileSize", SqlDbType.Float).Value = pRow["FileSize"];
                            cmd.Parameters.Add("@UsedSpace", SqlDbType.Float).Value = pRow["UsedSpace"];
                            cmd.Parameters.Add("@AvailableSpace", SqlDbType.Float).Value = pRow["AvailableSpace"];
                            cmd.Parameters.Add("@MaxSize", SqlDbType.Float).Value = pRow["MaxSize"];
                            cmd.Parameters.Add("@Growth", SqlDbType.Float).Value = pRow["Growth"];
                            cmd.Parameters.Add("@PercentageFree", SqlDbType.Decimal).Value = pRow["PercentageFree"];
                            cmd.Parameters.Add("@GrowthType", SqlDbType.VarChar).Value = pRow["GrowthType"].ToString();

                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }
        }

        public void GatherBlocking()
        {
            Dictionary<int,DateTime> _currentBlockers  = new Dictionary<int,DateTime>();

            DataSet _data = GatherData();
            if(Jobs.TestDataSet(_data))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredBlocking_SetBlocking", repConn))
                {
                    try
                    {
                        SqlCommand existingcmd = new SqlCommand("dbo.MonitoredBlocking_GetBlocking", repConn);
                        

                        existingcmd.Parameters.Clear();
                        existingcmd.CommandType = CommandType.StoredProcedure;
                        existingcmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;


                        SqlDataAdapter adapter = new SqlDataAdapter(existingcmd);
                        DataSet _existingBlocking = new DataSet();
                        repConn.Open();
                        adapter.Fill(_existingBlocking);
                        
                        foreach(DataRow _blocker in _existingBlocking.Tables[0].Rows)
                        {
                            _currentBlockers.Add(Convert.ToInt32(_blocker["CurrentBlockingSpid"]),(Convert.ToDateTime(_blocker["LastBatchTime"])));
                        }

                        foreach (DataRow pRow in _data.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@SPID", SqlDbType.SmallInt).Value = pRow["SPID"];
                            cmd.Parameters.Add("@Action", SqlDbType.VarChar).Value = "OPEN";
                            cmd.Parameters.Add("@LastBatchTime", SqlDbType.DateTime).Value = pRow["LastBatchTime"];
                            cmd.Parameters.Add("@Status", SqlDbType.VarChar).Value = pRow["Status"].ToString();
                            cmd.Parameters.Add("@LoginName", SqlDbType.VarChar).Value = pRow["LoginName"].ToString();
                            cmd.Parameters.Add("@HostName", SqlDbType.VarChar).Value = pRow["HostName"].ToString();
                            cmd.Parameters.Add("@ProgramName", SqlDbType.VarChar).Value = pRow["ProgramName"].ToString();
                            cmd.Parameters.Add("@OpenTran", SqlDbType.SmallInt).Value = pRow["OpenTran"];
                            cmd.Parameters.Add("@DatabaseName", SqlDbType.VarChar).Value = pRow["DatabaseName"].ToString();
                            cmd.Parameters.Add("@Command", SqlDbType.VarChar).Value = pRow["Command"].ToString();
                            cmd.Parameters.Add("@LastWaitType", SqlDbType.VarChar).Value = pRow["LastWaitType"].ToString();
                            cmd.Parameters.Add("@WaitTime", SqlDbType.BigInt).Value = pRow["WaitTime"];
                            cmd.Parameters.Add("@SQL", SqlDbType.VarChar).Value = pRow["SQLStatement"].ToString();  
                            cmd.ExecuteNonQuery();
                            _currentBlockers.Remove(Convert.ToInt32(pRow["SPID"]));
                        }

                        foreach(KeyValuePair<int,DateTime> _deadBlocker in _currentBlockers)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@Action", SqlDbType.VarChar).Value = "CLOSE";
                            cmd.Parameters.Add("@SPID", SqlDbType.Int).Value = _deadBlocker.Key;
                            cmd.Parameters.Add("@LastBatchTime", SqlDbType.DateTime).Value = _deadBlocker.Value;
                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(),"Warning");
                    }
                }
            }
        }
        public void GatherDatabases()
        {
            DataSet _dbs = GatherData();
            if (Jobs.TestDataSet(_dbs))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredDatabases_SetDatabases", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _dbs.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@DatabaseName", SqlDbType.VarChar).Value = pRow["DatabaseName"].ToString();
                            cmd.Parameters.Add("@CreationDate", SqlDbType.DateTime).Value = (DateTime)pRow["CreationDate"];
                            cmd.Parameters.Add("@CompatibilityLevel", SqlDbType.Int).Value = (int)pRow["CompatibilityLevel"];
                            cmd.Parameters.Add("@Collation", SqlDbType.VarChar).Value = pRow["Collation"].ToString();
                            cmd.Parameters.Add("@size", SqlDbType.Int).Value = (int)pRow["Size"];
                            cmd.Parameters.Add("@DataSpaceUsage", SqlDbType.BigInt).Value = (long)pRow["DataSpaceUsage"];
                            cmd.Parameters.Add("@IndexSpaceUsage", SqlDbType.BigInt).Value = (long)pRow["IndexSpaceUsage"];
                            cmd.Parameters.Add("@SpaceAvailable", SqlDbType.BigInt).Value = (long)pRow["SpaceAvailable"];
                            cmd.Parameters.Add("@RecoveryModel", SqlDbType.VarChar).Value = pRow["RecoveryModel"].ToString();
                            cmd.Parameters.Add("@AutoClose", SqlDbType.Bit).Value = (bool)pRow["AutoClose"]; ;
                            cmd.Parameters.Add("@AutoShrink", SqlDbType.Bit).Value = (bool)pRow["AutoShrink"];
                            cmd.Parameters.Add("@ReadOnly", SqlDbType.Bit).Value = (bool)pRow["ReadOnly"];
                            cmd.Parameters.Add("@PageVerify", SqlDbType.VarChar).Value = pRow["PageVerify"].ToString();
                            cmd.Parameters.Add("@GUID", SqlDbType.VarChar).Value = pRow["DatabaseGUID"].ToString();
                            cmd.Parameters.Add("@Owner", SqlDbType.VarChar).Value = pRow["Owner"].ToString();
                            cmd.Parameters.Add("@Status", SqlDbType.VarChar).Value = pRow["Status"].ToString();
                            cmd.Parameters.Add("@Deleted", SqlDbType.Bit).Value = false;

                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }
                		
	    }

        public void GatherAgentJobs()
        {
            DataSet _agentJobs = GatherData();
            if(Jobs.TestDataSet(_agentJobs))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredInstanceJobs_SetJobs", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _agentJobs.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@JobName", SqlDbType.VarChar).Value = pRow["Name"].ToString();
                            cmd.Parameters.Add("@JobGUID", SqlDbType.VarChar).Value = pRow["JobID"].ToString();
                            cmd.Parameters.Add("@JobCategory", SqlDbType.VarChar).Value = pRow["Category"].ToString();
                            cmd.Parameters.Add("@JobOwner", SqlDbType.VarChar).Value = pRow["OwnerLoginName"].ToString();
                            cmd.Parameters.Add("@LastRunDate", SqlDbType.DateTime).Value = (DateTime)pRow["LastRunDate"];
                            cmd.Parameters.Add("@NextRunDate", SqlDbType.DateTime).Value = (DateTime)pRow["NextRunDate"];
                            cmd.Parameters.Add("@JobOutcome", SqlDbType.VarChar).Value = pRow["LastRunOutcome"].ToString();
                            cmd.Parameters.Add("@JobEnabled", SqlDbType.TinyInt).Value = (int)pRow["IsEnabled"];
                            cmd.Parameters.Add("@JobScheduled", SqlDbType.Int).Value = (int)pRow["HasSchedule"];
                            cmd.Parameters.Add("@JobDuration", SqlDbType.Int).Value = (int)pRow["RunDuration"];
                            cmd.Parameters.Add("@JobCreationDate", SqlDbType.DateTime).Value = (DateTime)pRow["DateCreated"];
                            cmd.Parameters.Add("@JobModifiedDate", SqlDbType.DateTime).Value = (DateTime)pRow["DateLastModified"];
                            cmd.Parameters.Add("@JobEmailLevel", SqlDbType.VarChar).Value = pRow["EmailLevel"].ToString();
                            cmd.Parameters.Add("@JobPageLevel", SqlDbType.VarChar).Value = pRow["PageLevel"].ToString();
                            cmd.Parameters.Add("@JobNetSendLevel", SqlDbType.VarChar).Value = pRow["NetSendLevel"].ToString();
                            cmd.Parameters.Add("@OperatorToEmail", SqlDbType.VarChar).Value = pRow["OperatorToEmail"].ToString();
                            cmd.Parameters.Add("@OperatorToPage", SqlDbType.VarChar).Value = pRow["OperatorToPage"].ToString();
                            cmd.Parameters.Add("@OperatorToNetSend", SqlDbType.VarChar).Value = pRow["OperatorToNetSend"].ToString();

                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }
        }


        public void GatherWaitStats()
        {
            DataSet _waitStats = GatherData();
            if (Jobs.TestDataSet(_waitStats))
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredInstanceServerWaits_SetWaits", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (DataRow pRow in _waitStats.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@WaitType", SqlDbType.VarChar).Value = pRow["wait_type"].ToString();
                            cmd.Parameters.Add("@Waiting_Task_Count", SqlDbType.BigInt).Value = (long)pRow["waiting_tasks_count"];
                            cmd.Parameters.Add("@Wait_Time_MS", SqlDbType.BigInt).Value = (long)pRow["Wait_Time_MS"];
                            cmd.Parameters.Add("@Max_Wait_Time_MS", SqlDbType.BigInt).Value = (long)pRow["Max_Wait_Time_MS"];
                            cmd.Parameters.Add("@Signal_Wait_Time_MS", SqlDbType.BigInt).Value = (long)pRow["Signal_Wait_Time_MS"];
                            cmd.Parameters.Add("@CollectionDate", SqlDbType.DateTime).Value = (DateTime)pRow["CollectionDate"];

                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }
        }


        private DataSet GatherData([CallerMemberName] string Query = null)
        {
            string _query;
            if(Query == null)
            {
                 _query = GetQuery(Query);
            }
            else 
            {
                _query = Query;
            }
            
            DataSet _data = PullDatabases(_query);
            return _data;
        }



        private DataSet PullDatabases(string _query)
        {
            SqlConnection conn = BuildConnection();
            DataSet _dbs = new DataSet();
            try
            {
                SqlCommand gatherDatabases = new SqlCommand(_query, conn);
                SqlDataAdapter adapter = new SqlDataAdapter(gatherDatabases);
                conn.Open();
                adapter.Fill(_dbs);
                return _dbs;
            }
            catch (Exception ex)
            {
                EventLogger.LogEvent(ex.ToString(),"Error");
                return _dbs;
            }
            finally
            {
                conn.Close();
            }
        }
        public void CheckDeletedDatabases(List<Database> Databases)
        {
            List<Database> _existing = new List<Database>();
            List<Database> _dbs = Databases.Where(p => p.InstanceID == _instanceID).ToList();
                        
            DataSet _existingDatabases = GatherData("select d.name,r.database_guid as DatabaseGUID from sys.databases d inner join sys.database_recovery_status r ON d.database_id = r.database_id");
            if(Jobs.TestDataSet(_existingDatabases))
            {
                foreach (DataRow pRow in _existingDatabases.Tables[0].Rows)
                {
                    _existing.Add(new Database(_instanceID, pRow["name"].ToString(),pRow["DatabaseGUID"].ToString()));
                }

            }

            List<Database> _result = _dbs.Except(_existing).ToList();
            if(_result.Count > 0)
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (SqlConnection repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredDatabases_SetDatabases", repConn))
                {
                    try
                    {
                        repConn.Open();
                        foreach (Database _r in _result)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            cmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                            cmd.Parameters.Add("@Deleted", SqlDbType.Bit).Value = true;
                            cmd.Parameters.Add("@DatabaseName", SqlDbType.VarChar).Value = _r.DatabaseName;
                            cmd.Parameters.Add("@GUID", SqlDbType.VarChar).Value = _r.DatabaseGUID;
                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        EventLogger.LogEvent(e.ToString(), "Warning");
                    }
                }
            }                
        }
    }
}

