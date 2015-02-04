CREATE VIEW [History].[vw_MonitoredDrives]
as
select hmd.*,ms.ServerName
from history.monitoredDrives hmd
join monitoredservers ms
on hmd.ServerID = ms.ServerID
