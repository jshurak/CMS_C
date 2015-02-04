CREATE PROCEDURE [dbo].[TrackHistory]
@TrackJobs bit = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @HistoryDate Datetime = GETDATE()

IF @TrackJobs = 0
	BEGIN
		--Record ServerHistory
		INSERT INTO [History].[MonitoredServers]
			   ([HistoryDate]
			   ,[ServerID]
			   ,[ServerName]
			   ,[Environment]
			   ,[MonitorServer]
			   ,[TotalMemory]
			   ,[Manufacturer]
			   ,[Model]
			   ,[IPAddress]
			   ,[OperatingSystem]
			   ,[BitLevel]
			   ,[DateInstalled]
			   ,[NumberofProcessors]
			   ,[NumberofProcessorCores]
			   ,[ProcessorClockSpeed]
			   ,[DateCreated]
			   ,[DateLastBoot]
			   ,[MonitorDrives])
		 SELECT @HistoryDate
		  ,[ServerID]
		  ,[ServerName]
		  ,[Environment]
		  ,[MonitorServer]
		  ,[TotalMemory]
		  ,[Manufacturer]
		  ,[Model]
		  ,[IPAddress]
		  ,[OperatingSystem]
		  ,[BitLevel]
		  ,[DateInstalled]
		  ,[NumberofProcessors]
		  ,[NumberofProcessorCores]
		  ,[ProcessorClockSpeed]
		  ,[DateCreated]
		  ,[DateLastBoot]
		  ,[MonitorDrives]
	  FROM [dbo].[MonitoredServers]
	  WHERE Deleted = 0
	  AND MonitorServer = 1
 
	 --Instances
	INSERT INTO [History].[MonitoredInstances]
			   ([HistoryDate]
			   ,[InstanceID]
			   ,[ServerID]
			   ,[InstanceName]
			   ,[Environment]
			   ,[MonitorInstance]
			   ,[Edition]
			   ,[Version]
			   ,[isClustered]
			   ,[MaxMemory]
			   ,[MinMemory]
			   ,[DateCreated]
			   ,[ServiceAccount]
			   ,[MonitorDatabases]
			   ,[MonitorBlocking]
			   ,[Criticality]
			   ,[ProductLevel])
		SELECT @HistoryDate
				,[InstanceID]
				,[ServerID]
				,[InstanceName]
				,[Environment]
				,[MonitorInstance]
				,[Edition]
				,[Version]
				,[isClustered]
				,[MaxMemory]
				,[MinMemory]
				,[DateCreated]
				,[ServiceAccount]
				,[MonitorDatabases]
				,[MonitorBlocking]
				,[Criticality]
				,[ProductLevel]
			FROM [dbo].[MonitoredInstances]
			WHERE Deleted = 0
			AND MonitorInstance = 1

	--databases
	INSERT INTO [History].[MonitoredDatabases]
			   ([HistoryDate]
			   ,[DatabaseID]
			   ,[ServerID]
			   ,[InstanceID]
			   ,[DatabaseName]
			   ,[CreationDate]
			   ,[CompatibilityLevel]
			   ,[Collation]
			   ,[Size]
			   ,[DataSpaceUsage]
			   ,[IndexSpaceUsage]
			   ,[SpaceAvailable]
			   ,[RecoveryModel]
			   ,[AutoClose]
			   ,[AutoShrink]
			   ,[ReadOnly]
			   ,[PageVerify]
			   ,[Owner]
			   ,[DateCreated]
			   ,[MonitorDatabaseFiles]
			   ,[Status]
			   ,[Deleted]
			   ,[DatabaseGUID])
		SELECT @HistoryDate 
			  ,[DatabaseID]
			  ,[ServerID]
			  ,[InstanceID]
			  ,[DatabaseName]
			  ,[CreationDate]
			  ,[CompatibilityLevel]
			  ,[Collation]
			  ,[Size]
			  ,[DataSpaceUsage]
			  ,[IndexSpaceUsage]
			  ,[SpaceAvailable]
			  ,[RecoveryModel]
			  ,[AutoClose]
			  ,[AutoShrink]
			  ,[ReadOnly]
			  ,[PageVerify]
			  ,[Owner]
			  ,[DateCreated]
			  ,[MonitorDatabaseFiles]
			  ,[Status]
			  ,[Deleted]
			  ,[DatabaseGUID]
		  FROM [dbo].[MonitoredDatabases]
		  WHERE Deleted = 0
		  

		  --Drives
		  INSERT INTO [History].[MonitoredDrives]
			   ([HistoryDate]
			   ,[DriveID]
			   ,[ServerID]
			   ,[TotalCapacity]
			   ,[FreeSpace]
			   ,[PercentFreeThreshold]
			   ,[DateCreated]
			   ,[VolumeName]
			   ,[MountPoint]
			   ,[DeviceID])
		SELECT @HistoryDate 
			  ,[DriveID]
			  ,[ServerID]
			  ,[TotalCapacity]
			  ,[FreeSpace]
			  ,[PercentFreeThreshold]
			  ,[DateCreated]
			  ,[VolumeName]
			  ,[MountPoint]
			  ,[DeviceID]
		  FROM [dbo].[MonitoredDrives]
		  WHERE Deleted = 0

		-- Database Files
		INSERT INTO [History].[MonitoredDatabaseFiles]
			   ([HistoryDate]
			   ,[DatabaseFileID]
			   ,[InstanceID]
			   ,[DatabaseID]
			   ,[LogicalName]
			   ,[PhysicalName]
			   ,[FileSize]
			   ,[UsedSpace]
			   ,[MaxSize]
			   ,[AvailableSpace]
			   ,[PercentageFree]
			   ,[Growth]
			   ,[GrowthType]
			   ,[DateCreated]
			   ,[MonitorDatabaseFileSpace]
			   ,[DatabaseFileSpaceThreshold]
			   ,[FileType]
			   ,[Directory]
			   ,[DriveID])
			SELECT @HistoryDate
				  ,[DatabaseFileID]
				  ,[InstanceID]
				  ,[DatabaseID]
				  ,[LogicalName]
				  ,[PhysicalName]
				  ,[FileSize]
				  ,[UsedSpace]
				  ,[MaxSize]
				  ,[AvailableSpace]
				  ,[PercentageFree]
				  ,[Growth]
				  ,[GrowthType]
				  ,[DateCreated]
				  ,[MonitorDatabaseFileSpace]
				  ,[DatabaseFileSpaceThreshold]
				  ,[FileType]
				  ,[Directory]
				  ,[DriveID]
			  FROM [dbo].[MonitoredDatabaseFiles]
			  WHERE Deleted = 0
	END
IF @TrackJobs = 1
	BEGIN
		INSERT INTO History.MonitoredInstanceJobs
		SELECT @HistoryDate,
			   mj.[JobID]
			  ,mj.[LastRunDate]
			  ,mj.[JobOutcome]
			  ,mj.[JobDuration]
		  FROM [dbo].[MonitoredInstanceJobs] mj
		  LEFT OUTER JOIN [History].[MonitoredInstanceJobs] hj
		  ON mj.JobID = hj.JobID 
		  AND mj.LastRunDate = hj.LastRunDate
		  WHERE hj.HistoryId is null
		  AND mj.Deleted = 0
		  AND mj.MonitorJob = 1
	END
END
