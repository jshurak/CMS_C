CREATE VIEW [History].[vw_MonitoredDatabases]
as
select hmd.*,mi.InstanceName,ms.ServerName
from history.monitoreddatabases hmd
join monitoredinstances mi
on hmd.InstanceID = mi.InstanceID
join monitoredservers ms
on hmd.ServerID = ms.ServerID
