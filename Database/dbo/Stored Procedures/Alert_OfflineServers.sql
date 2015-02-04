CREATE PROCEDURE [dbo].[Alert_OfflineServers]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Server Report ' + @Environment
	--INSERT new offline Servers
	INSERT INTO CurrentOfflineServers
		(ServerID,ServerName,OfflineDate,Environment)
  	SELECT ms.ServerID,
			ms.ServerName,
			GETDATE(),
			ms.Environment
	FROM MonitoredServers ms
	LEFT OUTER JOIN  CurrentOfflineServers co ON ms.ServerID =  co.ServerID
	WHERE PingStatus = 0
	AND DELETED = 0
	AND co.ServerID IS NULL;

	--Delete
	DELETE co
	FROM CurrentOfflineServers co
	INNER JOIN MonitoredServers ms ON co.ServerID = ms.ServerID
	WHERE ms.PingStatus = 1;

	IF EXISTS(SELECT TOP 1 ServerID FROM CurrentOfflineServers WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>ServerName</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+ServerName+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineServers
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineServerReport',@subject,1, @HTML = 1
	END
END
