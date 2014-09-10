﻿using System;
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
                    Console.WriteLine(instanceName,e.ToString());
                    return false;

                }
            }
        }

        public void GatherInstance()
        {
            DataSet _instances = GatherData("GatherInstance");
            if (InstanceJobs.TestDataSet(_instances))
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
            DataSet _dbs = GatherData("GatherBackups");
            if (InstanceJobs.TestDataSet(_dbs))
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
                        Console.WriteLine(e.ToString());
                        Console.ReadLine();
                        throw;
                    }
                }
            }
        }
        public void GatherDatabaseFiles()
        {
            DataSet _files = GatherData("GatherDatabaseFiles");
            if(InstanceJobs.TestDataSet(_files))
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
                        Console.WriteLine(e.ToString());
                        Console.ReadLine();
                        throw;
                    }
                }
            }
        }

        public void GatherBlocking()
        {
            DataSet _data = GatherData("GatherBlocking");
            if(InstanceJobs.TestDataSet(_data))
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
                            Dictionary<int,DateTime> _currentBlockers = new Dictionary<int,DateTime>();
                            _currentBlockers.Add((int)_blocker["CurrentBlockingSpid"],(DateTime)_blocker["LastBatchTime"]);

                        }

                        foreach (DataRow pRow in _data.Tables[0].Rows)
                        {
                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instanceID;
                            
                            cmd.ExecuteNonQuery();
                        }
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                        Console.ReadLine();
                        throw;
                    }
                }
            }
        }
        public void GatherDatabases()
        {
            DataSet _dbs = GatherData("GatherDatabases");
            if (InstanceJobs.TestDataSet(_dbs))
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
                        Console.WriteLine(e.ToString());
                        Console.ReadLine();
                        throw;
                    }
                }
            }
                		
	    }

        private DataSet GatherData(string Query)
        {
            string _query = GetQuery(Query);
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
        }
    }

