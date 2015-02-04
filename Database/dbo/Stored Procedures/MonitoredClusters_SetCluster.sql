CREATE PROCEDURE [dbo].[MonitoredClusters_SetCluster]
@ClusterName varchar(128),
@Deleted bit = 0,
@ClusterID int = null
AS
BEGIN
	IF NOT EXISTS(SELECT TOP 1 ClusterID FROM MonitoredClusters WHERE ClusterName = @ClusterName)
		BEGIN
			INSERT INTO MonitoredClusters VALUES (@ClusterName,getdate(),getdate(),0,null)
			SELECT @ClusterID = SCOPE_IDENTITY()
		END
	ELSE IF @Deleted = 1
		UPDATE MonitoredClusters
		SET
			Deleted = 1,
			DateDeleted = GETDATE(),
			DateUpdated = GETDATE()
		WHERE
			ClusterName = @ClusterName
	ELSE
		BEGIN
			SELECT @ClusterID = ClusterID
			FROM MonitoredClusters
			WHERE ClusterName = @ClusterName
		END

	RETURN @ClusterID
END
