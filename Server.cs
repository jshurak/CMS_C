using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Net.NetworkInformation;
using System.Net;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using log4net;

namespace CMS_C
{
    public class Server
    {


        public Server(string Name)
        {
            serverName = Name;       
            _scope = new ManagementScope("\\\\" + serverName + "\\root\\cimv2");
        }
        public Server(int ServerID,string Name)
        {
            serverName = Name;
            _serverID = ServerID;
            _scope = new ManagementScope("\\\\" + serverName + "\\root\\cimv2");
        }

        public Server(int ServerID, string Name, bool IsVirtualServerName)
        {
            serverName = Name;
            _serverID = ServerID;
            _scope = new ManagementScope("\\\\" + serverName + "\\root\\cimv2");
            if(IsVirtualServerName)
            {
                isVirtualServerName = IsVirtualServerName;
                ConnectionOptions _connectionOptions = new ConnectionOptions();
                _connectionOptions.Authentication = AuthenticationLevel.PacketPrivacy;
                _clusterScope = new ManagementScope("\\\\" + serverName + "\\root\\mscluster",_connectionOptions);   
            }
        }

        private int _serverID;
        public string serverName { get; set; }
        public ulong totalMemory { get; set; }
        public string manufacturer { get; set; }
        public string model { get; set; }
        public string ipAddress { get; set; }
        public string operatingSystem { get; set; }
        public string bitLevel { get; set; }
        public DateTime dateInstalled { get; set; }
        public int numProcessors { get; set; }
        public UInt32 numCores { get; set; }
        public DateTime dateLastBoot { get; set; }
        public bool pingStatus { get; set; }
        public bool isVirtualServerName { get; set; }
        public UInt32 clockSpeed;
        private string _clusterName;
        private ManagementScope _scope;
        private ManagementScope _clusterScope;
        static string repository = ConfigurationManager.ConnectionStrings["Repository"].ConnectionString;
        SqlConnection repConn = new SqlConnection(repository);
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod
().DeclaringType);
        
