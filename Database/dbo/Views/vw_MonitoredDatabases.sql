CREATE VIEW [dbo].[vw_MonitoredDatabases]
AS
SELECT ms.ServerName
	  ,mi.InstanceName
      ,md.[DatabaseName]
      ,md.[CreationDate]
      ,md.[CompatibilityLevel]
      ,md.[Collation]
      ,md.[Size]
      ,md.[DataSpaceUsage]
      ,md.[IndexSpaceUsage]
      ,md.[SpaceAvailable]
      ,md.[RecoveryModel]
      ,md.[AutoClose]
      ,md.[AutoShrink]
      ,md.[ReadOnly]
      ,md.[PageVerify]
      ,md.[Owner]
      ,md.[DateCreated]
      ,md.[Dateupdated]
      ,md.[MonitorDatabaseFiles]
      ,md.[Status]
      ,md.[Deleted]
      ,md.[FBThreshold]
      ,md.[FullBackupFlag]
      ,md.[DBThreshold]
      ,md.[DiffBackupFlag]
      ,md.[TBThreshold]
      ,md.[TranBackupFlag]
      ,md.[DateDeleted]
  FROM [dbo].[MonitoredDatabases] md
  JOIN [dbo].[MonitoredInstances] mi
  ON md.InstanceID = mi.InstanceID
  JOIN [dbo].[MonitoredServers] ms
  ON md.ServerID = ms.ServerID
