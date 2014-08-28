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
        public static void ProcessInstances()
        {
            //bool SSAS;
            //bool SSRS;
            //Instance instance;
            ////string connectionString = ConfigurationManager.ConnectionStrings("Repository");
            //SqlConnectionStringBuilder connectionString = new SqlConnectionStringBuilder();
            //connectionString["Data Source"] = "PHLDVWSSQL002\\DVS1201";
            //connectionString["Initial Catalog"] = "CMS_Dev";
            //connectionString["Timeout"] = 3;
            //connectionString["Integrated Security"] = true;
          
            //SqlConnection conn = new SqlConnection(connectionString.ConnectionString);
            
            //conn.Open();
            //SqlCommand listInstances = new SqlCommand("exec MonitoredInstances_GetInstances @Module = 'CheckServers'", conn);
            //SqlDataAdapter adapter = new SqlDataAdapter(listInstances);
            //DataSet instances = new DataSet();
            //adapter.Fill(instances);
            //conn.Close();
            //foreach (DataRow pRow in instances.Tables[0].Rows)
            //{
            //    string Name = (string)pRow["InstanceName"];
            //    if(pRow.IsNull("SSAS") || pRow.IsNull("SSRS"))
            //    {
            //        instance = new Instance(Name);
            //        instance.GatherServices();
            //    }
            //    else
            //    {
            //        SSAS = (bool)pRow["SSAS"];
            //        SSRS = (bool)pRow["SSRS"];
            //        instance = new Instance(Name, SSAS, SSRS);
            //    }
                
            //    instance.TestConnection();
            //    instance.CheckServices();
            //    instance.GatherInstance();
            //}

            //Console.ReadLine();
        }
    }
}