        public void GatherServer(List<Instance> InstanceList)
        {
            int _clusterID;
            try
            {
                IPAddress[] addresslist = Dns.GetHostAddresses(serverName);
                ManagementObjectCollection _osCollection = GatherServerInfo("SELECT * FROM Win32_OperatingSystem", _scope);
                ManagementObjectCollection _csCollection = GatherServerInfo("SELECT * FROM Win32_ComputerSystem", _scope);
                ManagementObjectCollection _cpuCollection = GatherServerInfo("SELECT * FROM Win32_processor", _scope);
                
                //Process Clusters here
                if(isVirtualServerName)
                {

                    ManagementObjectCollection _clusterCollection = GatherServerInfo("SELECT * FROM MSCluster_Cluster", _clusterScope);
                    if(_clusterCollection != null)
                    {
                        foreach (ManagementObject _cluster in _clusterCollection)
                        {
                            _clusterName = _cluster["Name"].ToString();
                        }
                        using (SqlCommand cmd = new SqlCommand("dbo.MonitoredClusters_SetCluster", repConn))
                        {

                            cmd.Parameters.Clear();
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ClusterName", SqlDbType.VarChar).Value = _clusterName;
                            SqlParameter _returnValue = cmd.Parameters.Add("@ClusterID", SqlDbType.Int);
                            _returnValue.Direction = ParameterDirection.ReturnValue;

                            if (repConn != null && repConn.State == ConnectionState.Closed)
                            {
                                repConn.Open();
                            }
                            cmd.ExecuteNonQuery();
                            _clusterID = (int)_returnValue.Value;
                        }
                        Instance _instance = InstanceList.Find(i => i.ServerID == _serverID);
                        DataSet _nodes = _instance.GatherClusterNodes();
                        foreach (DataRow pRow in _nodes.Tables[0].Rows)
                        {
                            using (SqlCommand _detailCmd = new SqlCommand("dbo.MonitoredClusters_SetDetails", repConn))
                            {
                                bool _isOwner = false;
                                if (object.Equals(pRow["NodeName"], pRow["Owner"]))
                                {
                                    _isOwner = true;
                                }

                                _detailCmd.Parameters.Clear();
                                _detailCmd.CommandType = CommandType.StoredProcedure;
                                _detailCmd.Parameters.Add("@ClusterID", SqlDbType.Int).Value = _clusterID;
                                _detailCmd.Parameters.Add("@InstanceID", SqlDbType.Int).Value = _instance.InstanceID;
                                _detailCmd.Parameters.Add("@NodeName", SqlDbType.VarChar).Value = pRow["NodeName"].ToString();
                                _detailCmd.Parameters.Add("@IsCurrentOwner", SqlDbType.Bit).Value = _isOwner;

                                if (repConn != null && repConn.State == ConnectionState.Closed)
                                {
                                    repConn.Open();
                                }
                                _detailCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    else
                    {
                        log.Warn("Server: " + this.serverName + " Message: Error collecting cluster info.");
                    }
<<<<<<< HEAD
                    
=======
>>>>>>> Parallelism

                }
                

                foreach(IPAddress ip in addresslist)
                {
                    ipAddress = ip.ToString();
                }
                if(_osCollection != null)
                {
                    foreach (ManagementObject _os in _osCollection)
                    {
                        operatingSystem = _os["Caption"].ToString();
                        dateInstalled = ManagementDateTimeConverter.ToDateTime(_os["InstallDate"].ToString());
                        dateLastBoot = ManagementDateTimeConverter.ToDateTime(_os["LastBootUpTime"].ToString());
                        if (!operatingSystem.Contains("2003"))
                        {
                            bitLevel = _os["OSArchitecture"].ToString().Substring(0, 2);
                        }
                    }
                }
                else
                {
                    log.Warn("Server: " + this.serverName + " Message: Error collecting operating system info.");
                }
                if(_csCollection != null)
                {
                    foreach (ManagementObject _cs in _csCollection)
                    {
                        manufacturer = _cs["Manufacturer"].ToString();
                        model = _cs["Model"].ToString();
                        totalMemory = (ulong)_cs["TotalPhysicalMemory"];
                    }
                }
                else
                {
                    log.Warn("Server: " + this.serverName + " Message: Error collecting computer system info.");
                }
                if(_cpuCollection != null)
                {
                    numProcessors = _cpuCollection.Count;
                    foreach (ManagementObject _cpu in _cpuCollection)
                    {

                        clockSpeed = (UInt32)_cpu["CurrentClockSpeed"];
                        if (operatingSystem.Contains("2003"))
                        {
                            numCores = (uint)numProcessors;
                            bitLevel = _cpu["AddressWidth"].ToString().Substring(0, 2);
                        }
                        else
                        {
                            numCores = (UInt32)_cpu["NumberOfCores"];
                        }
                    }
                }
                else
                {
                    log.Warn("Server: " + this.serverName + " Message: Error collecting cpu info.");
                }
                

                using (SqlCommand cmd = new SqlCommand("dbo.MonitoredServers_SetServer", repConn))
                {
                    
                    cmd.Parameters.Clear();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ServerName",SqlDbType.VarChar).Value = serverName;
                    cmd.Parameters.Add("@Manufacturer", SqlDbType.VarChar).Value = manufacturer;
                    cmd.Parameters.Add("@Model", SqlDbType.VarChar).Value = model;
                    cmd.Parameters.Add("@IPAddress", SqlDbType.VarChar).Value = ipAddress;
                    cmd.Parameters.Add("@OperatingSystem", SqlDbType.VarChar).Value = operatingSystem;
                    cmd.Parameters.Add("@BitLevel", SqlDbType.Char).Value = bitLevel;
                    cmd.Parameters.Add("@TotalMemory", SqlDbType.BigInt).Value = totalMemory;
                    cmd.Parameters.Add("@DateInstalled", SqlDbType.DateTime).Value = dateInstalled;
                    cmd.Parameters.Add("@DateLastBoot", SqlDbType.DateTime).Value = dateLastBoot;
                    cmd.Parameters.Add("@NumberOfProcessors", SqlDbType.TinyInt).Value = numProcessors;
                    cmd.Parameters.Add("@NumberOfProcessorCores", SqlDbType.TinyInt).Value = numCores;
                    cmd.Parameters.Add("@ProcessorClockSpeed", SqlDbType.SmallInt).Value = clockSpeed;

                    if (repConn != null && repConn.State == ConnectionState.Closed)
                    {
                        repConn.Open();
                    }
                    cmd.ExecuteNonQuery();
                }

            }
            catch (SqlException ex)
            {
                log.Error("Instance: " + ex.Server + ". " + ex.Message);
                //EventLogger.LogEvent(e.ToString(), "Error");
            }
            finally
            {
                repConn.Close();
            }

        }
        public void GatherDrives()
        {
            try
            {
                ManagementObjectCollection _driveCollection = GatherServerInfo("SELECT * FROM win32_Volume", _scope);
                if (repConn != null && repConn.State == ConnectionState.Closed)
                {
                    repConn.Open();
                }
                if(_driveCollection != null)
                {
                    foreach (ManagementObject _drive in _driveCollection)
                    {
                        if (!(String.IsNullOrEmpty(Convert.ToString(_drive["DriveType"]))) &&
                                (UInt32)_drive["DriveType"] >= 2 && (UInt32)_drive["DriveType"] <= 4)
                        {
                            string _mountPoint = _drive["Name"].ToString();
                            UInt64 _totalCapacity = (UInt64)_drive["Capacity"];
                            UInt64 _freeSpace = (UInt64)_drive["FreeSpace"];
                            string _volumeName = String.IsNullOrEmpty(Convert.ToString(_drive["Label"])) ? "" : _drive["Label"].ToString();
                            string _deviceID = _drive["DeviceID"].ToString().Substring(_drive["DeviceID"].ToString().IndexOf("{") + 1, _drive["DeviceID"].ToString().IndexOf("}") - _drive["DeviceID"].ToString().IndexOf("{") - 1);

                            using (SqlCommand driveCmd = new SqlCommand("dbo.MonitoredDrives_SetDrives", repConn))
                            {
                                driveCmd.Parameters.Clear();
                                driveCmd.CommandType = CommandType.StoredProcedure;
                                driveCmd.Parameters.Add("@ServerID", SqlDbType.Int).Value = _serverID;
                                driveCmd.Parameters.Add("@DeviceID", SqlDbType.VarChar).Value = _deviceID;
                                driveCmd.Parameters.Add("@MountPoint", SqlDbType.VarChar).Value = _mountPoint;
                                driveCmd.Parameters.Add("@TotalCapacity", SqlDbType.BigInt).Value = _totalCapacity;
                                driveCmd.Parameters.Add("@FreeSpace", SqlDbType.BigInt).Value = _freeSpace;
                                driveCmd.Parameters.Add("@VolumeName", SqlDbType.VarChar).Value = _volumeName;

                                if (repConn != null && repConn.State == ConnectionState.Closed)
                                {
                                    repConn.Open();
                                }
                                driveCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
                else
                {
                    log.Warn("Server: " + this.serverName + " Message: Error collecting drive info." );
                }
            }
            catch(NullReferenceException ex)
            {
                log.Error(ex.Message);
                //EventLogger.LogEvent(serverName + e.ToString(), "Warning");
            }
            catch (SqlException ex)
            {
                log.Error("Instance: " + ex.Server + ". " + ex.Message);
                //EventLogger.LogEvent(serverName + e.ToString(), "Error");
            }
            finally
            {
                repConn.Close();
            }
        }
        private ManagementObjectCollection GatherServerInfo(string Query, ManagementScope Scope)
        {

            ManagementObjectCollection queryCollection = null;
            try
            {
                ManagementScope _scope = Scope;
                ObjectQuery _query = new ObjectQuery(Query);
                ManagementObjectSearcher searcher = new ManagementObjectSearcher(_scope, _query);
                _scope.Connect();
                queryCollection = searcher.Get();
                
            }
            catch (Exception ex)
            {
                log.Error(ex.Message);    
            }
            return queryCollection;

            

        }
        
    }
}
