CREATE TABLE [dbo].[MonitoredInstanceJobs] (
    [JobID]             INT           IDENTITY (1, 1) NOT NULL,
    [InstanceID]        INT           NULL,
    [ServerID]          INT           NULL,
    [JobName]           VARCHAR (128) NULL,
    [JobGUID]           VARCHAR (36)  NULL,
    [JobCategory]       VARCHAR (128) NULL,
    [JobOwner]          VARCHAR (60)  NULL,
    [LastRunDate]       DATETIME      NULL,
    [NextRunDate]       DATETIME      NULL,
    [JobOutcome]        VARCHAR (60)  NULL,
    [JobEnabled]        BIT           NULL,
    [JobScheduled]      BIT           NULL,
    [JobDuration]       INT           NULL,
    [JobCreationDate]   DATETIME      NULL,
    [JobModifiedDate]   DATETIME      NULL,
    [JobEmailLevel]     VARCHAR (60)  NULL,
    [JobPageLevel]      VARCHAR (60)  NULL,
    [OperatorToEmail]   VARCHAR (60)  NULL,
    [OperatorToPage]    VARCHAR (60)  NULL,
    [DateCreated]       DATETIME      NULL,
    [DateUpdated]       DATETIME      NULL,
    [OperatorToNetSend] VARCHAR (60)  NULL,
    [JobNetSendLevel]   VARCHAR (60)  NULL,
    [FailFlag]          AS            (case when [JobOutcome]='Failed' then (1) else (0) end),
    [NotifyFlag]        AS            (case when [JobEmailLevel]='Never' AND [JobPageLevel]='Never' AND [JobNetSendLevel]='Never' then (1) else (0) end),
    [OwnerFlag]         BIT           NULL,
    [MonitorJob]        BIT           CONSTRAINT [c_default_monitorjob] DEFAULT ((1)) NULL,
    [DateDeleted]       DATETIME      NULL,
    [Deleted]           BIT           NULL,
    CONSTRAINT [pk_monitoredinstancejobs] PRIMARY KEY CLUSTERED ([JobID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_JobName]
    ON [dbo].[MonitoredInstanceJobs]([JobName] ASC)
    INCLUDE([JobID], [InstanceID], [LastRunDate], [NextRunDate]);

