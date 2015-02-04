CREATE TABLE [dbo].[CurrentBackupsOutstanding] (
    [BackupID]                   INT           NULL,
    [ServerName]                 VARCHAR (128) NULL,
    [InstanceName]               VARCHAR (128) NULL,
    [DatabaseName]               VARCHAR (128) NULL,
    [BackupRecordDate]           DATETIME      NULL,
    [LastFullBackupDate]         DATETIME      NULL,
    [FullFlag]                   BIT           NULL,
    [LastDifferentialBackupDate] DATETIME      NULL,
    [DiffFlag]                   BIT           NULL,
    [LastLogBackupDate]          DATETIME      NULL,
    [TFlag]                      BIT           NULL,
    [PageID]                     BIGINT        NULL,
    [DatabaseID]                 INT           NULL,
    [InstanceEnvironment]        VARCHAR (60)  NULL
);

