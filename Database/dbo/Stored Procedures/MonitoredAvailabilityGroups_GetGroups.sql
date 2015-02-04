CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_GetGroups]
@Mode varchar(25),
@InstanceID int
AS
BEGIN
	DECLARE @SQL varchar(4000)
	 IF @Mode = 'Listener'
		SET @SQL = N'SELECT distinct(gl.ListenerName),gl.ListenerGUID,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupListeners gl
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gl.AvailabilityGroupID = gr.AvailabilityGroupID
					JOIN MonitoredAvailabilityGroups g
					ON g.AvailabilityGroupID = gl.AvailabilityGroupID
					WHERE gr.InstanceID =' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Database'
		SET @SQL = N'SELECT distinct(gd.DatabaseName),gd.AGDatabaseGuid,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupDBDetails gd
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gd.AvailabilityGroupID = gr.AvailabilityGroupID
					JOIN MonitoredAvailabilityGroups g
					ON gd.AvailabilityGroupID = g.AvailabilityGroupID
					WHERE gd.Deleted = 0 AND
					gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Replica'
		SET @SQL = N'SELECT gr.ReplicaName,gr.ReplicaGUID,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupReplicas gr
					JOIN MonitoredAvailabilityGroups g
					ON gr.AvailabilityGroupID = g.AvailabilityGroupID
					WHERE gr.Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Group'
		SET @SQL = N'SELECT DISTINCT g.AvailabilityGroupID,g.AvailabilityGroupName,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroups g
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON g.AvailabilityGroupID = gr.AvailabilityGroupID 
					WHERE g.Deleted = 0 AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	exec(@SQL)
END
