CREATE TABLE [History].[MonitoredDatabases] (
    [HistoryID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [HistoryDate]          DATETIME      NULL,
    [DatabaseID]           INT           NULL,
    [ServerID]             INT           NULL,
    [InstanceID]           INT           NULL,
    [DatabaseName]         VARCHAR (128) NULL,
    [CreationDate]         DATETIME      NULL,
    [CompatibilityLevel]   INT           NULL,
    [Collation]            VARCHAR (60)  NULL,
    [Size]                 FLOAT (53)    NULL,
    [DataSpaceUsage]       FLOAT (53)    NULL,
    [IndexSpaceUsage]      FLOAT (53)    NULL,
    [SpaceAvailable]       FLOAT (53)    NULL,
    [RecoveryModel]        VARCHAR (25)  NULL,
    [AutoClose]            BIT           NULL,
    [AutoShrink]           BIT           NULL,
    [ReadOnly]             BIT           NULL,
    [PageVerify]           VARCHAR (25)  NULL,
    [Owner]                VARCHAR (60)  NULL,
    [DateCreated]          DATETIME      NULL,
    [MonitorDatabaseFiles] BIT           NULL,
    [Status]               VARCHAR (60)  NULL,
    [Deleted]              BIT           NULL,
    [DatabaseGUID]         VARCHAR (36)  NULL,
    CONSTRAINT [pk_hmonitoreddatabases] PRIMARY KEY NONCLUSTERED ([HistoryID] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoreddatabases]
    ON [History].[MonitoredDatabases]([HistoryDate] ASC);

