CREATE PROCEDURE [dbo].[MonitoredServers_GetServers]
@ModuleName varchar(128)
as
BEGIN
DECLARE @SQL varchar(max)

IF @ModuleName = 'ProcessServers'
	SET @SQL = N'SELECT ServerID,ServerName,IsVirtualServerName FROM MonitoredServers WHERE MonitorServer = 1 AND Deleted = 0'
ELSE IF @ModuleName = 'ProcessDrives' 
	SET @SQL = N'SELECT ms.ServerID,ms.ServerName,ms.IsVirtualServerName,COALESCE(MCD.IsPartofCluster,0) AS IsPartOfCluster
					FROM MonitoredServers ms
					LEFT OUTER JOIN (
					select distinct ServerID, 1 as IsPartofCluster
					from MonitoredClusterDetails
					) AS mcd
					on ms.ServerID = mcd.ServerID
					WHERE ms.MonitorDrives = 1 AND ms.Deleted = 0'

exec (@SQL)
END
