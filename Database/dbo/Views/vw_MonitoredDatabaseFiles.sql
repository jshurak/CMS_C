CREATE VIEW [dbo].[vw_MonitoredDatabaseFiles]
AS
SELECT ms.ServerName
      ,mi.[InstanceName]
      ,md.[DatabaseName]
      ,mdf.[LogicalName]
      ,mdf.[PhysicalName]
      ,mdf.[FileSize]
      ,mdf.[UsedSpace]
      ,mdf.[MaxSize]
      ,mdf.[AvailableSpace]
      ,mdf.[PercentageFree]
      ,mdf.[Growth]
      ,mdf.[GrowthType]
      ,mdf.[DateCreated]
      ,mdf.[DateUpdated]
      ,mdf.[MonitorDatabaseFileSpace]
      ,mdf.[DatabaseFileSpaceThreshold]
      ,mdf.[FileType]
      ,mdf.[Directory]
      ,mdr.MountPoint
  FROM [dbo].[MonitoredDatabaseFiles] mdf
  JOIN [dbo].[MonitoredDatabases] md
  ON mdf.DatabaseID = md.DatabaseID
  JOIN [dbo].[MonitoredInstances] mi
  ON mdf.InstanceID = mi.InstanceID
  JOIN [dbo].[MonitoredServers] ms
  ON mi.ServerID = ms.ServerID
  JOIN [dbo].[MonitoredDrives] mdr
  ON mdf.DriveID = mdr.DriveID
