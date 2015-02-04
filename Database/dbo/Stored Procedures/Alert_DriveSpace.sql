CREATE PROCEDURE [dbo].[Alert_DriveSpace]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @DriveID int,@ServerName varchar(128),@MountPoint varchar(60),@FreeSpace bigint,@TotalCapacity BIGINT, @PercentFree DECIMAL(4,2)
	DECLARE @Message varchar(max), @Subject varchar(60) = 'Drive Space Alert'
	/**************************************************************
		Insert any low drives that don't exist in table already
	**************************************************************/
	
	INSERT INTO CurrentDriveSpaceLow (ServerName,ServerEnvironment,DriveID,MountPoint,FreeSpace,TotalCapacity,PercentageFree,PercentageFreeThreshold)
	SELECT ms.ServerName,ms.Environment,md.DriveID,md.MountPoint,md.FreeSpace,md.TotalCapacity
	,md.PercentageFree
	,md.PercentFreeThreshold
	FROM MonitoredDrives md
	JOIN MonitoredServers ms
	ON md.ServerID = ms.ServerID
	LEFT OUTER JOIN CurrentDriveSpaceLow cds
	ON md.DriveID = cds.DriveID
	WHERE md.Deleted = 0 AND
	md.PercentageFree <= md.PercentFreeThreshold
	AND cds.DriveID IS NULL

	/*************************************************************
		Delete any drives that are in the clear
	**************************************************************/
	DELETE cds
	FROM CurrentDriveSpaceLow cds
	JOIN MonitoredDrives md
	ON cds.DriveID = md.DriveID
	WHERE md.Deleted = 1 OR
	md.PercentageFree > md.PercentFreeThreshold

	/***********************************************************
		Update any Existing records
	************************************************************/
	UPDATE CurrentDriveSpaceLow
	SET FreeSpace = md.FreeSpace
	,TotalCapacity = md.TotalCapacity
	,PercentageFree = md.PercentageFree
	,PercentageFreeThreshold = md.PercentFreeThreshold
	FROM MonitoredDrives md
	JOIN CurrentDriveSpaceLow cds
	ON md.DriveID = cds.DriveID

	/******************************************************
		Begin processing alerts.
	*******************************************************/


	IF EXISTS(SELECT TOP 1 DriveID FROM CurrentDriveSpaceLow WHERE ServerEnvironment = @Environment)
		BEGIN
				SET @Message = dbo.get_css()
				SET @Message = @Message + N'<table id="box-table" >' +
					N'<tr>
					<th>ServerName</th>
					<th>MountPoint</th>
					<th>FreeSpace (MB)</th>
					<th>TotalCapacity (MB)</th>
					<th>PercentFree</th>
					</tr>'
					SELECT @Message = @Message + N'
					<tr>
						<td>'+[ServerName]+'</td>
						<td>'+[MountPoint]+'</td>
						<td>'+CAST(Freespace/1024/1024 AS VARCHAR)+'</td>
						<td>'+CAST(TotalCapacity/1024/1024 AS VARCHAR)+'</td>
						<td>'+CAST(PercentageFree * 100 AS VARCHAR)+'</td>
					</tr>'
					FROM [dbo].[CurrentDriveSpaceLow]
					WHERE ServerEnvironment = @Environment
					SET @Message = @Message + '</table>' 
					exec CMS_SendPage @Message,'DriveSpaceReport',@subject,1, @HTML = 1
			
		END

END
