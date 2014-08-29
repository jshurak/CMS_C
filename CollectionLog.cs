using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.CompilerServices;

namespace CMS_C
{
    public class CollectionLog
    {
        private string _moduleName;
        private long _logID;
        private string repository;

        public long LogModule([CallerMemberName] string ModuleName = null)
        {
            _moduleName = ModuleName;
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
            using (SqlConnection repConn = new SqlConnection(repository))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.LogModule", repConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ModuleName", SqlDbType.VarChar).Value = _moduleName;

                    try
                    {
                        repConn.Open();
                        _logID = (long)cmd.ExecuteScalar();
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                    }

                }
            }

            return _logID;
        }

        public void LogModule( long LogID, [CallerMemberName] string ModuleName = null)
        {
            _moduleName = ModuleName;
            _logID = LogID;
            string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
            using (SqlConnection repConn = new SqlConnection(repository))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.LogModule", repConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ModuleName", SqlDbType.VarChar).Value = _moduleName;
                    cmd.Parameters.Add("@LogID", SqlDbType.BigInt).Value = _logID;

                    try
                    {
                        repConn.Open();
                        cmd.ExecuteScalar();
                        repConn.Close();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                    }
                }
            }
        }
    }
}
