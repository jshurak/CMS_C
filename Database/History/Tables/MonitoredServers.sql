CREATE TABLE [History].[MonitoredServers] (
    [HistoryID]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [HistoryDate]            DATETIME      NULL,
    [ServerID]               INT           NULL,
    [ServerName]             VARCHAR (128) NULL,
    [Environment]            VARCHAR (60)  NULL,
    [MonitorServer]          BIT           NULL,
    [TotalMemory]            BIGINT        NULL,
    [Manufacturer]           VARCHAR (128) NULL,
    [Model]                  VARCHAR (128) NULL,
    [IPAddress]              VARCHAR (15)  NULL,
    [OperatingSystem]        VARCHAR (128) NULL,
    [BitLevel]               TINYINT       NULL,
    [DateInstalled]          DATETIME      NULL,
    [NumberofProcessors]     TINYINT       NULL,
    [NumberofProcessorCores] TINYINT       NULL,
    [ProcessorClockSpeed]    SMALLINT      NULL,
    [DateCreated]            DATETIME      NULL,
    [DateLastBoot]           DATETIME      NULL,
    [MonitorDrives]          BIT           NULL,
    CONSTRAINT [pk_hmonitoredservers] PRIMARY KEY NONCLUSTERED ([HistoryID] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoredservers]
    ON [History].[MonitoredServers]([HistoryDate] ASC);

