using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace CMS_C
{
    public class CMSCache
    {
        public List<Database> DatabaseCache = new List<Database>();
        public List<Server> ServerCache = new List<Server>();
        public List<Instance> InstanceCache = new List<Instance>();
        
        public void BuildDatabaseCache()
        {
            DataSet _databaseSet = Jobs.ConnectRepository("SELECT mi.InstanceID,databaseName,DatabaseGUID FROM MonitoredDatabases md INNER JOIN MonitoredInstances mi ON md.InstanceID = mi.InstanceID where md.deleted = 0 AND mi.MonitorInstance = 1");
            if(Jobs.TestDataSet(_databaseSet))
            {
                foreach(DataRow pRow in _databaseSet.Tables[0].Rows)
                {
                    DatabaseCache.Add(new Database((int)pRow["InstanceID"],(string)pRow["DatabaseName"],(string)pRow["DatabaseGUID"]));
                }
            }
        }

        public void BuildServerCache()
        {
            DataSet _serverSet = Jobs.ConnectRepository("SELECT ServerID,ServerName FROM MonitoredServers Where MonitorServer = 1 and Deleted = 0");
            if (Jobs.TestDataSet(_serverSet))
            {
                foreach(DataRow pRow in _serverSet.Tables[0].Rows)
                {
                    ServerCache.Add(new Server((int)pRow["ServerID"], (string)pRow["ServerName"]));
                }
            }
        }

        public void BuildInstanceCache()
        {
            DataSet _instanceSet = Jobs.ConnectRepository("exec MonitoredInstances_GetInstances @Module = 'CheckServers'");
            if(Jobs.TestDataSet(_instanceSet))
            {
                foreach(DataRow pRow in _instanceSet.Tables[0].Rows)
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
        
    }
}
