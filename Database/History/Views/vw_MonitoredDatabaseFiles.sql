CREATE VIEW [History].[vw_MonitoredDatabaseFiles]
as
select hmdf.*,md.DatabaseName,mi.InstanceName,ms.servername
from History.MonitoredDatabaseFiles hmdf
JOIN MonitoredDatabases md
ON hmdf.DatabaseID = md.DatabaseID
JOIN MonitoredInstances mi
on md.InstanceID = mi.InstanceID
join monitoredservers ms
on md.ServerID = ms.serverid
