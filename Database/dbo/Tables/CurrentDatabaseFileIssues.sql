CREATE TABLE [dbo].[CurrentDatabaseFileIssues] (
    [DatabaseFileID]             INT            NOT NULL,
    [ServerName]                 VARCHAR (128)  NULL,
    [InstanceName]               VARCHAR (128)  NULL,
    [DatabaseName]               VARCHAR (128)  NULL,
    [LogicalName]                VARCHAR (128)  NULL,
    [FileSize]                   FLOAT (53)     NULL,
    [UsedSpace]                  FLOAT (53)     NULL,
    [AvailableSpace]             FLOAT (53)     NULL,
    [MaxSize]                    FLOAT (53)     NULL,
    [PercentageFree]             DECIMAL (4, 3) NULL,
    [Growth]                     FLOAT (53)     NULL,
    [GrowthType]                 VARCHAR (60)   NULL,
    [DatabaseFileSpaceThreshold] DECIMAL (4, 3) NULL,
    [FileType]                   VARCHAR (10)   NULL,
    [AvailableGrowth]            FLOAT (53)     NULL,
    [PageCount]                  INT            NULL,
    [UnlimitedFlag]              AS             (case when [MaxSize]=(-1) then (1) else (0) end),
    [SpaceFreeFlag]              AS             (case when [PercentageFree]<[DatabaseFileSpaceThreshold] then (1) else (0) end),
    [FileSizeFlag]               AS             (case when ((1)-[FileSize]/[MaxSize])<[DatabaseFileSpaceThreshold] then (1) else (0) end),
    [InstanceEnvironment]        VARCHAR (60)   NULL
);

