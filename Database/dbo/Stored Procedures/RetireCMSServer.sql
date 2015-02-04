CREATE PROCEDURE [dbo].[RetireCMSServer]
	@ObjectName varchar(128),
	@ObjectType varchar(10) 
AS
	DECLARE @ServerID int, @InstanceID int,@msg varchar(1000)
	IF (@ObjectType <> 'Server' AND @ObjectType <> 'Instance')
	BEGIN
		SET @msg = 'Please Specify Server or Instance for @ObjectType for retirement' 
		RAISERROR(@msg,0,1)
		RETURN 1
	END
	IF(@ObjectType = 'Instance')
	BEGIN
		IF EXISTS(SELECT TOP 1 InstanceID FROM MonitoredInstances WHERE InstanceName = @ObjectName)
		BEGIN
			SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @ObjectName
			EXEC RetireCMSInstance @InstanceID = @InstanceID
			RETURN 0
		END
		ELSE
		BEGIN
			SET @msg = 'Instance ' + @ObjectName + ' not found'
			RAISERROR(@msg,0,1)
			RETURN 1			
		END
	END
	IF(@ObjectType = 'Server')
	BEGIN
		IF EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE ServerName = @ObjectName)
		BEGIN
			SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ObjectName

			SELECT InstanceID
			INTO #Instances
			FROM MonitoredInstances
			WHERE ServerID = @ServerID
			BEGIN TRANSACTION
				--Retire Drives
				UPDATE MonitoredDrives
				SET Deleted = 1,
				DateDeleted = GETDATE(),
				DateUpdated = GETDATE()
				WHERE ServerID = @ServerID
				AND Deleted = 0

				WHILE(SELECT COUNT(*) FROM #Instances) > 0
				BEGIN
					SELECT TOP 1 @InstanceID = InstanceID FROM #Instances
					EXEC RetireCMSInstance @InstanceID = @InstanceID

					DELETE FROM #Instances WHERE InstanceID = @InstanceID
				END

				UPDATE MonitoredServers
				SET Deleted = 1,
				DateDeleted = getdate(),
				DateUpdated = getdate()
				WHERE ServerID = @ServerID

				exec CacheUpdateController @CacheID = 1, @Refresh = 1
			COMMIT TRANSACTION
		END
		ELSE 
		BEGIN
			SET @msg = 'Server ' + @ObjectName + ' not found'
			RAISERROR(@msg,0,1)
			RETURN 1
		END
	END
RETURN 0
