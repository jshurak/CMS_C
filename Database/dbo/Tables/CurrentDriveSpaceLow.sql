CREATE TABLE [dbo].[CurrentDriveSpaceLow] (
    [ServerName]              VARCHAR (128)  NULL,
    [DriveID]                 INT            NULL,
    [MountPoint]              VARCHAR (60)   NULL,
    [FreeSpace]               BIGINT         NULL,
    [TotalCapacity]           BIGINT         NULL,
    [PercentageFree]          DECIMAL (4, 3) NULL,
    [PercentageFreeThreshold] DECIMAL (4, 3) NULL,
    [PageCount]               INT            NULL,
    [ServerEnvironment]       VARCHAR (60)   NULL
);

