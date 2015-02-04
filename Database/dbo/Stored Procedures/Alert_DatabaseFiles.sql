CREATE PROCEDURE [dbo].[Alert_DatabaseFiles]
@Report varchar(25) = 'daily'
,@Environment varchar(25)
AS
BEGIN
       SET NOCOUNT ON
       DECLARE @Message varchar(max), @Subject varchar(60) = 'Database File Alert ' + @Environment
       /**************************************************
              Insert new records
       ***************************************************/
       INSERT INTO [dbo].[CurrentDatabaseFileIssues]
                        ([DatabaseFileID],[ServerName],[InstanceName],[InstanceEnvironment],[DatabaseName],[LogicalName],[FileSize],[UsedSpace],[AvailableSpace],[MaxSize],[PercentageFree],[Growth],[GrowthType],[DatabaseFileSpaceThreshold],[FileType],[AvailableGrowth])
       SELECT       mdf.DatabaseFileID,ms.ServerName,mi.InstanceName,mi.Environment,mdb.DatabaseName,mdf.LogicalName,mdf.FileSize,mdf.UsedSpace,mdf.AvailableSpace,mdf.MaxSize,mdf.PercentageFree,mdf.Growth,mdf.GrowthType,mdf.DatabaseFileSpaceThreshold,mdf.FileType
                           ,1-(mdf.FileSize/mdf.MaxSize) as AvailableGrowth
                           FROM MonitoredDatabaseFiles mdf
                           JOIN MonitoredDatabases mdb
                           ON mdf.DatabaseID = mdb.DatabaseID
                           JOIN MonitoredInstances mi
                           ON mdf.InstanceID = mi.InstanceID
                           JOIN MonitoredServers ms
                           ON mi.ServerID = ms.ServerID
                           LEFT OUTER JOIN CurrentDatabaseFileIssues cdf
                           ON mdf.DatabaseFileID = cdf.DatabaseFileID
                           WHERE mdb.Deleted = 0 AND
                           mdb.DatabaseName NOT IN ('master','model') AND
                           cdf.DatabaseFileID IS NULL AND
                           (mdf.PercentageFree < mdf.DatabaseFileSpaceThreshold
                           OR
                           ((mdf.MaxSize = -1) OR (1-(mdf.FileSize/mdf.MaxSize) < mdf.DatabaseFileSpaceThreshold)))

                     /***************************************************************************
                           Delete records that are fixed
                     ***************************************************************************/

                     DELETE cdf
                     FROM CurrentDatabaseFileIssues cdf
                     JOIN MonitoredDatabaseFiles mdf
                     ON cdf.DatabaseFileID = mdf.DatabaseFileID
                     JOIN MonitoredDatabases md
                     ON mdf.DatabaseID = md.DatabaseID
                     WHERE md.MonitorDatabaseFiles = 0 OR md.Deleted = 1 OR
                     (mdf.PercentageFree >= mdf.DatabaseFileSpaceThreshold
                     AND
                     mdf.MaxSize <> -1
                     AND 1-(mdf.FileSize/mdf.MaxSize) >= mdf.DatabaseFileSpaceThreshold)

                     /**********************************************************************
                           Update Existing Records                  
                     ***********************************************************************/
                     UPDATE cdf
                        SET cdf.[FileSize] = mdf.FileSize
                             ,cdf.[UsedSpace] = mdf.UsedSpace
                             ,cdf.[AvailableSpace] = mdf.AvailableSpace
                             ,cdf.[MaxSize] = mdf.MaxSize
                             ,cdf.[PercentageFree] = mdf.PercentageFree
                             ,cdf.[Growth] = mdf.Growth
                             ,cdf.[GrowthType] = mdf.GrowthType
                             ,cdf.[DatabaseFileSpaceThreshold] = mdf.DatabaseFileSpaceThreshold
                             ,cdf.[FileType] = mdf.FileType
                             ,cdf.[AvailableGrowth] = 1-(mdf.FileSize/mdf.MaxSize) 
                           FROM MonitoredDatabaseFiles mdf
                           JOIN CurrentDatabaseFileIssues cdf
                           ON mdf.DatabaseFileID = cdf.DatabaseFileID




                     IF EXISTS (SELECT TOP 1 DatabaseFileID FROM CurrentDatabaseFileIssues WHERE InstanceEnvironment = @Environment)
                           IF @Report = 'daily'
                                  BEGIN
                                         SET @Message = dbo.get_css()
                                                SET @Message = @Message + N'<table id="box-table" >' +
                                                       N'<tr><font color="Green">
                                                         <th>ServerName</th>      
                                                         <th>InstanceName</th>
                                                         <th>DatabaseName</th>
                                                         <th>LogicalName</th>
                                                         <th>FileType</th>
                                                         <th>UsedSpace</th>
                                                         <th>FileSize</th>
                                                         <th>AvailableSpace</th>
                                                         <th>MaxSize</th>
                                                         <th>PercentageFree</th>
                                                       </tr>'
                                                       SELECT @Message = @Message + N'
                                                       <tr>
                                                              <td>'+[ServerName]+'</td>
                                                              <td>'+[InstanceName]+'</td>
                                                              <td>'+[DatabaseName]+'</td>
                                                              <td>'+[LogicalName]+'</td>
                                                              <td>'+[FileType]+'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' ELSE '' END + CAST(CAST(UsedSPace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CAST(CAST(FileSize AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(CAST(AvailableSpace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN UnlimitedFlag = 1 THEN '<font color="orange">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CASE WHEN MaxSize =-1 THEN 'Unlimited' ELSE CAST(CAST(MaxSize AS BIGINT) AS VARCHAR) END +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(PercentageFree*100 AS VARCHAR) +'</td>
                                                       </tr>'
                                                       FROM [dbo].[CurrentDatabaseFileIssues]
													   WHERE InstanceEnvironment = @Environment
                                                       SET @Message = @Message + '</table>' 
                                                       exec CMS_SendPage @Message,'DatabaseFileReport',@subject,1, @HTML = 1
                                  END
                           IF @Report = 'hourly' AND EXISTS(SELECT TOP 1 DatabaseFileID FROM CurrentDatabaseFileIssues WHERE FileSizeFlag = 1 AND InstanceEnvironment = @Environment)
                                  BEGIN
                                         SET @Message = dbo.get_css()
                                                SET @Message = @Message + N'<table id="box-table" >' +
                                                       N'<tr><font color="Green">
                                                         <th>ServerName</th>      
                                                         <th>InstanceName</th>
                                                         <th>DatabaseName</th>
                                                         <th>LogicalName</th>
                                                         <th>FileType</th>
                                                         <th>UsedSpace</th>
                                                         <th>FileSize</th>
                                                         <th>AvailableSpace</th>
                                                         <th>MaxSize</th>
                                                         <th>PercentageFree</th>
                                                       </tr>'
                                                       SELECT @Message = @Message + N'
                                                       <tr>
                                                              <td>'+[ServerName]+'</td>
                                                              <td>'+[InstanceName]+'</td>
                                                              <td>'+[DatabaseName]+'</td>
                                                              <td>'+[LogicalName]+'</td>
                                                              <td>'+[FileType]+'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' ELSE '' END + CAST(CAST(UsedSPace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CAST(CAST(FileSize AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(CAST(AvailableSpace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN UnlimitedFlag = 1 THEN '<font color="orange">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CASE WHEN MaxSize =-1 THEN 'Unlimited' ELSE CAST(CAST(MaxSize AS BIGINT) AS VARCHAR) END +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(PercentageFree*100 AS VARCHAR) +'</td>
                                                       </tr>'
                                                       FROM [dbo].[CurrentDatabaseFileIssues]
                                                       WHERE FileSizeFlag = 1 
													   AND InstanceEnvironment = @Environment
                                                       SET @Message = @Message + '</table>' 
                                                       exec CMS_SendPage @Message,'DatabaseFileReport',@subject,1, @HTML = 1
                                  END
END
