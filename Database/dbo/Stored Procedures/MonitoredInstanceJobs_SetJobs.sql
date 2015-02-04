CREATE PROCEDURE [dbo].[MonitoredInstanceJobs_SetJobs]
@InstanceID int,
@ServerID int = NULL,
@JobName varchar(128) = NULL,
@JobGUID varchar(36),
@JobCategory varchar(128) = NULL,
@JobOwner varchar(60) = NULL,
@LastRunDate datetime = NULL,
@NextRunDate datetime = NULL,
@JobOutcome varchar(60) = NULL,
@JobEnabled bit = NULL,
@JobScheduled bit = NULL,
@JobDuration int = NULL,
@JobCreationDate datetime = NULL,
@JobModifiedDate datetime = NULL,
@JobEmailLevel varchar(60) = NULL,
@JobPageLevel varchar(60) = NULL,
@JobNetSendLevel varchar(60) = NULL,
@OperatorToEmail varchar(60) = NULL,
@OperatorToPage varchar(60) = NULL,
@OperatorToNetSend varchar(60) = NULL,
@Deleted bit = 0
AS
BEGIN
	DECLARE @RunDate DATETIME = GETDATE(),@JobID INT

	IF NOT EXISTS(SELECT JobID FROM MonitoredInstanceJobs WHERE InstanceID = @InstanceID AND JobGUID = @JobGUID)
		BEGIN
			INSERT INTO [dbo].[MonitoredInstanceJobs]
			([InstanceID],[ServerID],[JobName],[JobGUID],[JobCategory],[JobOwner],[LastRunDate],[NextRunDate],[JobOutcome],[JobEnabled],[JobScheduled],[JobDuration],[JobCreationDate],[JobModifiedDate],[JobEmailLevel],[JobPageLevel],[JobNetSendLevel],[OperatorToEmail],[OperatorToPage],[OperatorToNetSend],[DateCreated],[DateUpdated],[Deleted])
			VALUES
			(@InstanceID,@ServerID,@JobName,@JobGUID,@JobCategory,@JobOwner,@LastRunDate,@NextRunDate,@JobOutcome,@JobEnabled,@JobScheduled,@JobDuration,@JobCreationDate,@JobModifiedDate,@JobEmailLevel,@JobPageLevel,@JobNetSendLevel,@OperatorToEmail,@OperatorToPage,@OperatorToNetSend,@RunDate,@RunDate,@Deleted)

			SELECT @JobID = SCOPE_IDENTITY()

			exec CacheUpdateController @CacheName = 'AgentJob',@Refresh = 1;

			IF NOT EXISTS(SELECT sa.Name FROM MonitoredInstanceJobs mj JOIN ServiceAccounts sa ON mj.JobOwner = sa.name WHERE JobID = @JobID AND sa.AgentJobs = 1)
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 1
				WHERE JobId = @JobID
			ELSE
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 0
				WHERE JobId = @JobID
		END
	ELSE IF @Deleted = 1
		BEGIN
			UPDATE MonitoredInstanceJobs
			SET Deleted = 1,
			DateDeleted = GETDATE(),
			JobEnabled = 0
			WHERE InstanceID = @InstanceID
			AND JobGUID = @JobGUID

			exec CacheUpdateController @CacheName = 'AgentJob',@Refresh = 1;
		END
	ELSE
		BEGIN
			SELECT @JobID = JobID FROM MonitoredInstanceJobs WHERE InstanceID = @InstanceID AND JobGUID = @JobGUID

			UPDATE [dbo].[MonitoredInstanceJobs]
			   SET [ServerID]		= @ServerID
				  ,[JobName]		= @JobName
				  ,[JobGUID]		= @JobGUID
				  ,[JobCategory]	= @JobCategory
				  ,[JobOwner]		= @JobOwner
				  ,[LastRunDate]	= @LastRunDate
				  ,[NextRunDate]	= @NextRunDate
				  ,[JobOutcome]		= @JobOutcome
				  ,[JobEnabled]		= @JobEnabled
				  ,[JobScheduled]	= @JobScheduled
				  ,[JobDuration]	= @JobDuration
				  ,[JobCreationDate] = @JobCreationDate
				  ,[JobModifiedDate] = @JobModifiedDate
				  ,[JobEmailLevel]	= @JobEmailLevel
				  ,[JobPageLevel]	= @JobPageLevel
				  ,[JobNetSendLevel] = @JobNetSendLevel
				  ,[OperatorToEmail] = @OperatorToEmail
				  ,[OperatorToPage] = @OperatorToPage
				  ,[OperatorToNetSend] = @OperatorToNetSend
				  ,[DateUpdated]	= @RunDate
				  ,[Deleted]		= @Deleted
			 WHERE 
				InstanceID = @InstanceID AND
				JobGUID = @JobGUID

			IF NOT EXISTS(SELECT sa.Name FROM MonitoredInstanceJobs mj JOIN ServiceAccounts sa ON mj.JobOwner = sa.name WHERE JobID = @JobID)
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 1
				WHERE JobId = @JobID
			ELSE
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 0
				WHERE JobId = @JobID
		END
END
