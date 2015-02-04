CREATE Procedure [dbo].[Alert_Backups]
@Environment varchar(20)
AS
BEGIN
SET NOCOUNT ON
               DECLARE @RunDate DATETIME = GETDATE()


                /*********************************************
                                Clear out old backup records
                **********************************************/
                DELETE
                FROM CurrentBackupsOutstanding
                WHERE BackupRecordDate < DATEADD(mi,-1440,@RunDate)
                /*************************************
                                CHECK FOR NEW OUTSTANDING BACKSUP
                **************************************/
                INSERT INTO CurrentBackupsOutstanding (BackupID,ServerName,InstanceName,InstanceEnvironment,DatabaseName,DatabaseID,BackupRecordDate,LastFullBackupDate,FullFlag,LastDIfferentialBackupDate,DiffFlag,LastLogBackupDate,TFlag)
                SELECT mdb.BackupID,ms.ServerName,mi.InstanceName,mi.Environment,md.DatabaseName,md.DatabaseID,mdb.BackupRecordDate
                ,mdb.LastFullBackupDate
                ,CASE
                                WHEN md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold THEN 1
                                ELSE 0
                END FullFlag
                ,mdb.LastDifferentialBackupDate
                ,CASE
                                WHEN md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold THEN 1
                                ELSE 0
                END DiffFlag
                ,mdb.LastLogBackupDate
                ,CASE
                                WHEN md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold THEN 1
                                ELSE 0
                END TFlag
                FROM MonitoredDatabaseBackups mdb
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                JOIN MonitoredInstances mi
                ON md.InstanceID = mi.InstanceID
                JOIN MonitoredServers ms
                ON mi.ServerID = ms.ServerID
                LEFT OUTER JOIN CurrentBackupsOutstanding cb
                ON mdb.BackupID = cb.BackupID
                WHERE md.Deleted = 0 AND md.ReadOnly = 0 AND
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440
                AND 
                ((md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold)
                OR 
                (
					(md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold)
					AND
					(md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.DBThreshold)
				) 
                OR
                (md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold))
                AND cb.BackupID IS NULL

                /*
                                CHECK FOR ANY RECORDS THAT SHOULD BE REMOVED FROM CURRENT OUTSTANDING
                */
                DELETE cb
                FROM CurrentBackupsOutstanding cb
                JOIN MonitoredDatabaseBackups mdb
                ON cb.BackupID = mdb.BackupID
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                WHERE md.Deleted = 1 OR md.ReadOnly = 1 OR
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440
                AND
                (
				(md.FullBackupFlag = 0 OR (md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) <		md.FBThreshold))
                AND
                (
					(md.DiffBackupFlag = 0 OR (md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) < md.DBThreshold)) AND (md.FullBackupFlag = 0 OR (md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) <		md.DBThreshold))
				)
                AND
                (md.TranBackupFlag = 0 OR (md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) < md.TBThreshold))
				)

                /*
                                UPDATE EXISTING RECORDS WITH LATEST 
                */
                UPDATE CurrentBackupsOutstanding
                SET
                LastFullBackupDate = mdb.LastFullBackupDate
                ,FullFlag = 
                CASE
                                WHEN md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold THEN 1
                                ELSE 0
                END 
                ,LastDifferentialBackupDate = mdb.LastDifferentialBackupDate
                ,DiffFlag = 
                CASE
                                WHEN md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold THEN 1
                                ELSE 0
                END 
                ,LastLogBackupDate = mdb.LastLogBackupDate
                ,TFlag = 
                CASE
                                WHEN md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold THEN 1
                                ELSE 0
                END 
                FROM MonitoredDatabaseBackups mdb
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                JOIN MonitoredInstances mi
                ON md.InstanceID = mi.InstanceID
                JOIN MonitoredServers ms
                ON mi.ServerID = ms.ServerID
                JOIN CurrentBackupsOutstanding cb
                ON cb.BackupID = mdb.BackupID
                WHERE md.Deleted = 0 AND 
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440


			IF EXISTS(SELECT TOP 1 BackupID FROM CurrentBackupsOutstanding WHERE InstanceEnvironment = @Environment)
				BEGIN
					DECLARE @bodyMsg nvarchar(max)
					DECLARE @subject nvarchar(max)
					DECLARE @Message nvarchar(max)

					SET @subject = 'Missing Backup Report ' + @Environment


					SET @Message = dbo.get_css()


					SET @Message = @Message + N'<table id="box-table" >' +
					N'<tr><font color="Green"><th>ServerName</th>
					<th>InstanceName</th>
					<th>DatabaseName</th>
					<th>LastFullBackupDate</th>
					<th>LastDifferentialBackupDate</th>
					<th>LastLogBackupDate</th>
					</tr>' 
					SELECT @Message = @Message + N'
					<tr>
						<td>'+[cb].[ServerName]+'</td>
						<td>'+[cb].[InstanceName]+'</td>
						<td>'+[cb].[DatabaseName]+'</td>
						<td>'+CASE WHEN FullFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.FullBackupFlag = 0 THEN 'NA' WHEN [cb].[LastFullBackupDate] = '01/01/1900 00:00:00' THEN 'No record of a full backup' ELSE CONVERT(VARCHAR(30),[cb].[LastFullBackupDate],120) END+'</td>
						<td>'+CASE WHEN DiffFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.DiffBackupFlag = 0 THEN 'NA' ELSE CONVERT(VARCHAR(30),[cb].[LastDifferentialBackupDate],120) END+'</td>
						<td>'+CASE WHEN TFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.TranBackupFlag = 0 THEN 'NA' WHEN [cb].[LastLogBackupDate] = '01/01/1900 00:00:00' THEN 'No record of log backups' ELSE CONVERT(VARCHAR(30),[cb].[LastLogBackupDate],120) END+'</td>
					</tr>'
					FROM [dbo].[CurrentBackupsOutstanding] cb
					JOIN [dbo].[MonitoredDatabases] md
					ON cb.DatabaseID = md.DatabaseID
					WHERE cb.InstanceEnvironment = @Environment
					ORDER BY [BackupID]
					SET @Message = @Message + '</table>' 

					exec CMS_SendPage @Message,'BackupReport',@subject,1, @HTML = 1
				END

END
