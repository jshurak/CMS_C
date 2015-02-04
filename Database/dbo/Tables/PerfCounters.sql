CREATE TABLE [dbo].[PerfCounters] (
    [CounterID]         SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CounterName]       VARCHAR (250) NULL,
    [IsServerCounter]   BIT           NULL,
    [IsInstanceCounter] BIT           NULL,
    [MonitorCounter]    BIT           NULL,
    [CounterCategory]   VARCHAR (128) NULL
);


GO
CREATE CLUSTERED INDEX [cl_CounterName]
    ON [dbo].[PerfCounters]([CounterName] ASC);

