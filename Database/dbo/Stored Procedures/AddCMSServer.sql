CREATE PROCEDURE [dbo].[AddCMSServer]
@ServerName varchar(128)
,@InstanceName varchar(128) = NULL
,@Environment varchar(20) = 'PRODUCTION'
,@IsVirtualServerName bit = 0
AS
BEGIN
SET NOCOUNT ON

	DECLARE @ServerID int,@InstanceID int
	
	--Check for server existence, add if not
	IF NOT EXISTS(SELECT ServerID FROM MonitoredServers WHERE ServerName = @ServerName)
		BEGIN
			INSERT INTO MonitoredServers (ServerName,Environment,deleted,IsVirtualServerName) VALUES (@ServerName,@Environment,0,@IsVirtualServerName)
			SELECT @ServerID = SCOPE_IDENTITY()

			exec CacheUpdateController @CacheName = 'Server', @Refresh = 1
		END
	ELSE
		SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ServerName

	IF @InstanceName IS NOT NULL
	BEGIN	
		--check for instance existence add if not
		IF NOT EXISTS(SELECT InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName AND ServerID = @ServerID)
		BEGIN
			INSERT INTO MonitoredInstances (ServerID,InstanceName,Environment,Deleted) VALUES (@ServerID,@InstanceName,@Environment,0)

			exec CacheUpdateController @CacheName = 'Instance', @Refresh = 1
		END
		ELSE
			BEGIN
				SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName AND ServerID = @ServerID
				PRINT 'Instance already exists. InstanceName: ' + @InstanceName + ', InstanceID: ' + CAST(@InstanceID as varchar)
			END
	END
END