using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace CMS_C
{
    class Program
    {
        static void Main(string[] args)
        {
            SqlConnectionStringBuilder connectionstring = new SqlConnectionStringBuilder();
            connectionstring["Data Source"] = "PHLDVWSSQL002\\DVS1201";
            connectionstring["Database"] = "CMS_Dev";
            connectionstring["Integrated Security"] = true;
            connectionstring["Connect Timeout"] = 3;
            SqlConnection conn = new SqlConnection(connectionstring.ConnectionString);
            conn.Open();
            SqlCommand listInstances = new SqlCommand("exec MonitoredInstances_GetInstances @Module = 'CheckServers'",conn);
            SqlDataAdapter adapter = new SqlDataAdapter(listInstances);
            DataSet instances = new DataSet();
            adapter.Fill(instances);
            conn.Close();
            foreach(DataRow pRow in instances.Tables[0].Rows)
            {
                string Name = (string)pRow["InstanceName"];
                bool SSAS = (bool)pRow["SSAS"];
                bool SSRS = (bool)pRow["SSRS"];
                Instance instance = new Instance(Name,SSAS,SSRS);
                instance.TestConnection();
                instance.CheckServices();
                instance.GatherInstance();
            }

            Console.ReadLine();
        }
    }
}
