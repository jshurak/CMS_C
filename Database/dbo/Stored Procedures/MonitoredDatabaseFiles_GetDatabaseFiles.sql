CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_GetDatabaseFiles]
	@InstanceID int,
	@DatabaseID int,
	@FileType varchar(10)
AS
BEGIN
	SELECT InstanceID,DatabaseID,DatabaseFileID,LogicalName,PhysicalName,Directory
	FROM MonitoredDatabaseFiles
	WHERE InstanceID = @InstanceID
	AND DatabaseID = @DatabaseID
	AND FileType = @FileType
	AND Deleted = 0
END
