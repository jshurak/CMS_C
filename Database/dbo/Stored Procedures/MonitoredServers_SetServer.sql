CREATE PROCEDURE [dbo].[MonitoredServers_SetServer]
@ServerName varchar(128) = null
,@ServerID int = null
,@TotalMemory bigint = null
,@Manufacturer varchar(128) = null
,@Model varchar(128) = null
,@IPAddress varchar(15) = null
,@OperatingSystem varchar(128) = null
,@BitLevel char(2) = null
,@DateInstalled datetime = null
,@DateLastBoot datetime = null
,@NumberofProcessors tinyint = null
,@NumberofProcessorCores tinyint = null
,@ProcessorClockSpeed smallint = null
,@PingStatus bit = 1
,@PingTest bit = 0
,@VSN bit = 0
,@InstanceID int = null
,@Environment varchar(128) = 'PRODUCTION'
AS
BEGIN
	--Check for existence of server
	

	IF NOT EXISTS(SELECT ServerID FROM MonitoredServers WHERE ServerName = @ServerName)
	BEGIN
		INSERT INTO [dbo].[MonitoredServers]
			([ServerName],[MonitorServer],[TotalMemory],[Manufacturer],[Model],[IPAddress],[OperatingSystem],[BitLevel],[DateInstalled],[NumberofProcessors],[NumberofProcessorCores],[ProcessorClockSpeed],[DateCreated],[DateUpdated],[DateLastBoot],[MonitorDrives],[PingStatus],[Deleted],[IsVirtualServerName],[Environment])
		VALUES
			(@ServerName,1,@TotalMemory,@Manufacturer,@Model,@IPAddress,@OperatingSystem,@BitLevel,@DateInstalled,@NumberofProcessors,@NumberofProcessorCores,@ProcessorClockSpeed,getdate(),getdate(),@DateLastBoot,1,@PingStatus,0,@VSN,@Environment)
		
		EXEC CacheUpdateController @CacheName = 'Server', @Refresh =1
	END
	ELSE IF @PingTest = 1
		UPDATE [dbo].[MonitoredServers]
		SET PingStatus = @PingStatus
		WHERE ServerName = @ServerName
	ELSE IF @VSN = 1
	BEGIN
		SELECT @ServerID = ServerID
		FROM MonitoredClusterDetails
		WHERE InstanceID = @InstanceID
		AND IsCurrentOwner = 1

		UPDATE ms2
		SET
			 ms2.[Environment] = ms.[Environment]
			,ms2.[MonitorServer] = ms.[MonitorServer]
			,ms2.[TotalMemory] = ms.[TotalMemory]
			,ms2.[Manufacturer] = ms.[Manufacturer]
			,ms2.[Model] = ms.[Model]
			,ms2.[OperatingSystem] = ms.[OperatingSystem]
			,ms2.[BitLevel] = ms.[BitLevel]
			,ms2.[DateInstalled] = ms.[DateInstalled]
			,ms2.[NumberofProcessors] = ms.[NumberofProcessors]
			,ms2.[NumberofProcessorCores] = ms.[NumberofProcessorCores]
			,ms2.[ProcessorClockSpeed] = ms.[ProcessorClockSpeed]
			,ms2.[DateUpdated] = GETDATE()
			,ms2.[DateLastBoot] = ms.[DateLastBoot]
			,ms2.[MonitorDrives] = ms.[MonitorDrives]
			,ms2.[PingStatus] = ms.[PingStatus]
			,ms2.[Deleted] = ms.[Deleted]
			,ms2.[DateDeleted] = ms.[DateDeleted]
			,ms2.[IPAddress] = @IPAddress
		FROM [dbo].[MonitoredServers] ms,
		[dbo].[MonitoredServers] ms2
		WHERE ms2.ServerName = @ServerName
		AND ms.ServerID = @ServerID
	END
	ELSE 
	UPDATE [dbo].[MonitoredServers]
		   SET [TotalMemory] = @TotalMemory
			  ,[Manufacturer] = @Manufacturer
			  ,[Model] = @Model
			  ,[IPAddress] = @IPAddress
			  ,[OperatingSystem] = @OperatingSystem
			  ,[BitLevel] = @BitLevel
			  ,[DateInstalled] = @DateInstalled
			  ,[NumberofProcessors] = @NumberofProcessors
			  ,[NumberofProcessorCores] = @NumberofProcessorCores
			  ,[ProcessorClockSpeed] = @ProcessorClockSpeed
			  ,[DateUpdated] = GETDATE()
			  ,[DateLastBoot] = @DateLastBoot
			  ,[PingStatus] = @PingStatus
			  ,[Deleted] = 0
			  ,[DateDeleted] = null
		 WHERE ServerName = @ServerName

END
