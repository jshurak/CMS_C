CREATE PROCEDURE [dbo].[Alert_Databases]
AS
BEGIN 
SET NOCOUNT ON

DECLARE @Message varchar(max), @Subject varchar(60)

	IF EXISTS(SELECT TOP 1 DatabaseID FROM MonitoredDatabases WHERE DateCreated > DATEADD(mi,-30,GETDATE()))
	BEGIN
		SET @Subject  = 'New Database Found'
		SET @Message = dbo.get_css()
		SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><font color="Green">
				<th>ServerName</th>	
				<th>InstanceName</th>
				<th>DatabaseName</th>
				<th>CreationDate</th>
				<th>RecoveryModel</th>
			</tr>'
		SELECT @Message = @Message + N'
		<tr>
			<td>'+ms.[ServerName]+'</td>
			<td>'+mi.[InstanceName]+'</td>
			<td>'+md.[DatabaseName]+'</td>
			<td>'+CAST(md.[CreationDate] AS VARCHAR)+'</td>
			<td>'+md.[RecoveryModel]+'</td>
		</tr>'
		FROM MonitoredDatabases md
		JOIN MonitoredInstances mi
		ON md.InstanceID = mi.InstanceID
		JOIN MonitoredServers ms
		ON md.ServerID = ms.ServerID
		WHERE md.DateCreated > DATEADD(mi,-30,GETDATE()) 
		SET @Message = @Message + '</table>' 
		exec CMS_SendPage @Message,'DatabaseReport',@subject,1, @HTML = 1
	END

	IF EXISTS(SELECT TOP 1 DatabaseID FROM MonitoredDatabases WHERE DateDeleted > DATEADD(mi,-30,GETDATE()))
	BEGIN
		SET @Subject  = 'Database Marked as Deleted'
		SET @Message = dbo.get_css()
		SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><font color="Green">
				<th>ServerName</th>	
				<th>InstanceName</th>
				<th>DatabaseName</th>
				<th>DeletionDate</th>
			</tr>'
		SELECT @Message = @Message + N'
		<tr>
			<td>'+ms.[ServerName]+'</td>
			<td>'+mi.[InstanceName]+'</td>
			<td>'+md.[DatabaseName]+'</td>
			<td>'+CAST(md.[DateDeleted] AS VARCHAR)+'</td>
		</tr>'
		FROM MonitoredDatabases md
		JOIN MonitoredInstances mi
		ON md.InstanceID = mi.InstanceID
		JOIN MonitoredServers ms
		ON md.ServerID = ms.ServerID
		WHERE md.DateDeleted > DATEADD(mi,-30,GETDATE()) 
		SET @Message = @Message + '</table>' 
		exec CMS_SendPage @Message,'DatabaseReport',@subject,1, @HTML = 1
	END
END
