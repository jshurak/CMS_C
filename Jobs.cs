using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;


namespace CMS_C
{
    public static class Jobs
    {
        
        static private long _logID;
        
        public static void ProcessInstances(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            
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
            catch (Exception ex)
            {
                EventLogger.LogEvent(ex.ToString(), "Error");
                return instances;
            }
            
                
        }
        public static void CheckServices(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            
            _logID = log.LogModule();


            foreach (Instance _instance in InstanceList)
            {
                if (_instance.TestConnection())
                {
                    _instance.CheckServices();
                }
            }
         

            log.LogModule(_logID);

        }
        public static void ProcessDatabases(List<Database> DatabaseList,List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherDatabases(DatabaseList);
                }
            }            
            log.LogModule(_logID);

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

            foreach (Instance _instance in InstanceList)
            {
                if (_instance.TestConnection())
                {
                    _instance.GatherBlocking();
                }
            }

            log.LogModule(_logID);

        }


        public static void ProcessDatabaseFiles(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();


            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherDatabaseFiles();
                }
            }


            log.LogModule(_logID);
        }

        public static void ProcessBackups(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();


                foreach (Instance _instance in InstanceList)
                {

                    if (_instance.TestConnection())
                    {
                        _instance.GatherBackups();
                    }
                }

            log.LogModule(_logID);

        }
        public static void Daily(List<Server> ServerList,List<Instance> InstanceList,List<Database> DatabaseList,List<AgentJob> AgentJobList)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            ProcessServers(ServerList);
            ProcessDrives(ServerList);
            ProcessInstances(InstanceList);
            ProcessDatabases(DatabaseList,InstanceList);
            ProcessDatabaseFiles(InstanceList);
            ProcessAgentJobs(InstanceList, AgentJobList);

            log.LogModule(_DlogID);
        }
        public static void ThirtyMinutes(List<Database> DatabaseList, List<Instance> InstanceList, List<AgentJob> AgentJobList)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            ProcessDatabases(DatabaseList,InstanceList);
            ProcessDatabaseFiles(InstanceList);
            ProcessAgentJobs(InstanceList,AgentJobList);
            ProcessWaitStats(InstanceList);

            log.LogModule(_DlogID);
        }
        public static void FiveMinutes(List<Server> ServerList,List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            CheckServices(InstanceList);
            ProcessDrives(ServerList);
            ProcessDatabaseFiles(InstanceList);
            ProcessBlocking(InstanceList);
            ProcessBackups(InstanceList);

            log.LogModule(_DlogID);
        }

        

        public static bool TestDataSet(DataSet _dbs)
        {
            return _dbs.Tables.Count > 0;
        }

        public static void ProcessServers(List<Server> ServerList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            foreach (Server _server in ServerList)
            {
                _server.GatherServer();
            }
            
            log.LogModule(_logID);
        }
        public static void ProcessDrives(List<Server> ServerList)
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            foreach (Server _server in ServerList)
            {
                _server.GatherDrives();
            }

            log.LogModule(_logID);
        }

        public static void ProcessWaitStats(List<Instance> InstanceList)
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();


            foreach (Instance _instance in InstanceList)
            {

                if (_instance.TestConnection())
                {
                    _instance.GatherWaitStats();
                }
            }

            log.LogModule(_logID);
        }
    }
}
