CREATE VIEW [dbo].[Database_Inventory]
AS
SELECT mi.InstanceName,mdb.DatabaseName,mdb.CompatibilityLevel,mdb.RecoveryModel,mdf.FileCount as DataFileCount,mdf.MaxSize,mdb.Size AS [DatabaseSize],mdf.Growth
FROM MonitoredDatabases mdb
JOIN MonitoredInstances mi
ON mdb.InstanceID = mi.InstanceID
JOIN
( 
SELECT databaseid,MaxSize,Growth,count(*) as FileCount
FROM MonitoredDatabaseFiles
WHERE FileType = 'DATA'
GROUP BY DatabaseID,MaxSize,Growth
) AS mdf
ON mdb.DatabaseID = mdf.DatabaseID
WHERE mdb.DatabaseName NOT IN ('master','model','tempdb','msdb')
