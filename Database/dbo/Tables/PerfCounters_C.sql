CREATE TABLE [dbo].[PerfCounters_C] (
    [CounterID]         SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CounterName]       VARCHAR (250) NULL,
    [IsServerCounter]   BIT           NULL,
    [IsInstanceCounter] BIT           NULL,
    [MonitorCounter]    BIT           NULL,
    [CounterCategory]   VARCHAR (128) NULL
);

