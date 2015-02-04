CREATE PROCEDURE [dbo].[Alert_OfflineInstances]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Instance Report ' + @Environment
	--INSERT new offline instances
	INSERT INTO CurrentOfflineInstances
		(InstanceID,InstanceName,OfflineDate,Environment)
  	SELECT mi.InstanceID,
			mi.InstanceName,
			GETDATE(),
			mi.Environment
	FROM MonitoredInstances mi 
	LEFT OUTER JOIN  CurrentOfflineInstances coi ON mi.InstanceID =  coi.InstanceID
	WHERE PingStatus = 0
	AND DELETED = 0
	AND coi.InstanceID IS NULL;

	--Delete
	DELETE coi
	FROM CurrentOfflineInstances coi
	INNER JOIN MonitoredInstances mi ON coi.InstanceID = mi.InstanceID
	WHERE mi.PingStatus = 1;

	IF EXISTS(SELECT TOP 1 InstanceID FROM CurrentOfflineInstances WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>InstanceName</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+InstanceName+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineInstances
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineInstanceReport',@subject,1, @HTML = 1
	END
END
