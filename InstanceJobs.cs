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
            //string connectionString = ConfigurationManager.ConnectionStrings("Repository");
            SqlConnectionStringBuilder connectionString = new SqlConnectionStringBuilder();
            connectionString["Data Source"] = "PHLDVWSSQL002\\DVS1201";
            connectionString["Initial Catalog"] = "CMS";
            connectionString["Timeout"] = 3;
            connectionString["Integrated Security"] = true;
          
            SqlConnection conn = new SqlConnection(connectionString.ConnectionString);
            
            conn.Open();
            SqlCommand listInstances = new SqlCommand("exec MonitoredInstances_GetInstances @Module = 'CheckServers'", conn);
            SqlDataAdapter adapter = new SqlDataAdapter(listInstances);
            DataSet instances = new DataSet();
            adapter.Fill(instances);
            conn.Close();
            foreach (DataRow pRow in instances.Tables[0].Rows)
            {
                string Name = (string)pRow["InstanceName"];
                bool SSAS = (bool)pRow["SSAS"];
                bool SSRS = (bool)pRow["SSRS"];
                Instance instance = new Instance(Name, SSAS, SSRS);
                instance.TestConnection();
                instance.CheckServices();
                instance.GatherInstance();
            }

            Console.ReadLine();
        }
    }
}
