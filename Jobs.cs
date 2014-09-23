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
        
        public static void ProcessInstances()
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {
                    string Name = (string)pRow["InstanceName"];
                    if (pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
                    {
                        instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                        instance.GatherServices();
                    }
                    else
                    {
                        instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"], (bool)pRow["SSAS"], (bool)pRow["SSRS"]);
                    }

                    if (instance.TestConnection())
                    {
                        instance.GatherInstance();
                    }
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
        public static void CheckServices()
        {
            CollectionLog log = new CollectionLog();
            
            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {
                    string Name = (string)pRow["InstanceName"];
                    if (pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
                    {
                        instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                        instance.GatherServices();
                    }
                    else
                    {
                        instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"], (bool)pRow["SSAS"], (bool)pRow["SSRS"]);
                    }

                    if (instance.TestConnection())
                    {
                        instance.CheckServices();
                    }
                }
            }

            log.LogModule(_logID);

        }
        public static void ProcessDatabases()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if(TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherDatabases();
                    }
                }
            }
            
            log.LogModule(_logID);

        }

        public static void ProcessAgentJobs()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherAgentJobs();
                    }
                }
            }

            log.LogModule(_logID);

        }




        public static void ProcessBlocking()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"],(int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherBlocking();
                    }
                }
            }

            log.LogModule(_logID);

        }


        public static void ProcessDatabaseFiles()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherDatabaseFiles();
                    }
                }
            }


            log.LogModule(_logID);
        }

        public static void ProcessBackups()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if(TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherBackups();
                    }
                }
            }
            

            log.LogModule(_logID);

        }
        public static void Daily(List<Server> ServerList)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            ProcessServers(ServerList);
            ProcessDrives(ServerList);
            ProcessInstances();
            ProcessDatabases();
            ProcessDatabaseFiles();
            ProcessAgentJobs();

            log.LogModule(_DlogID);
        }
        public static void ThirtyMinutes()
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            ProcessDatabases();
            ProcessDatabaseFiles();
            ProcessAgentJobs();
            ProcessWaitStats();

            log.LogModule(_DlogID);
        }
        public static void FiveMinutes(List<Server> ServerList)
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            CheckServices();
            ProcessDrives(ServerList);
            ProcessDatabaseFiles();
            ProcessBlocking();
            ProcessBackups();

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

        public static void ProcessWaitStats()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            if (TestDataSet(instances))
            {
                foreach (DataRow pRow in instances.Tables[0].Rows)
                {

                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                    if (instance.TestConnection())
                    {
                        instance.GatherWaitStats();
                    }
                }
            }


            log.LogModule(_logID);
        }
    }
}
