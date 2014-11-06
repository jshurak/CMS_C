using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
using log4net;
using System.Reflection;


namespace CMS_C
{
    public static class Jobs
    {

        private static readonly ILog logNet = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod
().DeclaringType);
        static private long _logID;
        
        public static void ProcessInstances(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");
            
            foreach (Instance _instance in InstanceList)
            {
                
                if ((_instance.SSAS.HasValue == false) || (_instance.SSRS.HasValue == false))
                    
                {                    
                    _instance.GatherServices();
                    _instance.GatherInstance();
                }


                if (_instance.TestConnection())
                {
                    _instance.GatherInstance();
                }
            }
            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        public static DataSet ConnectRepository(string Query = "exec MonitoredInstances_GetInstances @Module = 'CheckServers'")
        {
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
            DataSet instances = new DataSet();
            SqlConnection conn = new SqlConnection(repository);

            try
            {
                using (SqlCommand listInstances = new SqlCommand(Query, conn))
                using (SqlDataAdapter adapter = new SqlDataAdapter(listInstances))
                {
                    conn.Open();
                    adapter.Fill(instances);
                    conn.Close();
                    return instances;
                }
            }
            catch (SqlException ex)
            {
                logNet.Error(ex.Message);
                EventLogger.LogEvent(ex.ToString(), "Error");
                return instances;
            }
            
                
        }
        public static void CheckServices(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            
            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Instance _instance in InstanceList)
            {
                if (_instance.TestConnection())
                {
                    _instance.CheckServices();
                }
            }
         

            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }
        public static void ProcessDatabases(List<Database> DatabaseList,List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherDatabases(DatabaseList);
                }
            }            
            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        public static void ProcessAgentJobs(List<Instance> InstanceList,List<AgentJob> AgentList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();


            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherAgentJobs(AgentList);
                    
                }
            }

            log.LogModule(_logID);

        }




        public static void ProcessBlocking(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");
            foreach (Instance _instance in InstanceList)
            {
                if (_instance.TestConnection())
                {
                    _instance.GatherBlocking();
                }
            }

            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }


        public static void ProcessDatabaseFiles(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherDatabaseFiles();
                }
            }


            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        public static void ProcessBackups(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

                foreach (Instance _instance in InstanceList)
                {

                    if (_instance.TestConnection())
                    {
                        _instance.GatherBackups();
                    }
                }

            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }
        public static void Daily(CMSCache Cache)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            ProcessServers(Cache.ServerCache,Cache.InstanceCache);
            ProcessDrives(Cache.ServerCache);
            ProcessInstances(Cache.InstanceCache);
            ProcessDatabases(Cache.DatabaseCache,Cache.InstanceCache);
            ProcessDatabaseFiles(Cache.InstanceCache);
            ProcessAgentJobs(Cache.InstanceCache,Cache.AgentJobCache);

            log.LogModule(_DlogID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }
        public static void ThirtyMinutes(CMSCache Cache)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            ProcessDatabases(Cache.DatabaseCache,Cache.InstanceCache);
            ProcessDatabaseFiles(Cache.InstanceCache);
            ProcessAgentJobs(Cache.InstanceCache,Cache.AgentJobCache);
            ProcessWaitStats(Cache.InstanceCache);

            log.LogModule(_DlogID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }
        public static void FiveMinutes(CMSCache Cache)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            CheckServices(Cache.InstanceCache);
            ProcessDrives(Cache.ServerCache);
            ProcessDatabaseFiles(Cache.InstanceCache);
            ProcessBlocking(Cache.InstanceCache);
            ProcessBackups(Cache.InstanceCache);

            log.LogModule(_DlogID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        

        public static bool TestDataSet(DataSet _dbs)
        {
            return _dbs.Tables.Count > 0;
        }

        public static void ProcessServers(List<Server> ServerList,List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Server _server in ServerList)
            {
                    _server.GatherServer(InstanceList);               
            }
            
            log.LogModule(_logID);

            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }
        public static void ProcessDrives(List<Server> ServerList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Server _server in ServerList)
            {
                _server.GatherDrives();
            }

            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        public static void ProcessWaitStats(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();
            logNet.Info(MethodBase.GetCurrentMethod().Name + " starting.");

            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherWaitStats();
                }
            }

            log.LogModule(_logID);
            logNet.Info(MethodBase.GetCurrentMethod().Name + " complete.");
        }

        public static void LogSQLErrors(SqlException ex,string ServerName,string InstanceName)
        {
            StringBuilder errorMessages = new StringBuilder();
            for (int i = 0; i < ex.Errors.Count; i++)
            {
                errorMessages.Append("Message: " + ex.Errors[i].Message + "\n" +
                    "ServerName: " + ServerName + "\n" +
                    "InstanceName: " + InstanceName + "\n" +
                    "Source: " + ex.Errors[i].Source + "\n");
            }
            EventLogger.LogEvent(errorMessages.ToString(), "Error");
        }

        public static bool TestConnection(string ServerName, string InstanceName)
        {
            SqlConnection conn = BuildConnection(InstanceName);
            using (SqlCommand instanceCheckCmd = new SqlCommand("SELECT @@SERVERNAME", conn))
            {
                try
                {
                    conn.Open();
                    instanceCheckCmd.ExecuteScalar();
                    conn.Close();
                    return true;
                }
                catch (SqlException ex)
                {
                    logNet.Error("Instance: " + InstanceName + ". " + ex.Message);
                    Jobs.LogSQLErrors(ex, ServerName, InstanceName);
                    return false;

                }
            }
        }

        private static SqlConnection BuildConnection(string InstanceName)
        {
            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = InstanceName;
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 30;

            SqlConnection conn = new SqlConnection(connectionstring.ConnectionString);
            return conn;
        }
    }
}
