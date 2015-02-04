CREATE TABLE [dbo].[MonitoredDrives] (
    [DriveID]              INT            IDENTITY (1, 1) NOT NULL,
    [ServerID]             INT            NULL,
    [TotalCapacity]        BIGINT         NULL,
    [FreeSpace]            BIGINT         NULL,
    [PercentFreeThreshold] DECIMAL (4, 3) CONSTRAINT [c_default_Percent] DEFAULT ((0.100)) NULL,
    [DateCreated]          DATETIME       CONSTRAINT [c_default_DrivesCreateDate] DEFAULT (getdate()) NULL,
    [DateUpdated]          DATETIME       CONSTRAINT [c_default_DrivesUpdateDate] DEFAULT (getdate()) NULL,
    [VolumeName]           VARCHAR (128)  NULL,
    [MountPoint]           VARCHAR (60)   NULL,
    [DeviceID]             VARCHAR (60)   NULL,
    [PercentageFree]       AS             (CONVERT([decimal](4,2),round((([FreeSpace]*(1.0))/[TotalCapacity])*(1.0),(2)))),
    [Deleted]              BIT            NULL,
    [DateDeleted]          DATETIME       NULL,
    CONSTRAINT [pk_monitoreddrives] PRIMARY KEY CLUSTERED ([DriveID] ASC)
);

