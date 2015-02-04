CREATE PROCEDURE [dbo].[UntrackCMSServer]
@ServerName varchar(128) = null
,@ServerID int = null
AS
BEGIN
	IF(@ServerName IS NULL AND @ServerID IS NULL)
		BEGIN
			PRINT 'Please enter a server name or server id.'
			RETURN
		END
	ELSE
		BEGIN
			IF(@ServerID IS NULL)
				SELECT TOP 1 @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ServerName
			IF(@ServerID IS NULL)
				BEGIN
					Print 'The server ' + @ServerName + ' not found.'
				END
			ELSE
				BEGIN
					UPDATE MonitoredServers 
					SET MonitorServer = 0
					WHERE ServerID = @ServerID

					exec CacheUpdateController @CacheID = 1,@Refresh = 1;
				END
		END
END
