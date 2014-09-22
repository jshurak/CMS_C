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
        
        public void BuildDatabaseCache()
        {
            DataSet _databaseSet = Jobs.ConnectRepository("SELECT DatabaseID,mi.InstanceID,databaseName,DatabaseGUID FROM MonitoredDatabases md INNER JOIN MonitoredInstances mi ON md.InstanceID = mi.InstanceID where md.deleted = 0 AND mi.MonitorInstance = 1");
            if(Jobs.TestDataSet(_databaseSet))
            {
                foreach(DataRow pRow in _databaseSet.Tables[0].Rows)
                {
                    DatabaseCache.Add(new Database((int)pRow["DatabaseID"],(int)pRow["InstanceID"],(string)pRow["DatabaseName"],(string)pRow["DatabaseGUID"]));
                }
            }
        }
    }
}
