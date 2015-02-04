CREATE PROCEDURE [dbo].[Alert_AgentJobs]
@Environment varchar(20)
AS
BEGIN
	DECLARE @bodyMsg nvarchar(max)
	DECLARE @subject nvarchar(max)
	DECLARE @Message nvarchar(max)
	SET @subject = 'Agent Job Report ' + @Environment

	BEGIN
		IF EXISTS(SELECT TOP 1 mj.JobID FROM MonitoredInstanceJobs mj JOIN MonitoredInstances mi ON mj.InstanceID = mi.InstanceID WHERE mi.Environment = @Environment AND mj.JobEnabled = 1 AND mj.MonitorJob = 1 AND mj.Deleted = 0 AND mj.JobCategory <> 'Report Server' AND (mj.FailFlag = 1 OR mj.NotifyFlag = 1 OR mj.OwnerFlag = 1) AND LastRunDate > DATEADD(day,-2,GETDATE()))
			BEGIN
				SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green"><th>ServerName</th>
				<th>InstanceName</th>
				<th>JobName</th>
				<th>LastRunDate</th>
				<th>NextRunDate</th>
				<th>JobOwner</th>
				<th>JobOutcome</th>
				<th>JobEmailLevel</th>
				<th>JobPageLevel</th>
				<th>JobNetSendLevel</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td>'+ms.ServerName+'</td>
						<td>'+mi.InstanceName+'</td>
						<td>'+mj.JobName+'</td>
						<td>'+CAST(mj.LastRunDate AS VARCHAR)+'</td>
						<td>'+CAST(mj.NextRunDate AS VARCHAR)+'</td>
						<td>'+CASE WHEN OwnerFlag = 1 THEN '<font color = orange>' ELSE '' END + mj.JobOwner+'</td>	
						<td>'+CASE WHEN FailFlag = 1 THEN '<font color = red>' ELSE '' END + mj.JobOutcome+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobEmailLevel+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobPageLevel+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobNetSendLevel+'</td>
					</tr>'
					FROM MonitoredInstanceJobs mj
					JOIN MonitoredInstances mi
					ON mj.InstanceID = mi.InstanceID
					JOIN MonitoredServers ms
					ON mj.ServerID = ms.ServerID
					WHERE mi.Environment = @Environment AND mj.Deleted = 0 AND
					mj.JobEnabled = 1 AND mj.MonitorJob = 1 AND mj.JobCategory <> 'Report Server' AND
					(mj.FailFlag = 1 OR mj.OwnerFlag = 1 OR NotifyFlag = 1)
					AND LastRunDate > DATEADD(day,-2,GETDATE())
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'AgentReport',@subject,1, @HTML = 1
			END
		END
END
