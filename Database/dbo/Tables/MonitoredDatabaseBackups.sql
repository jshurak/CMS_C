CREATE TABLE [dbo].[MonitoredDatabaseBackups] (
    [BackupID]                   INT      IDENTITY (1, 1) NOT NULL,
    [BackupRecordDate]           DATETIME NULL,
    [DatabaseID]                 INT      NULL,
    [LastFullBackupDate]         DATETIME NULL,
    [LastDifferentialBackupDate] DATETIME NULL,
    [LastLogBackupDate]          DATETIME NULL,
    CONSTRAINT [pk_monitoreddatabasebackups] PRIMARY KEY CLUSTERED ([BackupID] ASC)
);

