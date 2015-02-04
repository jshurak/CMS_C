CREATE PROCEDURE [dbo].[MonitoredDatabases_SetDatabases]
@ServerID int
,@InstanceID int
,@Databasename varchar(128)
,@CreationDate datetime = null
,@CompatibilityLevel int = null
,@Collation varchar(60) = null
,@size int = null
,@DataSpaceUsage int = null
,@IndexSpaceUsage int = null
,@SpaceAvailable int = null
,@RecoveryModel varchar(25) = null
,@AutoClose bit = null
,@AutoShrink bit = null
,@ReadOnly bit = null
,@PageVerify varchar(25) = null
,@Owner varchar(60) = null
,@Status varchar(60) = null
,@Deleted BIT = null
,@GUID varchar(36)
AS
BEGIN
	DECLARE @TBFlag BIT = 1
	
	IF NOT EXISTS (SELECT DatabaseID FROM MonitoredDatabases WHERE ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID)
	BEGIN
		INSERT INTO [dbo].[MonitoredDatabases]
           ([ServerID],[InstanceID],[DatabaseName],[CreationDate],[CompatibilityLevel],[Collation],[Size],[DataSpaceUsage],[IndexSpaceUsage],[SpaceAvailable],[RecoveryModel],[AutoClose],[AutoShrink],[ReadOnly],[PageVerify],[Owner],[DateCreated],[Dateupdated],[Status],[DatabaseGUID],[Deleted])
		VALUES
           (@ServerID,@InstanceID,@Databasename,@CreationDate,@CompatibilityLevel,@Collation,@size,@DataSpaceUsage,@IndexSpaceUsage,@SpaceAvailable,@RecoveryModel,@AutoClose,@AutoShrink,@ReadOnly,@PageVerify,@Owner,getdate(),getdate(),@Status,@GUID,0)

		   exec CacheUpdateController @CacheName = 'Database', @Refresh = 1;
	END
    ELSE IF @Deleted = 1
	BEGIN
		UPDATE MonitoredDatabases
		SET Dateupdated = getdate()
		,Deleted = @Deleted
		,DateDeleted = getdate()
		WHERE ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID
	
		exec CacheUpdateController @CacheName = 'Database',@Refresh = 1;
	END
	ELSE
		UPDATE MonitoredDatabases
		   SET 
		   [DatabaseName] = @Databasename
		  ,[CreationDate] = @CreationDate
		  ,[CompatibilityLevel] = @CompatibilityLevel
		  ,[Collation] = @Collation
		  ,[Size] = @size
		  ,[DataSpaceUsage] = @DataSpaceUsage
		  ,[IndexSpaceUsage] = @IndexSpaceUsage
		  ,[SpaceAvailable] = @SpaceAvailable
		  ,[RecoveryModel] = @RecoveryModel
		  ,[AutoClose] = @AutoClose
		  ,[AutoShrink] = @AutoShrink
		  ,[ReadOnly] = @ReadOnly
		  ,[PageVerify] = @PageVerify
		  ,[Owner] = @Owner
		  ,[Dateupdated] = getdate()
		  ,[Status] = @Status
		  ,[Deleted] = @Deleted
		WHERE 	
			ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID
END
