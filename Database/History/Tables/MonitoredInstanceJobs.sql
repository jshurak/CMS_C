CREATE TABLE [History].[MonitoredInstanceJobs] (
    [HistoryId]   INT          IDENTITY (1, 1) NOT NULL,
    [HistoryDate] DATETIME     NULL,
    [JobID]       INT          NULL,
    [LastRunDate] DATETIME     NULL,
    [JobOutcome]  VARCHAR (60) NULL,
    [JobDuration] INT          NULL,
    CONSTRAINT [pk_hmonitoredinstancejobs] PRIMARY KEY NONCLUSTERED ([HistoryId] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoredinstancejobs]
    ON [History].[MonitoredInstanceJobs]([HistoryDate] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_jobID_Duration]
    ON [History].[MonitoredInstanceJobs]([JobID] ASC, [JobDuration] ASC);

