using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Reflection;
using System.Data.SqlClient;
using System.Configuration;
using log4net;


namespace CMS_C
{
    public class CMSCache
    {
        public List<Database> DatabaseCache = new List<Database>();
        public List<Server> ServerCache = new List<Server>();
        public List<Instance> InstanceCache = new List<Instance>();
        public List<AgentJob> AgentJobCache = new List<AgentJob>();
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod
().DeclaringType);
        
        public void BuildCache()
        {
            this.AgentJobCache.Clear();
            this.DatabaseCache.Clear();
            this.ServerCache.Clear();
            this.InstanceCache.Clear();

            BuildServerCache();
            BuildInstanceCache();
            BuildDatabaseCache();
            BuildAgentJobCache();
        }

        public void CheckForCacheRefresh()
        {
            log.Info("Checking for cache refresh flags");
            DataSet _results = Jobs.ConnectRepository("SELECT CacheName FROM CacheController WHERE Refresh = 1");
            if(Jobs.TestDataSet(_results))
            {
                foreach (DataRow pRow in _results.Tables[0].Rows)
                {
                    RefreshCache(pRow["CacheName"].ToString());
                    
                }
            }
            
        }

        public void AcknowledgeCacheRefresh(string T)
        {
            SqlConnection repConn;
            try
            {
                string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
                using (repConn = new SqlConnection(repository))
                using (SqlCommand cmd = new SqlCommand("dbo.CacheAcknowledgeRefresh", repConn))
                {

                    cmd.Parameters.Clear();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CacheName", SqlDbType.VarChar).Value = T;

                    repConn.Open();
                    cmd.ExecuteNonQuery();
                    repConn.Close();
                }
                log.Info(T + " cache built.");
            }
            catch (SqlException ex)
            {
                log.Error("Instance: " + ex.Server + ". " + ex.Message);
                //Jobs.LogSQLErrors(ex, ex.Server,ex.Server);
            }
        }

        public void RefreshCache(string Type)
        {            
            switch(Type)
            {
                case "AgentJob":
                    this.AgentJobCache.Clear();
                    BuildAgentJobCache();
                    break;
                case "Database":
                    this.DatabaseCache.Clear();
                    BuildDatabaseCache();
                    break;
                case "Server" :
                    this.ServerCache.Clear();
                    BuildServerCache();
                    break;
                case "Instance" :
                    this.InstanceCache.Clear();
                    BuildInstanceCache();
                    break;
                default:
                    this.BuildCache();
                    break;
            }

        }

        public void BuildAgentJobCache()
        {
            log.Info("Building agent cache.");
            DataSet _agentJobSet = Jobs.ConnectRepository("SELECT InstanceID,JobGUID FROM monitoredinstancejobs WHERE MonitorJob = 1 and Deleted = 0");
            if (Jobs.TestDataSet(_agentJobSet))
            {

                //Parallel.ForEach<DataRow>(_agentJobSet.Tables[0].Rows.OfType<DataRow>(), pRow => 
                //{
                //    AgentJobCache.Add(new AgentJob((int)pRow["InstanceID"], (string)pRow["JobGUID"]));
                //});


                foreach (DataRow pRow in _agentJobSet.Tables[0].Rows)
                {
                    AgentJobCache.Add(new AgentJob((int)pRow["InstanceID"], (string)pRow["JobGUID"]));
                }
            }
            AcknowledgeCacheRefresh("AgentJob");
        }

        public void BuildDatabaseCache()
        {
            log.Info("Building database cache.");
            DataSet _databaseSet = Jobs.ConnectRepository("SELECT mi.InstanceID,databaseName,DatabaseGUID FROM MonitoredDatabases md INNER JOIN MonitoredInstances mi ON md.InstanceID = mi.InstanceID where md.deleted = 0 AND mi.MonitorInstance = 1");
            if(Jobs.TestDataSet(_databaseSet))
            {
                //Parallel.ForEach<DataRow>(_databaseSet.Tables[0].Rows.OfType<DataRow>(), pRow =>
                //{
                //    DatabaseCache.Add(new Database((int)pRow["InstanceID"], (string)pRow["DatabaseName"], (string)pRow["DatabaseGUID"]));
                //});

                foreach (DataRow pRow in _databaseSet.Tables[0].Rows)
                {
                    DatabaseCache.Add(new Database((int)pRow["InstanceID"], (string)pRow["DatabaseName"], (string)pRow["DatabaseGUID"]));
                }
            }
            AcknowledgeCacheRefresh("Database");
        }

        public void BuildServerCache()
        {
            log.Info("Building server cache.");
            DataSet _serverSet = Jobs.ConnectRepository("SELECT ServerID,ServerName,IsVirtualServerName FROM MonitoredServers Where MonitorServer = 1 and Deleted = 0");
            if (Jobs.TestDataSet(_serverSet))
            {

                //Parallel.ForEach<DataRow>(_serverSet.Tables[0].Rows.OfType<DataRow>(), pRow =>
                //{
                //    ServerCache.Add(new Server((int)pRow["ServerID"], (string)pRow["ServerName"], (bool)pRow["IsVirtualServerName"]));
                //});

                foreach (DataRow pRow in _serverSet.Tables[0].Rows)
                {
                    ServerCache.Add(new Server((int)pRow["ServerID"], (string)pRow["ServerName"], (bool)pRow["IsVirtualServerName"]));
                }
            }
            AcknowledgeCacheRefresh("Server");
        }

        public void BuildInstanceCache()
        {
            log.Info("Building instance cache.");
            DataSet _instanceSet = Jobs.ConnectRepository("exec MonitoredInstances_GetInstances @Module = 'CheckServers'");
            if(Jobs.TestDataSet(_instanceSet))
            {
                //Parallel.ForEach<DataRow>(_instanceSet.Tables[0].Rows.OfType<DataRow>(), pRow =>
                //{
                //    if (Jobs.TestConnection(pRow["ServerName"].ToString(), pRow["InstanceName"].ToString()))
                //    {
                //        if (pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
                //        {
                //            InstanceCache.Add(new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]));

                //        }
                //        else
                //        {
                //            InstanceCache.Add(new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"], (bool)pRow["SSAS"], (bool)pRow["SSRS"]));
                //        }
                //    }
                //});

                foreach (DataRow pRow in _instanceSet.Tables[0].Rows)
                {
                    if (Jobs.TestConnection(pRow["ServerName"].ToString(), pRow["InstanceName"].ToString()))
                    {
                        if (pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
                        {
                            InstanceCache.Add(new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"]));

                        }
                        else
                        {
                            InstanceCache.Add(new Instance((string)pRow["InstanceName"], (int)pRow["ServerID"], (int)pRow["InstanceID"], (bool)pRow["SSAS"], (bool)pRow["SSRS"]));
                        }
                    }
                }
            }
            AcknowledgeCacheRefresh("Instance");
        }
        
    }
}
