CREATE PROCEDURE [dbo].[MonitoredInstances_SetInstance]
@ServerID int = null
,@InstanceID int
,@InstanceName varchar(128) = null
,@Edition varchar(128) = null
,@Version varchar(120) = null
,@isClustered bit = null
,@MaxMemory bigint = null
,@MinMemory bigint = null
,@ServiceAccount varchar(60) = null
,@ProductLevel varchar(10) = null
,@SSAS bit = NULL
,@SSRS bit = NULL 
,@PingTest bit = 0
,@PingStatus bit = 1
,@SSASStatus varchar(20) = NULL
,@SSRSStatus varchar(20) = NULL
,@AgentStatus varchar(20) = NULL
AS
BEGIN
	IF EXISTS (SELECT INSTANCEID FROM MonitoredInstances WHERE INSTANCENAME = @InstanceName and ServerID = @ServerID and InstanceID = @InstanceID)
	BEGIN
		IF @PingTest = 1
			UPDATE MonitoredInstances
			SET 
				PingStatus = @PingStatus,
				SSASStatus = @SSASStatus,
				SSRSStatus = @SSRSStatus,
				AgentStatus = @AgentStatus
			WHERE InstanceID = @InstanceID
		ELSE
		BEGIN
			UPDATE MonitoredInstances
			SET
				Edition = @Edition
				,[Version] = @Version
				,isClustered = @isClustered
				,MaxMemory = @MaxMemory
				,MinMemory = @MinMemory
				,ServiceAccount = @ServiceAccount
				,ProductLevel = @ProductLevel
				,DateUpdated = getdate()
				,SSAS = @SSAS
				,SSRS = @SSRS
				,Deleted = 0
				,DateDeleted = NULL
			WHERE
				InstanceName = @InstanceName
				AND ServerID = @ServerID
	
			IF @isClustered = 1
				UPDATE MonitoredServers
				SET
					IsVirtualServerName = 1
				WHERE
					ServerID = @ServerID
		END
	END
END
