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
    class InstanceJobs
    {
        
        static private long _logID;
        
        public static void ProcessInstances()
        {
            CollectionLog log = new CollectionLog();
            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            foreach (DataRow pRow in instances.Tables[0].Rows)
            {
                string Name = (string)pRow["InstanceName"];
                if(pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
                {
                    instance = new Instance((string)pRow["InstanceName"],(int)pRow["ServerID"],(int)pRow["InstanceID"]);
                    instance.GatherServices();
                }
                else
                {
                    instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"],(int)pRow["InstanceID"],(bool)pRow["SSAS"], (bool)pRow["SSRS"]);
                }
                
                if(instance.TestConnection())
                {
                    instance.GatherInstance();
                }                
            }

            log.LogModule(_logID);
        }

        private static DataSet ConnectRepository()
        {
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;

            SqlConnection conn = new SqlConnection(repository);

            try
            {
                using (SqlCommand listInstances = new SqlCommand("exec MonitoredInstances_GetInstances @Module = 'CheckServers'", conn))
                using (SqlDataAdapter adapter = new SqlDataAdapter(listInstances))
                {
                    conn.Open();
                    DataSet instances = new DataSet();
                    adapter.Fill(instances);
                    conn.Close();
                    return instances;
                }
            }
            catch (Exception)
            {
                
                throw;
            }
            
                
        }
        public static void CheckServices()
        {
            CollectionLog log = new CollectionLog();
            
            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
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

            log.LogModule(_logID);

        }
        public static void ProcessDatabases()
        {
            CollectionLog log = new CollectionLog();

            _logID = log.LogModule();

            Instance instance;
            DataSet instances = ConnectRepository();
            foreach (DataRow pRow in instances.Tables[0].Rows)
            {

                instance = new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]);
                if (instance.TestConnection())
                {
                    instance.GatherDatabases();
                }
            }

            log.LogModule(_logID);

        }
        public static void Daily()
        {
            CollectionLog log = new CollectionLog();
            long _DlogID = log.LogModule();

            ProcessInstances();
            ProcessDatabases();

            log.LogModule(_DlogID);
        }
    }
}
