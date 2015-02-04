CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_SetDatabaseFiles]
@InstanceID int
,@DatabaseID int = NULL
,@LogicalName varchar(60) = null
,@PhysicalName varchar(60) = null
,@Directory varchar(250) = null
,@FileType varchar(10) = null 
,@FileSize float = null
,@UsedSpace float = null
,@AvailableSpace float = null
,@PercentageFree decimal(4,3) = null
,@MaxSize float = null
,@Growth float = null
,@GrowthType varchar(60) = null
,@Deleted bit = 0
,@DatabaseFileID int = null
,@DatabaseGUID varchar(36)
AS
BEGIN

	DECLARE @dbfid table (id int)
	SELECT @DatabaseID = DatabaseID FROM dbo.MonitoredDatabases WHERE InstanceID = @InstanceID AND DatabaseGUID = @DatabaseGUID
	IF NOT EXISTS(SELECT DatabaseFileID FROM MonitoredDatabaseFiles WHERE InstanceID = @InstanceID and DatabaseID = @DatabaseID and PhysicalName = @PhysicalName)
		BEGIN
			INSERT INTO MonitoredDatabaseFiles
				(InstanceID,DatabaseID,LogicalName,PhysicalName,Directory,FileType,FileSize,UsedSpace,AvailableSpace,PercentageFree,MaxSize,Growth,GrowthType,Deleted)
			Values
				(@InstanceID,@DatabaseID,@LogicalName,@PhysicalName,LTRIM(RTRIM(@Directory)),@FileType,@FileSize,@UsedSpace,@AvailableSpace,@PercentageFree,@MaxSize,@Growth,@GrowthType,0)
			SELECT @DatabaseFileID = SCOPE_IDENTITY()
			EXEC [dbo].[MonitoredDatabaseFiles_SetDriveID] @DatabaseFileID
		END
	ELSE IF (@Deleted = 1)
	BEGIN
		UPDATE MonitoredDatabaseFiles
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		DateUpdated = GETDATE()
		WHERE InstanceID = @InstanceID
		AND DatabaseID = @DatabaseID
		AND DatabaseFileID = @DatabaseFileID
	END
	ELSE
		UPDATE MonitoredDatabaseFiles
		SET [LogicalName] = @LogicalName
			  ,[PhysicalName] = @PhysicalName
			  ,[Directory] = LTRIM(RTRIM(@Directory))
			  ,[FileType] = @FileType
			  ,[FileSize] = @FileSize
			  ,[UsedSpace] = @UsedSpace
			  ,[MaxSize] = @MaxSize
			  ,[AvailableSpace] = @AvailableSpace
			  ,[PercentageFree] = @PercentageFree
			  ,[Growth] = @Growth
			  ,[GrowthType] = @Growthtype
			  ,[DateUpdated] = GETDATE()
			  ,[Deleted] = 0
			  ,[DateDeleted] = null
		OUTPUT inserted.DatabaseFileID INTO @dbfid
		WHERE
			InstanceID = @InstanceID
			and DatabaseID = @DatabaseID
			and PhysicalName = @PhysicalName
		SELECT top 1 @DatabaseFileID = id FROM @dbfid
		EXEC [dbo].[MonitoredDatabaseFiles_SetDriveID] @DatabaseFileID
END
