CREATE PROCEDURE [dbo].[MonitoredDatabases_GetDatabases]
@ModuleName varchar(28)
,@InstanceID INT = NULL
as
BEGIN
DECLARE @SQL VARCHAR(MAX)

IF @ModuleName = 'ProcessDatabaseFiles'
	SET @SQL = 'SELECT DISTINCT s.serverID, s.servername,i.instanceID,i.instanceName, db.DatabaseID,db.DatabaseName,COALESCE(DataFiles.DataFileCount,0) as DataFileCount,COALESCE(LogFiles.LogFileCount,0) AS LogFileCount
		FROM MonitoredDatabases db
		JOIN MonitoredInstances i
		ON db.InstanceID = i.instanceId
		JOIN MonitoredServers s
		ON db.ServerID = s.serverid
		LEFT OUTER JOIN MonitoredDatabaseFiles mdf
		ON db.DatabaseID = mdf.DatabaseID
		LEFT OUTER JOIN (SELECT DatabaseID,COUNT(*) as DataFileCount
				FROM MonitoredDatabaseFiles
				WHERE FileType = ''data'' AND Deleted = 0
				group by DatabaseID) AS DataFiles
		ON mdf.DatabaseID = DataFiles.DatabaseID
		LEFT OUTER JOIN (SELECT DatabaseID,COUNT(*) as LogFileCount
				FROM MonitoredDatabaseFiles
				WHERE FileType = ''log'' AND Deleted = 0
				group by DatabaseID) AS LogFiles
		ON mdf.DatabaseID = LogFiles.DatabaseID
		WHERE db.monitordatabasefiles = 1
		AND db.Deleted = 0'
IF @ModuleName = 'ProcessDatabases'
	SET @SQL = 'SELECT DatabaseName, DatabaseGUID
				FROM MonitoredDatabases
				WHERE InstanceID = ' + CAST(@InstanceID AS VARCHAR) + '
				AND Deleted = 0'
IF @ModuleName = 'GatherBackups'
	SET @SQL = 'SELECT distinct mi.InstanceID,mi.InstanceName
				FROM MonitoredDatabases md
				JOIN MonitoredInstances mi
				ON md.InstanceID = mi.InstanceID
				WHERE md.Deleted = 0'

EXEC (@SQL)


END
