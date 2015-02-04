CREATE PROCEDURE [dbo].[MonitoredInstances_GetInstances]
@Module varchar(128) = null,
@ServerID int = NULL
AS
DECLARE @SQL varchar(max)

       SET @SQL = N'SELECT mi.ServerID,ms.ServerName,mi.INSTANCEID,mi.INSTANCENAME 
					FROM MonitoredInstances mi 
					JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
					WHERE mi.MonitorInstance = 1 AND mi.Deleted = 0'
IF @Module = 'ProcessDatabases'
       SET @SQL = N'SELECT mi.ServerID,mi.INSTANCEID,mi.INSTANCENAME,COALESCE(DBCount.DatabaseCount,0) AS DatabaseCount
					FROM MonitoredInstances mi
					LEFT OUTER JOIN 
					(select InstanceID, Count(DatabaseID) as DatabaseCount
					from MonitoredDatabases
					WHERE Deleted = 0
					group by InstanceID) AS DBCount
					ON mi.InstanceID = DBCount.InstanceID
					WHERE MonitorDatabases = 1 AND mi.Deleted = 0'
ELSE IF @Module = 'GatherBlocking'
       SET @SQL = N'SELECT InstanceName,InstanceID FROM MonitoredInstances WHERE MonitorBlocking = 1 AND Deleted = 0'
ELSE IF @Module = 'ProcessAvailabilityGroups'
	   SET @SQL = N'SELECT mi.ServerID, mi.InstanceID,mi.InstanceName
					FROM MonitoredInstances mi
					WHERE mi.MonitorInstance = 1 AND DELETED = 0 AND CAST(LEFT(Version,2) AS INT) >= 11 AND mi.Edition LIKE ''Enterprise%''' 
ELSE IF @Module = 'ProcessDrives'
	   SET @SQL = N'SELECT mi.InstanceID,mi.InstanceName,mi.ServerID,CO.ServerName
					FROM MonitoredInstances mi
					JOIN 
					(
						SELECT mcd.InstanceID,mcd.ServerID,ms.ServerName
						FROM MonitoredClusterDetails mcd
						JOIN MonitoredServers ms
						ON mcd.ServerID = ms.ServerID
						WHERE mcd.IsCurrentOwner = 1
					) as CO
					ON mi.InstanceID = CO.InstanceID
					JOIN MonitoredServers ms
					ON mi.ServerID = ms.ServerID
					WHERE ms.ServerID = ' + CAST(@ServerID as varchar)
ELSE IF @Module = 'CheckServers'
		SET @SQL = N'SELECT ms.ServerID,ms.Servername,mi.InstanceID,mi.InstanceName,mi.SSAS,mi.SSRS
					FROM MonitoredInstances mi
					INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
					WHERE mi.MonitorInstance = 1 AND mi.Deleted = 0'
ELSE IF	@Module = 'GatherInstanceWaitStats'
		SET @SQL = N'SELECT InstanceID,InstanceName
					FROM MonitoredInstances
					WHERE Deleted = 0 AND MonitorWaitStats = 1'
exec (@sql)
