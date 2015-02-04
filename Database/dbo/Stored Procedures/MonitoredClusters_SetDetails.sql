CREATE PROCEDURE [dbo].[MonitoredClusters_SetDetails]
@ClusterID int
,@InstanceID int = null
,@NodeName varchar(128)
,@IsCurrentOwner bit = null
,@Deleted bit = 0
AS
BEGIN
	DECLARE @ServerID int,@PreviousRole bit
	IF NOT EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE ServerName = @NodeName)
		exec MonitoredServers_SetServer @ServerName = @NodeName
	SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @NodeName

	IF NOT EXISTS (Select TOP 1 DetailID FROM MonitoredClusterDetails WHERE ClusterID = @ClusterID AND ServerID = @ServerID AND InstanceID = @InstanceID)
		INSERT INTO MonitoredClusterDetails VALUES (@ClusterID,@InstanceID,@ServerID,@IsCurrentOwner,getdate(),getdate(),@Deleted,null,0)
	ELSE IF @Deleted = 1
		UPDATE MonitoredClusterDetails
		SET 
			Deleted = 1,
			DateUpdated = GETDATE(),
			DateDeleted = GETDATE()
		WHERE 
			ClusterID = @ClusterID
			AND ServerID = @ServerID
	ELSE
	BEGIN
		SELECT @PreviousRole = IsCurrentOwner FROM MonitoredClusterDetails WHERE ClusterID = @ClusterID and ServerID = @ServerID

		UPDATE MonitoredClusterDetails
		SET
			IsCurrentOwner = @IsCurrentOwner,
			DateUpdated = GETDATE(),
			FailoverFlag = 
				CASE
					WHEN @PreviousRole = @IsCurrentOwner THEN 0
					ELSE 1
				END
		WHERE
			ClusterID = @ClusterID
			AND ServerID = @ServerID
	END
END
