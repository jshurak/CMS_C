CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_GetCounts]
@Type varchar(10),
@InstanceID int
AS
BEGIN
	DECLARE @SQL varchar(4000)

	IF @Type = 'Groups'
		SET @SQL = N'SELECT COUNT(DISTINCT g.AvailabilityGroupID) as AGCount
					FROM MonitoredAvailabilityGroups g
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON g.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE g.Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Type = 'Replicas'
		SET @SQL = N'SELECT COUNT(DISTINCT(REPLICAid)) AS ReplicaCount
					FROM MonitoredAvailabilityGroupReplicas
					WHERE Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Type = 'Databases' 
		SET @SQL = N'SELECT COUNT (DISTINCT(DetailID)) AS DatabaseCount
					FROM MonitoredAvailabilityGroupDBDetails gdb
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gdb.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE gdb.Deleted = 0 
					AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)

	ELSE 
		SET @SQL = N'SELECT COUNT(DISTINCT(ListenerID)) AS ListenerCount
					FROM MonitoredAvailabilityGroupListeners gl
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gl.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE gl.Deleted = 0
					AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)

	exec (@SQL)
END
