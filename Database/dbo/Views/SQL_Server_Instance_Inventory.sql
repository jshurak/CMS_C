CREATE VIEW [dbo].[SQL_Server_Instance_Inventory]
	AS 
SELECT mi.InstanceName,mi.Version,mi.Edition,mi.ProductLevel
,CASE
	WHEN mi.isClustered = 0 THEN 'STANDALONE'
	ELSE 'CLUSTERED'
END [Type]
,ms.ServerName
,ms.NumberofProcessorCores as Cores
,ms.NumberofProcessors as Processors
,mi.MaxMemory as Memory
FROM monitoredinstances mi
JOIN MonitoredServers ms
ON ms.ServerID = mi.ServerID
where mi.Deleted = 0
