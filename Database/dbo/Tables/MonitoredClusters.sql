CREATE TABLE [dbo].[MonitoredClusters] (
    [ClusterID]   INT           IDENTITY (1, 1) NOT NULL,
    [ClusterName] VARCHAR (128) NULL,
    [DateCreated] DATETIME      NULL,
    [DateUpdated] DATETIME      NULL,
    [Deleted]     BIT           NULL,
    [DateDeleted] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ClusterID] ASC)
);

