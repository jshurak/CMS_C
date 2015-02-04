CREATE TABLE [dbo].[MonitoredBlocking] (
    [BlockingID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [InstanceID]          INT            NULL,
    [Spid]                SMALLINT       NULL,
    [Status]              VARCHAR (30)   NULL,
    [LoginName]           VARCHAR (128)  NULL,
    [HostName]            VARCHAR (128)  NULL,
    [ProgramName]         VARCHAR (128)  NULL,
    [OpenTran]            SMALLINT       NULL,
    [DatabaseName]        VARCHAR (128)  NULL,
    [Command]             VARCHAR (16)   NULL,
    [LastWaitType]        VARCHAR (32)   NULL,
    [waittime]            BIGINT         NULL,
    [LastBatchTime]       DATETIME       NULL,
    [StartCollectionTime] DATETIME       NULL,
    [EndCollectionTime]   DATETIME       NULL,
    [SQLStatement]        NVARCHAR (MAX) NULL,
    CONSTRAINT [pk_monitoredblocking] PRIMARY KEY CLUSTERED ([BlockingID] ASC)
);

