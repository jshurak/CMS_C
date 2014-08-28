﻿using System;
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
        static private string _moduleName;
        static private long _logID;

        public static void ProcessInstances()
        {
            CollectionLog log = new CollectionLog();
            _moduleName = "ProcessInstances";
            _logID = log.LogModule(_moduleName);

            Instance instance;
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
            
            SqlConnection conn = new SqlConnection(repository);
            
            conn.Open();
            SqlCommand listInstances = new SqlCommand("exec MonitoredInstances_GetInstances @Module = 'CheckServers'", conn);
            SqlDataAdapter adapter = new SqlDataAdapter(listInstances);
            DataSet instances = new DataSet();
            adapter.Fill(instances);
            conn.Close();
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

            log.LogModule(_moduleName, _logID);
        }
    }
}
