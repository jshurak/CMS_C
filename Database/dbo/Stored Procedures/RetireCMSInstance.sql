CREATE PROCEDURE [dbo].[RetireCMSInstance]
	@InstanceID int = null,
	@InstanceName varchar(128) = null
AS
	DECLARE @id int

	IF (@InstanceID IS NULL AND @InstanceName IS NULL)
	BEGIN
		RAISERROR('Please Specify InstanceID or InstanceName for retirement',0,1)
		RETURN 1
	END
	ELSE IF(@InstanceID IS NOT NULL AND @InstanceName IS NOT NULL)
	BEGIN
		SELECT @id = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName
		IF(@id <> @InstanceID)
			BEGIN
				RAISERROR('InstanceID does not match value found in database.  Please specify InstanceID or InstanceName. (do not need both)',0,1)
				RETURN 1			
			END	
	END
	ELSE IF(@InstanceID IS NULL AND @InstanceID IS NOT NULL)
		SELECT @id = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName
	ELSE
		SET @id = @InstanceID
	BEGIN TRANSACTION
		--Mark the instance as deleted
		UPDATE MonitoredInstances
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 2, @Refresh = 1

		--Mark all databases as deleted
		UPDATE MonitoredDatabases
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 3, @Refresh = 1

		--Mark all databaseFiles as deleted
		UPDATE MonitoredDatabaseFiles
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		--Mark all Jobs as deleted
		UPDATE MonitoredInstanceJobs
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 4, @Refresh = 1

	COMMIT TRANSACTION
RETURN 0
