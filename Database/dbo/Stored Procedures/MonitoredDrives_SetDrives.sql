CREATE PROCEDURE [dbo].[MonitoredDrives_SetDrives]
@ServerID int
,@DeviceID varchar(60)
,@MountPoint varchar(60) = null
,@TotalCapacity bigint = null
,@FreeSpace bigint = null
,@VolumeName varchar(128) = null
,@Deleted bit = 0
AS
BEGIN
	IF NOT EXISTS(select DriveID from MonitoredDrives where ServerID = @ServerID and DeviceID = @DeviceID)
		INSERT INTO MonitoredDrives(ServerID,DeviceID,MountPoint,TotalCapacity,FreeSpace,VolumeName,DateCreated,DateUpdated,Deleted) VALUES (@ServerID,@DeviceID,@MountPoint,@TotalCapacity,@FreeSpace,@VolumeName,getdate(),getdate(),0)
	IF @Deleted = 1
		BEGIN
			UPDATE MonitoredDrives
			SET Deleted = @Deleted,
			DateDeleted = getdate()
			WHERE ServerID = @ServerID
			AND DeviceID = @DeviceID
		END
	ELSE
		UPDATE MonitoredDrives
		SET
			TotalCapacity = @TotalCapacity
			,FreeSpace = @FreeSpace
			,VolumeName = @VolumeName
			,MountPoint = @MountPoint
			,DateUpdated = GETDATE()
			,Deleted = @Deleted
			,DateDeleted = null
		WHERE
			ServerID = @ServerID
			AND DeviceID = @DeviceID
END
