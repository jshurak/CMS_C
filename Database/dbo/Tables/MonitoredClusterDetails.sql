CREATE TABLE [dbo].[MonitoredClusterDetails] (
    [DetailID]       INT      IDENTITY (1, 1) NOT NULL,
    [ClusterID]      INT      NULL,
    [InstanceID]     INT      NULL,
    [ServerID]       INT      NULL,
    [IsCurrentOwner] BIT      NULL,
    [DateCreated]    DATETIME NULL,
    [DateUpdated]    DATETIME NULL,
    [Deleted]        BIT      NULL,
    [DateDeleted]    DATETIME NULL,
    [FailOverFlag]   BIT      NULL
);

