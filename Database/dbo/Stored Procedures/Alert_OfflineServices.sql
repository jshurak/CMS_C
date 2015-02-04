CREATE PROCEDURE [dbo].[Alert_OfflineServices]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Service Report ' + @Environment;


	--build service Names
		IF OBJECT_ID('tempdb..#ServiceNames') IS NOT NULL
			DROP TABLE #ServiceNames
	
		SELECT InstanceID,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'SQLAgent$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'SQLSERVERAGENT'
		END AgentServiceName,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'MSOLAP$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'MSSQLServerOLAPService'
		END SSASServiceName,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'ReportServer$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'ReportServer'
		END SSRSServiceName
		INTO #Servicenames
		FROM MonitoredInstances


	--INSERT new offline Servers
	INSERT INTO CurrentOfflineServices
		(ServerID,ServerName,InstanceID,InstanceName,ServiceName,ServiceStatus,OfflineDate,Environment)
  	SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.AgentServiceName,mi.AgentStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.AgentServiceName
			WHERE mi.Deleted = 0
			AND mi.AgentStatus <> 'Running'
			AND co.InstanceID IS NULL
			UNION 
			SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.SSASServiceName,mi.SSASStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.SSASServiceName
			WHERE mi.Deleted = 0
			AND mi.InstanceID not in (10,18,19,21,28,30,40,42,48,29)
			AND mi.SSAS = 1
			AND mi.SSASStatus <> 'Running'
			AND co.InstanceID IS NULL
			UNION 
			SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.SSRSServiceName,mi.SSRSStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.SSRSServiceName
			WHERE mi.Deleted = 0
			AND mi.InstanceID not in (3,48)
			AND mi.SSRS = 1
			AND mi.SSRSStatus <> 'Running'
			AND co.InstanceID IS NULL;

	--Delete
	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.AgentServiceName
	WHERE mi.AgentStatus = 'Running'
	
	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.SSASServiceName
	WHERE mi.SSASStatus = 'Running'
		OR mi.InstanceID IN (10,18,19,21,28,30,40,42,48,49);

	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.SSRSServiceName
	WHERE mi.SSRSStatus = 'Running'
		OR mi.InstanceID IN (3,48);


	IF EXISTS(SELECT TOP 1 ServerID FROM CurrentOfflineServices WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>ServerName</th>
				<th>InstanceName</th>
				<th>ServiceName</th>
				<th>ServiceStatus</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+ServerName+'</td>
						<td><font color = red>'+InstanceName+'</td>
						<td><font color = red>'+ServiceName+'</td>
						<td><font color = red>'+ServiceStatus+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineServices
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineServiceReport',@subject,1, @HTML = 1
	END
END
