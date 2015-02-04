CREATE VIEW [History].[vw_MonitoredInstances]
AS
SELECT hmi.*,ms.ServerName
FROM history.MonitoredInstances hmi
JOIN MonitoredServers ms
ON hmi.ServerID = ms.ServerID
