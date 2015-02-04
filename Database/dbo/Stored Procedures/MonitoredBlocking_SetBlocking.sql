CREATE PROCEDURE [dbo].[MonitoredBlocking_SetBlocking]
@InstanceID int,
@SPID smallint,
@LastBatchTime datetime,
@Action varchar(10),
@Status varchar(30) = null,
@LoginName varchar(128) = null,
@HostName varchar(128) = null,
@ProgramName varchar(128) = null,
@OpenTran smallint = null,
@DatabaseName varchar(128) = null,
@Command varchar(16) = null,
@LastWaitType varchar(32) = null,
@WaitTime bigint = null,
@SQL varchar(max) = null,
@BlockingID BIGINT = null
AS
BEGIN
	IF @Action = 'OPEN'
	  --Check to see if the current process is already recorded
		IF NOT EXISTS(SELECT TOP 1 InstanceID FROM MonitoredBlocking WHERE InstanceID = @InstanceID and SPID = @SPID and EndCollectionTime IS NULL)
			BEGIN
				
				INSERT INTO MonitoredBlocking (InstanceID,Spid,Status,LoginName,HostName,ProgramName,OpenTran,DatabaseName,Command,LastWaitType,WaitTime,LastBatchTime,StartCollectionTime,SQLStatement)
				VALUES (@InstanceID,@SPID,@Status,@LoginName,@HostName,@ProgramName,@OpenTran,@DatabaseName,@Command,@LastWaitType,@WaitTime,@LastBatchTime,GETDATE(),@SQL)

				SELECT @BlockingID = SCOPE_IDENTITY()

				INSERT INTO CurrentBlocking (InstanceID,CurrentBlockingSpid,LastBatchTime,BlockingID) values (@InstanceID,@SPID,@LastBatchTime,@BlockingID)

			END
		ELSE
			UPDATE MonitoredBlocking
			SET Status = @Status
			,LastWaitType = @LastWaitType
			,WaitTime = @WaitTime
			,LastBatchTime = @LastBatchTime
			WHERE InstanceID = @InstanceID
			AND Spid = @SPID
			AND EndCollectionTime IS NULL

			UPDATE CurrentBlocking
			SET LastBatchTime = @LastBatchTime
			WHERE InstanceID = @InstanceID
			AND CurrentBlockingSpid = @SPID

			DELETE cb
			FROM CurrentBlocking cb
			JOIN monitoredinstances mi
			ON cb.instanceid = mi.instanceid 
			WHERE mi.MonitorBlocking = 0

	IF @Action = 'CLOSE'
		BEGIN
			UPDATE MonitoredBlocking
			SET EndCollectionTime = GETDATE()
			WHERE Spid = @SPID
			AND InstanceID = @InstanceID
			AND EndCollectionTime IS NULL

			DELETE FROM CurrentBlocking
			WHERE InstanceID = @InstanceID 
			AND CurrentBlockingSpid = @SPID
			AND LastBatchTime = @LastBatchTime
		END
END
