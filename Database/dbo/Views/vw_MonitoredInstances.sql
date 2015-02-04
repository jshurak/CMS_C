CREATE VIEW [dbo].[vw_MonitoredInstances]
AS
SELECT ms.ServerName 
	  ,mi.[InstanceName]
      ,mi.[MonitorInstance]
      ,mi.[Edition]
      ,mi.[Version]
      ,mi.[isClustered]
      ,mi.[MaxMemory]
      ,mi.[MinMemory]
      ,mi.[DateCreated]
      ,mi.[ServiceAccount]
      ,mi.[DateUpdated]
      ,mi.[MonitorDatabases]
      ,mi.[MonitorBlocking]
      ,mi.[Criticality]
  FROM [dbo].[MonitoredInstances] mi
  JOIN [dbo].[MonitoredServers] ms
  ON mi.ServerID = ms.ServerID
