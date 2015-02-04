CREATE TABLE [History].[MonitoredDatabaseFiles] (
    [HistoryID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [HistoryDate]                DATETIME       NULL,
    [DatabaseFileID]             INT            NULL,
    [InstanceID]                 INT            NULL,
    [DatabaseID]                 INT            NULL,
    [LogicalName]                VARCHAR (60)   NULL,
    [PhysicalName]               VARCHAR (60)   NULL,
    [FileSize]                   FLOAT (53)     NULL,
    [UsedSpace]                  FLOAT (53)     NULL,
    [MaxSize]                    FLOAT (53)     NULL,
    [AvailableSpace]             FLOAT (53)     NULL,
    [PercentageFree]             DECIMAL (4, 3) NULL,
    [Growth]                     FLOAT (53)     NULL,
    [GrowthType]                 VARCHAR (60)   NULL,
    [DateCreated]                DATETIME       NULL,
    [MonitorDatabaseFileSpace]   BIT            NULL,
    [DatabaseFileSpaceThreshold] DECIMAL (4, 3) NULL,
    [FileType]                   VARCHAR (10)   NULL,
    [Directory]                  VARCHAR (250)  NULL,
    [DriveID]                    INT            NULL,
    CONSTRAINT [pk_hmonitoreddatabasefiles] PRIMARY KEY NONCLUSTERED ([HistoryID] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoreddatabasefiles]
    ON [History].[MonitoredDatabaseFiles]([HistoryDate] ASC);

