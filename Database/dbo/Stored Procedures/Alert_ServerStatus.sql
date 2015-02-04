CREATE PROCEDURE [dbo].[Alert_ServerStatus]
@Environment varchar(60) = 'PRODUCTION'
AS
BEGIN
	DECLARE @bodyMsg nvarchar(max)
	DECLARE @subject nvarchar(max)
	DECLARE @Message nvarchar(max)
	SET @subject = 'Server Status Report ' + @Environment

	IF EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE PingStatus <> 0 AND Environment = @Environment)
		BEGIN
			SET @Message = dbo.get_css()

			SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><th>ServerName</th>
				  <th>PingStatus</th>
			</tr>' 
			SELECT @Message = @Message + N'
					<tr>
						<td>'+ServerName+'</td>
						<td>'+CASE
								 WHEN PingStatus = 11003 THEN 'Destination Host Unreachable'
								 WHEN PingStatus = 11010 THEN 'Request Timed Out'
								 WHEN PingStatus = 11050 THEN 'General Failure'
							  END +'</td>
					</tr>'
			FROM MonitoredServers
			WHERE PingStatus <> 0 
			AND Environment = @Environment
		
			SET @Message = @Message + '</table>'
			exec CMS_SendPage @Message,'ServerAlert',@subject,1, @HTML = 1
		END
				
END
