CREATE TABLE [History].[MonitoredDrives] (
    [HistoryID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [HistoryDate]          DATETIME      NULL,
    [DriveID]              INT           NULL,
    [ServerID]             INT           NULL,
    [TotalCapacity]        BIGINT        NULL,
    [FreeSpace]            BIGINT        NULL,
    [PercentFreeThreshold] TINYINT       NULL,
    [DateCreated]          DATETIME      NULL,
    [VolumeName]           VARCHAR (128) NULL,
    [MountPoint]           VARCHAR (60)  NULL,
    [DeviceID]             VARCHAR (60)  NULL,
    CONSTRAINT [pk_hmonitoreddrives] PRIMARY KEY NONCLUSTERED ([HistoryID] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoreddrives]
    ON [History].[MonitoredDrives]([HistoryDate] ASC);

