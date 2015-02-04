CREATE VIEW [dbo].[vw_MonitoredDrives]
AS
SELECT ms.[ServerName]
      ,md.[TotalCapacity]
      ,md.[FreeSpace]
      ,md.[PercentFreeThreshold]
      ,md.[DateCreated]
      ,md.[DateUpdated]
      ,md.[VolumeName]
      ,md.[MountPoint]
      ,md.[DeviceID]
      ,md.[PercentageFree]
      ,md.[Deleted]
      ,md.[DateDeleted]
  FROM [dbo].[MonitoredDrives] md
  JOIN [dbo].[MonitoredServers] ms
  ON md.ServerID = ms.ServerID
