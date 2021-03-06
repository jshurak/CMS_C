USE [master]
GO
/****** Object:  Database [CMS_C]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE DATABASE [CMS_C]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CMS_C.mdf' , SIZE = 358400KB , MAXSIZE = 364544KB , FILEGROWTH = 102400KB )
 LOG ON 
( NAME = N'CMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CMS_C_Log.ldf' , SIZE = 90112KB , MAXSIZE = 10240000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [CMS_C] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CMS_C].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CMS_C] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CMS_C] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CMS_C] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CMS_C] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CMS_C] SET ARITHABORT OFF 
GO
ALTER DATABASE [CMS_C] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CMS_C] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CMS_C] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CMS_C] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CMS_C] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CMS_C] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CMS_C] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CMS_C] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CMS_C] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CMS_C] SET  ENABLE_BROKER 
GO
ALTER DATABASE [CMS_C] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CMS_C] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CMS_C] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CMS_C] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CMS_C] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CMS_C] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CMS_C] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CMS_C] SET RECOVERY FULL 
GO
ALTER DATABASE [CMS_C] SET  MULTI_USER 
GO
ALTER DATABASE [CMS_C] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CMS_C] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CMS_C] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CMS_C] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'CMS_C', N'ON'
GO
USE [CMS_C]
GO
/****** Object:  User [PA01WJSHURAK01\sa_sql]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE USER [PA01WJSHURAK01\sa_sql] FOR LOGIN [PA01WJSHURAK01\sa_sql] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [PA01WJSHURAK01\sa_sql]
GO
/****** Object:  Schema [Baseline]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE SCHEMA [Baseline]
GO
/****** Object:  Schema [History]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE SCHEMA [History]
GO
/****** Object:  Schema [Reporting]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE SCHEMA [Reporting]
GO
/****** Object:  UserDefinedFunction [dbo].[CharCounter]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CharCounter] (@string varchar(128))
returns varchar(20)
as
begin
declare @nSpaces int = LEN(@string) - LEN(REPLACE(@string,' ',''))
declare @i int, @out varchar(20)


while @nSpaces > 0
BEGIN
	SELECT @i = CHARINDEX(' ',@string,0) - 1
	SET @out = CONCAT(@out,CAST(@i as varchar))
	--PRINT CAST(@i as varchar(5))

	SET @string = SUBSTRING(@string,@i + 2,LEN(@string))
	SET @nSpaces -= 1
END
SET @out = CONCAT(@out,CAST(LEN(@string) as varchar))
RETURN @out
END

GO
/****** Object:  UserDefinedFunction [dbo].[get_css]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_css] ()
RETURNS varchar(max)
AS
BEGIN
	DECLARE @header VARCHAR(MAX)
	SET @header = 
	N'<style type="text/css">
	#box-table
	{
	font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
	font-size: 12px;
	text-align: center;
	border-collapse: collapse;
	border-top: 7px solid #9baff1;
	border-bottom: 7px solid #9baff1;
	}
	#box-table th
	{
	font-size: 13px;
	font-weight: normal;
	background: #b9c9fe;
	border-right: 2px solid #9baff1;
	border-left: 2px solid #9baff1;
	border-bottom: 2px solid #9baff1;
	color: #039;
	}
	#box-table td
	{
	border-right: 1px solid #aabcfe;
	border-left: 1px solid #aabcfe;
	border-bottom: 1px solid #aabcfe;
	color: #669;
	text-align: left;
	}
	tr:nth-child(odd)	 { background-color:#eee; }
	tr:nth-child(even)	 { background-color:#fff; }	
	</style>'
RETURN (@header)
END

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_JobIntToSeconds]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_JobIntToSeconds]
(
      @run_duration INT
/*=========================================================================
Created By: Brian K. McDonald, MCDBA, MCSD (www.SQLBIGeek.com)
Email:      bmcdonald@SQLBIGeek.com
Twitter:    @briankmcdonald
Date:       10/29/2010
Purpose:    Convert the duration of a job to seconds
            A value of 13210 would be 1 hour, 32 minutes and 10 seconds,
            but I want to return this value in seconds. Which is 5530!
            Then I can sum all of the values and to find total duration.
 
Usage:      SELECT dbo.ufn_JobIntToSeconds (13210)
----------------------------------------------------------------------------
Modification History
----------------------------------------------------------------------------
 
==========================================================================*/
)
RETURNS INT
AS
BEGIN
 
RETURN
CASE
            --hours, minutes and seconds
            WHEN LEN(@run_duration) > 4 THEN CONVERT(VARCHAR(4),LEFT(@run_duration,LEN(@run_duration)-4)) * 3600
             + LEFT(RIGHT(@run_duration,4),2) * 60 + RIGHT(@run_duration,2)
            --minutes and seconds
            WHEN LEN(@run_duration) = 4 THEN LEFT(@run_duration,2) * 60 + RIGHT(@run_duration,2)
            WHEN LEN(@run_duration) = 3 THEN LEFT(@run_duration,1) * 60 + RIGHT(@run_duration,2)
      ELSE --only seconds    
            RIGHT(@run_duration,2) 
      END
END

GO
/****** Object:  Table [Baseline].[MonitoredInstancePerfCounters]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Baseline].[MonitoredInstancePerfCounters](
	[CollectionDate] [datetime] NULL,
	[InstanceID] [int] NULL,
	[CounterID] [smallint] NULL,
	[Value] [decimal](30, 15) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ClusteredIndex-20140728-105217]    Script Date: 2/4/2015 9:53:55 AM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20140728-105217] ON [Baseline].[MonitoredInstancePerfCounters]
(
	[CollectionDate] DESC,
	[InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [Baseline].[MonitoredInstanceServerWaits]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Baseline].[MonitoredInstanceServerWaits](
	[InstanceID] [int] NULL,
	[WaitID] [int] NULL,
	[Waiting_Task_Count] [bigint] NULL,
	[Wait_Time_MS] [bigint] NULL,
	[Max_Wait_Time_MS] [bigint] NULL,
	[Signal_Wait_Time_MS] [bigint] NULL,
	[CollectionDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [Baseline].[MonitoredServerPerfCounters]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Baseline].[MonitoredServerPerfCounters](
	[CollectionDate] [datetime] NULL,
	[ServerID] [int] NULL,
	[CounterID] [smallint] NULL,
	[Value] [decimal](30, 15) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Alert_PageRecords]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Alert_PageRecords](
	[PageID] [bigint] IDENTITY(1,1) NOT NULL,
	[OperatorID] [int] NULL,
	[PageCategory] [varchar](28) NULL,
	[PageDate] [datetime] NULL,
	[PageStatus] [varchar](28) NULL,
	[PageCount] [int] NULL,
	[PageRetryCount] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Alerts_Operators]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alerts_Operators](
	[OperatorID] [int] IDENTITY(1,1) NOT NULL,
	[OnDuty] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CacheController]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CacheController](
	[CacheID] [smallint] IDENTITY(1,1) NOT NULL,
	[CacheName] [varchar](25) NULL,
	[Refresh] [bit] NULL,
	[LastRefreshDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CMS_Version]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CMS_Version](
	[VersionNumber] [varchar](10) NULL,
	[Description] [varchar](250) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CollectionLog]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CollectionLog](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[ModuleName] [varchar](60) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Config]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Config](
	[ConfigID] [smallint] IDENTITY(1,1) NOT NULL,
	[Setting] [varchar](128) NULL,
	[intValue] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CriticalityMatrix]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CriticalityMatrix](
	[Criticality] [tinyint] NULL,
	[PageThresholdMinutes] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CurrentBackupsOutstanding]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentBackupsOutstanding](
	[BackupID] [int] NULL,
	[ServerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[DatabaseName] [varchar](128) NULL,
	[BackupRecordDate] [datetime] NULL,
	[LastFullBackupDate] [datetime] NULL,
	[FullFlag] [bit] NULL,
	[LastDifferentialBackupDate] [datetime] NULL,
	[DiffFlag] [bit] NULL,
	[LastLogBackupDate] [datetime] NULL,
	[TFlag] [bit] NULL,
	[PageID] [bigint] NULL,
	[DatabaseID] [int] NULL,
	[InstanceEnvironment] [varchar](60) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentBlocking]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrentBlocking](
	[InstanceID] [int] NULL,
	[CurrentBlockingSpid] [smallint] NULL,
	[LastBatchTime] [datetime] NULL,
	[BlockingID] [bigint] NULL,
	[PageCount] [smallint] NULL,
	[LastPageDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CurrentDatabaseFileIssues]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CurrentDatabaseFileIssues](
	[DatabaseFileID] [int] NOT NULL,
	[ServerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[DatabaseName] [varchar](128) NULL,
	[LogicalName] [varchar](128) NULL,
	[FileSize] [float] NULL,
	[UsedSpace] [float] NULL,
	[AvailableSpace] [float] NULL,
	[MaxSize] [float] NULL,
	[PercentageFree] [decimal](4, 3) NULL,
	[Growth] [float] NULL,
	[GrowthType] [varchar](60) NULL,
	[DatabaseFileSpaceThreshold] [decimal](4, 3) NULL,
	[FileType] [varchar](10) NULL,
	[AvailableGrowth] [float] NULL,
	[PageCount] [int] NULL,
	[UnlimitedFlag]  AS (case when [MaxSize]=(-1) then (1) else (0) end),
	[SpaceFreeFlag]  AS (case when [PercentageFree]<[DatabaseFileSpaceThreshold] then (1) else (0) end),
	[FileSizeFlag]  AS (case when ((1)-[FileSize]/[MaxSize])<[DatabaseFileSpaceThreshold] then (1) else (0) end)
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[CurrentDatabaseFileIssues] ADD [InstanceEnvironment] [varchar](60) NULL

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentDriveSpaceLow]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentDriveSpaceLow](
	[ServerName] [varchar](128) NULL,
	[DriveID] [int] NULL,
	[MountPoint] [varchar](60) NULL,
	[FreeSpace] [bigint] NULL,
	[TotalCapacity] [bigint] NULL,
	[PercentageFree] [decimal](4, 3) NULL,
	[PercentageFreeThreshold] [decimal](4, 3) NULL,
	[PageCount] [int] NULL,
	[ServerEnvironment] [varchar](60) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentOfflineInstances]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentOfflineInstances](
	[InstanceID] [int] NULL,
	[InstanceName] [varchar](128) NULL,
	[OfflineDate] [datetime] NULL,
	[Environment] [varchar](60) NULL,
	[PageCount] [smallint] NULL,
	[LastPageDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentOfflineServers]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentOfflineServers](
	[ServerID] [int] NULL,
	[ServerName] [varchar](128) NULL,
	[OfflineDate] [datetime] NULL,
	[Environment] [varchar](60) NULL,
	[PageCount] [smallint] NULL,
	[LastPageDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentOfflineServices]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentOfflineServices](
	[ServerID] [int] NULL,
	[ServerName] [varchar](128) NULL,
	[InstanceID] [int] NULL,
	[InstanceName] [varchar](128) NULL,
	[ServiceName] [varchar](60) NULL,
	[ServiceStatus] [varchar](20) NULL,
	[OfflineDate] [datetime] NULL,
	[Environment] [varchar](60) NULL,
	[PageCount] [smallint] NULL,
	[LastPageDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredAvailabilityGroupDBDetails]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredAvailabilityGroupDBDetails](
	[DetailID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[IsFailoverReady] [bit] NULL,
	[SynchronizationState] [varchar](13) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[AGDatabaseGuid] [varchar](36) NULL,
	[AvailabilityGroupID] [int] NULL,
	[ReplicaID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredAvailabilityGroupListeners]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredAvailabilityGroupListeners](
	[ListenerID] [int] IDENTITY(1,1) NOT NULL,
	[ListenerName] [varchar](128) NULL,
	[ListenerGUID] [varchar](36) NULL,
	[ListenerIPAddress] [varchar](15) NULL,
	[ListenerIPState] [varchar](16) NULL,
	[ListenerPort] [varchar](10) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[AvailabilityGroupID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ListenerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredAvailabilityGroupReplicas]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredAvailabilityGroupReplicas](
	[ReplicaID] [int] IDENTITY(1,1) NOT NULL,
	[ReplicaName] [varchar](128) NULL,
	[AvailabilityGroupID] [int] NULL,
	[InstanceID] [int] NULL,
	[AvailabilityMode] [varchar](18) NULL,
	[FailoverMode] [varchar](10) NULL,
	[CurrentRole] [varchar](9) NULL,
	[SynchronizationState] [varchar](13) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[FailoverFlag] [bit] NULL,
	[ReplicaGUID] [varchar](36) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReplicaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredAvailabilityGroups]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredAvailabilityGroups](
	[AvailabilityGroupID] [int] IDENTITY(1,1) NOT NULL,
	[AvailabilityGroupName] [varchar](128) NULL,
	[AvailabilityGroupGUID] [varchar](36) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AvailabilityGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredBlocking]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredBlocking](
	[BlockingID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[Spid] [smallint] NULL,
	[Status] [varchar](30) NULL,
	[LoginName] [varchar](128) NULL,
	[HostName] [varchar](128) NULL,
	[ProgramName] [varchar](128) NULL,
	[OpenTran] [smallint] NULL,
	[DatabaseName] [varchar](128) NULL,
	[Command] [varchar](16) NULL,
	[LastWaitType] [varchar](32) NULL,
	[waittime] [bigint] NULL,
	[LastBatchTime] [datetime] NULL,
	[StartCollectionTime] [datetime] NULL,
	[EndCollectionTime] [datetime] NULL,
	[SQLStatement] [nvarchar](max) NULL,
 CONSTRAINT [pk_monitoredblocking] PRIMARY KEY CLUSTERED 
(
	[BlockingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredClusterDetails]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonitoredClusterDetails](
	[DetailID] [int] IDENTITY(1,1) NOT NULL,
	[ClusterID] [int] NULL,
	[InstanceID] [int] NULL,
	[ServerID] [int] NULL,
	[IsCurrentOwner] [bit] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[FailOverFlag] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MonitoredClusters]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredClusters](
	[ClusterID] [int] IDENTITY(1,1) NOT NULL,
	[ClusterName] [varchar](128) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ClusterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredDatabaseBackups]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonitoredDatabaseBackups](
	[BackupID] [int] IDENTITY(1,1) NOT NULL,
	[BackupRecordDate] [datetime] NULL,
	[DatabaseID] [int] NULL,
	[LastFullBackupDate] [datetime] NULL,
	[LastDifferentialBackupDate] [datetime] NULL,
	[LastLogBackupDate] [datetime] NULL,
 CONSTRAINT [pk_monitoreddatabasebackups] PRIMARY KEY CLUSTERED 
(
	[BackupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MonitoredDatabaseFiles]    Script Date: 2/4/2015 9:53:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredDatabaseFiles](
	[DatabaseFileID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[LogicalName] [varchar](60) NULL,
	[PhysicalName] [varchar](60) NULL,
	[FileSize] [float] NULL,
	[UsedSpace] [float] NULL,
	[MaxSize] [float] NULL,
	[AvailableSpace] [float] NULL,
	[PercentageFree] [decimal](4, 3) NULL,
	[Growth] [float] NULL,
	[GrowthType] [varchar](60) NULL,
	[DateCreated] [datetime] NULL CONSTRAINT [c_default_Dates]  DEFAULT (getdate()),
	[DateUpdated] [datetime] NULL CONSTRAINT [c_default_DateUpdated]  DEFAULT (getdate()),
	[MonitorDatabaseFileSpace] [bit] NULL CONSTRAINT [c_default_MonitorSpace]  DEFAULT ((1)),
	[DatabaseFileSpaceThreshold] [decimal](4, 3) NULL CONSTRAINT [c_default_threshold]  DEFAULT ((0.10)),
	[FileType] [varchar](10) NULL,
	[Directory] [varchar](250) NULL,
	[DriveID] [int] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
 CONSTRAINT [pk_monitoreddatabasefiles] PRIMARY KEY CLUSTERED 
(
	[DatabaseFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredDatabases](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NULL,
	[InstanceID] [int] NOT NULL,
	[DatabaseName] [varchar](128) NOT NULL,
	[CreationDate] [datetime] NULL,
	[CompatibilityLevel] [int] NULL,
	[Collation] [varchar](60) NULL,
	[Size] [float] NULL,
	[DataSpaceUsage] [float] NULL,
	[IndexSpaceUsage] [float] NULL,
	[SpaceAvailable] [float] NULL,
	[RecoveryModel] [varchar](25) NULL,
	[AutoClose] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[ReadOnly] [bit] NULL,
	[PageVerify] [varchar](25) NULL,
	[Owner] [varchar](60) NULL,
	[DateCreated] [datetime] NULL CONSTRAINT [c_default_DB_DateCreated]  DEFAULT (getdate()),
	[Dateupdated] [datetime] NULL CONSTRAINT [c_default_DatabasesUpdateDate]  DEFAULT (getdate()),
	[MonitorDatabaseFiles] [bit] NULL CONSTRAINT [c_default_databasefiles]  DEFAULT ((1)),
	[Status] [varchar](60) NULL,
	[Deleted] [bit] NULL CONSTRAINT [c_Default_Deleted]  DEFAULT ((0)),
	[FBThreshold] [int] NULL CONSTRAINT [c_Default_FBThreshold]  DEFAULT ((1440)),
	[FullBackupFlag] [bit] NULL CONSTRAINT [c_Default_FullBackupFlag]  DEFAULT ((1)),
	[DBThreshold] [int] NULL CONSTRAINT [c_Default_DBThreshold]  DEFAULT ((1440)),
	[DiffBackupFlag] [bit] NULL CONSTRAINT [c_Default_DiffBackupFlag]  DEFAULT ((0)),
	[TBThreshold] [int] NULL CONSTRAINT [c_Default_TBThreshold]  DEFAULT ((40)),
	[TranBackupFlag]  AS (case when [RecoveryModel]='SIMPLE' then (0) else (1) end),
	[DateDeleted] [datetime] NULL,
	[DatabaseGUID] [varchar](36) NULL,
	[AvailabilityGroupID] [int] NULL,
 CONSTRAINT [pk_monitoreddatabases] PRIMARY KEY CLUSTERED 
(
	[DatabaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredDrives](
	[DriveID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NULL,
	[TotalCapacity] [bigint] NULL,
	[FreeSpace] [bigint] NULL,
	[PercentFreeThreshold] [decimal](4, 3) NULL CONSTRAINT [c_default_Percent]  DEFAULT ((0.100)),
	[DateCreated] [datetime] NULL CONSTRAINT [c_default_DrivesCreateDate]  DEFAULT (getdate()),
	[DateUpdated] [datetime] NULL CONSTRAINT [c_default_DrivesUpdateDate]  DEFAULT (getdate()),
	[VolumeName] [varchar](128) NULL,
	[MountPoint] [varchar](60) NULL,
	[DeviceID] [varchar](60) NULL,
	[PercentageFree]  AS (CONVERT([decimal](4,2),round((([FreeSpace]*(1.0))/[TotalCapacity])*(1.0),(2)))),
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
 CONSTRAINT [pk_monitoreddrives] PRIMARY KEY CLUSTERED 
(
	[DriveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredInstanceJobs]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[MonitoredInstanceJobs](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[ServerID] [int] NULL,
	[JobName] [varchar](128) NULL,
	[JobGUID] [varchar](36) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobCategory] [varchar](128) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobOwner] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [LastRunDate] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [NextRunDate] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobOutcome] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobEnabled] [bit] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobScheduled] [bit] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobDuration] [int] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobCreationDate] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobModifiedDate] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobEmailLevel] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobPageLevel] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [OperatorToEmail] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [OperatorToPage] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [DateCreated] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [DateUpdated] [datetime] NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [OperatorToNetSend] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [JobNetSendLevel] [varchar](60) NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [FailFlag]  AS (case when [JobOutcome]='Failed' then (1) else (0) end)
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [NotifyFlag]  AS (case when [JobEmailLevel]='Never' AND [JobPageLevel]='Never' AND [JobNetSendLevel]='Never' then (1) else (0) end)
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [OwnerFlag] [bit] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [MonitorJob] [bit] NULL CONSTRAINT [c_default_monitorjob]  DEFAULT ((1))
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [DateDeleted] [datetime] NULL
ALTER TABLE [dbo].[MonitoredInstanceJobs] ADD [Deleted] [bit] NULL
 CONSTRAINT [pk_monitoredinstancejobs] PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredInstancePerfCounters]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonitoredInstancePerfCounters](
	[CollectionDate] [datetime] NULL,
	[InstanceID] [int] NULL,
	[CounterID] [smallint] NULL,
	[Value] [decimal](30, 15) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MonitoredInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredInstances](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NULL,
	[InstanceName] [varchar](128) NOT NULL,
	[Environment] [varchar](60) NULL,
	[MonitorInstance] [bit] NULL CONSTRAINT [c_default_Monitor]  DEFAULT ((1)),
	[Edition] [varchar](128) NULL,
	[Version] [varchar](20) NULL,
	[isClustered] [bit] NULL,
	[MaxMemory] [bigint] NULL,
	[MinMemory] [int] NULL,
	[DateCreated] [datetime] NULL CONSTRAINT [c_default_datecreated]  DEFAULT (getdate()),
	[ServiceAccount] [varchar](60) NULL,
	[DateUpdated] [datetime] NULL CONSTRAINT [c_default_InstanceUpdateDate]  DEFAULT (getdate()),
	[MonitorDatabases] [bit] NULL CONSTRAINT [c_default_monitordatabases]  DEFAULT ((1)),
	[MonitorBlocking] [bit] NULL CONSTRAINT [c_default_MonitorBlocking]  DEFAULT ((1)),
	[Criticality] [tinyint] NULL CONSTRAINT [c_default_Criticality]  DEFAULT ((1)),
	[SSAS] [bit] NULL,
	[SSRS] [bit] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[ProductLevel] [varchar](10) NULL,
	[PingStatus] [bit] NULL,
	[SSASStatus] [varchar](20) NULL,
	[SSRSStatus] [varchar](20) NULL,
	[AgentStatus] [varchar](20) NULL,
	[MonitorWaitStats] [bit] NULL,
	[HasBaseline] [bit] NULL,
	[BaselineStartDate] [datetime] NULL,
	[HasWaitsBaseline] [bit] NULL,
	[WaitsBaselineStartDate] [datetime] NULL,
 CONSTRAINT [pk_monitoredinstances] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_instancename] UNIQUE NONCLUSTERED 
(
	[InstanceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitoredInstanceServerWaits]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonitoredInstanceServerWaits](
	[InstanceID] [int] NULL,
	[WaitID] [int] NULL,
	[Waiting_Task_Count] [bigint] NULL,
	[Wait_Time_MS] [bigint] NULL,
	[Max_Wait_Time_MS] [bigint] NULL,
	[Signal_Wait_Time_MS] [bigint] NULL,
	[CollectionDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ci_CollectionDateWaitID]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [ci_CollectionDateWaitID] ON [dbo].[MonitoredInstanceServerWaits]
(
	[CollectionDate] ASC,
	[WaitID] ASC,
	[InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonitoredServerPerfCounters]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonitoredServerPerfCounters](
	[CollectionDate] [datetime] NULL,
	[ServerID] [int] NULL,
	[CounterID] [smallint] NULL,
	[Value] [decimal](30, 15) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MonitoredServers]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitoredServers](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](128) NOT NULL,
	[Environment] [varchar](60) NULL,
	[MonitorServer] [bit] NULL CONSTRAINT [c_monitorServers]  DEFAULT ((1)),
	[TotalMemory] [bigint] NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[IPAddress] [varchar](15) NULL,
	[OperatingSystem] [varchar](128) NULL,
	[BitLevel] [char](2) NULL,
	[DateInstalled] [datetime] NULL,
	[NumberofProcessors] [tinyint] NULL,
	[NumberofProcessorCores] [tinyint] NULL,
	[ProcessorClockSpeed] [smallint] NULL,
	[DateCreated] [datetime] NULL CONSTRAINT [c_default_CreateDate]  DEFAULT (getdate()),
	[DateUpdated] [datetime] NULL CONSTRAINT [c_default_UpdateDate]  DEFAULT (getdate()),
	[DateLastBoot] [datetime] NULL,
	[MonitorDrives] [bit] NULL CONSTRAINT [c_monitorDrives]  DEFAULT ((1)),
	[PingStatus] [bit] NULL,
	[Deleted] [bit] NULL,
	[DateDeleted] [datetime] NULL,
	[IsVirtualServerName] [bit] NULL,
	[HasBaseline] [bit] NULL,
	[BaselineStartDate] [datetime] NULL,
 CONSTRAINT [pk_monitoredservers] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_servername] UNIQUE NONCLUSTERED 
(
	[ServerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PerfCounters]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PerfCounters](
	[CounterID] [smallint] IDENTITY(1,1) NOT NULL,
	[CounterName] [varchar](250) NULL,
	[IsServerCounter] [bit] NULL,
	[IsInstanceCounter] [bit] NULL,
	[MonitorCounter] [bit] NULL,
	[CounterCategory] [varchar](128) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [cl_CounterName]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cl_CounterName] ON [dbo].[PerfCounters]
(
	[CounterName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PerfCounters_C]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PerfCounters_C](
	[CounterID] [smallint] IDENTITY(1,1) NOT NULL,
	[CounterName] [varchar](250) NULL,
	[IsServerCounter] [bit] NULL,
	[IsInstanceCounter] [bit] NULL,
	[MonitorCounter] [bit] NULL,
	[CounterCategory] [varchar](128) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerWaits]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerWaits](
	[WaitID] [int] IDENTITY(1,1) NOT NULL,
	[WaitType] [nvarchar](60) NULL,
	[Capture] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServiceAccounts]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceAccounts](
	[ServiceID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](60) NULL,
	[MSSQL] [bit] NULL,
	[Databases] [bit] NULL,
	[AgentJobs] [bit] NULL,
 CONSTRAINT [pk_serviceaccounts] PRIMARY KEY CLUSTERED 
(
	[ServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[MonitoredDatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredDatabaseFiles](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[DatabaseFileID] [int] NULL,
	[InstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[LogicalName] [varchar](60) NULL,
	[PhysicalName] [varchar](60) NULL,
	[FileSize] [float] NULL,
	[UsedSpace] [float] NULL,
	[MaxSize] [float] NULL,
	[AvailableSpace] [float] NULL,
	[PercentageFree] [decimal](4, 3) NULL,
	[Growth] [float] NULL,
	[GrowthType] [varchar](60) NULL,
	[DateCreated] [datetime] NULL,
	[MonitorDatabaseFileSpace] [bit] NULL,
	[DatabaseFileSpaceThreshold] [decimal](4, 3) NULL,
	[FileType] [varchar](10) NULL,
	[Directory] [varchar](250) NULL,
	[DriveID] [int] NULL,
 CONSTRAINT [pk_hmonitoreddatabasefiles] PRIMARY KEY NONCLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoreddatabasefiles]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoreddatabasefiles] ON [History].[MonitoredDatabaseFiles]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [History].[MonitoredDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredDatabases](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[DatabaseID] [int] NULL,
	[ServerID] [int] NULL,
	[InstanceID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[CreationDate] [datetime] NULL,
	[CompatibilityLevel] [int] NULL,
	[Collation] [varchar](60) NULL,
	[Size] [float] NULL,
	[DataSpaceUsage] [float] NULL,
	[IndexSpaceUsage] [float] NULL,
	[SpaceAvailable] [float] NULL,
	[RecoveryModel] [varchar](25) NULL,
	[AutoClose] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[ReadOnly] [bit] NULL,
	[PageVerify] [varchar](25) NULL,
	[Owner] [varchar](60) NULL,
	[DateCreated] [datetime] NULL,
	[MonitorDatabaseFiles] [bit] NULL,
	[Status] [varchar](60) NULL,
	[Deleted] [bit] NULL,
	[DatabaseGUID] [varchar](36) NULL,
 CONSTRAINT [pk_hmonitoreddatabases] PRIMARY KEY NONCLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoreddatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoreddatabases] ON [History].[MonitoredDatabases]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [History].[MonitoredDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredDrives](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[DriveID] [int] NULL,
	[ServerID] [int] NULL,
	[TotalCapacity] [bigint] NULL,
	[FreeSpace] [bigint] NULL,
	[PercentFreeThreshold] [tinyint] NULL,
	[DateCreated] [datetime] NULL,
	[VolumeName] [varchar](128) NULL,
	[MountPoint] [varchar](60) NULL,
	[DeviceID] [varchar](60) NULL,
 CONSTRAINT [pk_hmonitoreddrives] PRIMARY KEY NONCLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoreddrives]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoreddrives] ON [History].[MonitoredDrives]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [History].[MonitoredInstanceJobs]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredInstanceJobs](
	[HistoryId] [int] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[JobID] [int] NULL,
	[LastRunDate] [datetime] NULL,
	[JobOutcome] [varchar](60) NULL,
	[JobDuration] [int] NULL,
 CONSTRAINT [pk_hmonitoredinstancejobs] PRIMARY KEY NONCLUSTERED 
(
	[HistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoredinstancejobs]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoredinstancejobs] ON [History].[MonitoredInstanceJobs]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [History].[MonitoredInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredInstances](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServerID] [int] NULL,
	[InstanceName] [varchar](128) NULL,
	[Environment] [varchar](60) NULL,
	[MonitorInstance] [bit] NULL,
	[Edition] [varchar](128) NULL,
	[Version] [varchar](20) NULL,
	[isClustered] [bit] NULL,
	[MaxMemory] [bigint] NULL,
	[MinMemory] [int] NULL,
	[DateCreated] [datetime] NULL,
	[ServiceAccount] [varchar](60) NULL,
	[MonitorDatabases] [bit] NULL,
	[MonitorBlocking] [bit] NULL,
	[Criticality] [tinyint] NULL,
	[ProductLevel] [varchar](10) NULL,
 CONSTRAINT [pk_hmonitoredinstances] PRIMARY KEY NONCLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoredinstances]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoredinstances] ON [History].[MonitoredInstances]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [History].[MonitoredServers]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[MonitoredServers](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDate] [datetime] NULL,
	[ServerID] [int] NULL,
	[ServerName] [varchar](128) NULL,
	[Environment] [varchar](60) NULL,
	[MonitorServer] [bit] NULL,
	[TotalMemory] [bigint] NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[IPAddress] [varchar](15) NULL,
	[OperatingSystem] [varchar](128) NULL,
	[BitLevel] [tinyint] NULL,
	[DateInstalled] [datetime] NULL,
	[NumberofProcessors] [tinyint] NULL,
	[NumberofProcessorCores] [tinyint] NULL,
	[ProcessorClockSpeed] [smallint] NULL,
	[DateCreated] [datetime] NULL,
	[DateLastBoot] [datetime] NULL,
	[MonitorDrives] [bit] NULL,
 CONSTRAINT [pk_hmonitoredservers] PRIMARY KEY NONCLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [cidx_hmonitoredservers]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE CLUSTERED INDEX [cidx_hmonitoredservers] ON [History].[MonitoredServers]
(
	[HistoryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [Reporting].[Reports]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Reporting].[Reports](
	[ReportID] [int] IDENTITY(1,1) NOT NULL,
	[ReportName] [varchar](60) NULL,
	[Environment] [varchar](25) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Reporting].[Subscriptions]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reporting].[Subscriptions](
	[ReportID] [int] NULL,
	[OperatorID] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Database_Inventory]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Database_Inventory]
AS
SELECT mi.InstanceName,mdb.DatabaseName,mdb.CompatibilityLevel,mdb.RecoveryModel,mdf.FileCount as DataFileCount,mdf.MaxSize,mdb.Size AS [DatabaseSize],mdf.Growth
FROM MonitoredDatabases mdb
JOIN MonitoredInstances mi
ON mdb.InstanceID = mi.InstanceID
JOIN
( 
SELECT databaseid,MaxSize,Growth,count(*) as FileCount
FROM MonitoredDatabaseFiles
WHERE FileType = 'DATA'
GROUP BY DatabaseID,MaxSize,Growth
) AS mdf
ON mdb.DatabaseID = mdf.DatabaseID
WHERE mdb.DatabaseName NOT IN ('master','model','tempdb','msdb')

GO
/****** Object:  View [dbo].[SQL_Server_Instance_Inventory]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SQL_Server_Instance_Inventory]
	AS 
SELECT mi.InstanceName,mi.Version,mi.Edition,mi.ProductLevel
,CASE
	WHEN mi.isClustered = 0 THEN 'STANDALONE'
	ELSE 'CLUSTERED'
END [Type]
,ms.ServerName
,ms.NumberofProcessorCores as Cores
,ms.NumberofProcessors as Processors
,mi.MaxMemory as Memory
FROM monitoredinstances mi
JOIN MonitoredServers ms
ON ms.ServerID = mi.ServerID
where mi.Deleted = 0

GO
/****** Object:  View [dbo].[vw_MonitoredDatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_MonitoredDatabaseFiles]
AS
SELECT ms.ServerName
      ,mi.[InstanceName]
      ,md.[DatabaseName]
      ,mdf.[LogicalName]
      ,mdf.[PhysicalName]
      ,mdf.[FileSize]
      ,mdf.[UsedSpace]
      ,mdf.[MaxSize]
      ,mdf.[AvailableSpace]
      ,mdf.[PercentageFree]
      ,mdf.[Growth]
      ,mdf.[GrowthType]
      ,mdf.[DateCreated]
      ,mdf.[DateUpdated]
      ,mdf.[MonitorDatabaseFileSpace]
      ,mdf.[DatabaseFileSpaceThreshold]
      ,mdf.[FileType]
      ,mdf.[Directory]
      ,mdr.MountPoint
  FROM [dbo].[MonitoredDatabaseFiles] mdf
  JOIN [dbo].[MonitoredDatabases] md
  ON mdf.DatabaseID = md.DatabaseID
  JOIN [dbo].[MonitoredInstances] mi
  ON mdf.InstanceID = mi.InstanceID
  JOIN [dbo].[MonitoredServers] ms
  ON mi.ServerID = ms.ServerID
  JOIN [dbo].[MonitoredDrives] mdr
  ON mdf.DriveID = mdr.DriveID

GO
/****** Object:  View [dbo].[vw_MonitoredDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_MonitoredDatabases]
AS
SELECT ms.ServerName
	  ,mi.InstanceName
      ,md.[DatabaseName]
      ,md.[CreationDate]
      ,md.[CompatibilityLevel]
      ,md.[Collation]
      ,md.[Size]
      ,md.[DataSpaceUsage]
      ,md.[IndexSpaceUsage]
      ,md.[SpaceAvailable]
      ,md.[RecoveryModel]
      ,md.[AutoClose]
      ,md.[AutoShrink]
      ,md.[ReadOnly]
      ,md.[PageVerify]
      ,md.[Owner]
      ,md.[DateCreated]
      ,md.[Dateupdated]
      ,md.[MonitorDatabaseFiles]
      ,md.[Status]
      ,md.[Deleted]
      ,md.[FBThreshold]
      ,md.[FullBackupFlag]
      ,md.[DBThreshold]
      ,md.[DiffBackupFlag]
      ,md.[TBThreshold]
      ,md.[TranBackupFlag]
      ,md.[DateDeleted]
  FROM [dbo].[MonitoredDatabases] md
  JOIN [dbo].[MonitoredInstances] mi
  ON md.InstanceID = mi.InstanceID
  JOIN [dbo].[MonitoredServers] ms
  ON md.ServerID = ms.ServerID

GO
/****** Object:  View [dbo].[vw_MonitoredDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_MonitoredDrives]
AS
SELECT ms.[ServerName]
      ,md.[TotalCapacity]
      ,md.[FreeSpace]
      ,md.[PercentFreeThreshold]
      ,md.[DateCreated]
      ,md.[DateUpdated]
      ,md.[VolumeName]
      ,md.[MountPoint]
      ,md.[DeviceID]
      ,md.[PercentageFree]
      ,md.[Deleted]
      ,md.[DateDeleted]
  FROM [dbo].[MonitoredDrives] md
  JOIN [dbo].[MonitoredServers] ms
  ON md.ServerID = ms.ServerID

GO
/****** Object:  View [dbo].[vw_MonitoredInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_MonitoredInstances]
AS
SELECT ms.ServerName 
	  ,mi.[InstanceName]
      ,mi.[MonitorInstance]
      ,mi.[Edition]
      ,mi.[Version]
      ,mi.[isClustered]
      ,mi.[MaxMemory]
      ,mi.[MinMemory]
      ,mi.[DateCreated]
      ,mi.[ServiceAccount]
      ,mi.[DateUpdated]
      ,mi.[MonitorDatabases]
      ,mi.[MonitorBlocking]
      ,mi.[Criticality]
  FROM [dbo].[MonitoredInstances] mi
  JOIN [dbo].[MonitoredServers] ms
  ON mi.ServerID = ms.ServerID

GO
/****** Object:  View [History].[vw_MonitoredDatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [History].[vw_MonitoredDatabaseFiles]
as
select hmdf.*,md.DatabaseName,mi.InstanceName,ms.servername
from History.MonitoredDatabaseFiles hmdf
JOIN MonitoredDatabases md
ON hmdf.DatabaseID = md.DatabaseID
JOIN MonitoredInstances mi
on md.InstanceID = mi.InstanceID
join monitoredservers ms
on md.ServerID = ms.serverid

GO
/****** Object:  View [History].[vw_MonitoredDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [History].[vw_MonitoredDatabases]
as
select hmd.*,mi.InstanceName,ms.ServerName
from history.monitoreddatabases hmd
join monitoredinstances mi
on hmd.InstanceID = mi.InstanceID
join monitoredservers ms
on hmd.ServerID = ms.ServerID

GO
/****** Object:  View [History].[vw_MonitoredDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [History].[vw_MonitoredDrives]
as
select hmd.*,ms.ServerName
from history.monitoredDrives hmd
join monitoredservers ms
on hmd.ServerID = ms.ServerID

GO
/****** Object:  View [History].[vw_MonitoredInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [History].[vw_MonitoredInstances]
AS
SELECT hmi.*,ms.ServerName
FROM history.MonitoredInstances hmi
JOIN MonitoredServers ms
ON hmi.ServerID = ms.ServerID

GO
/****** Object:  Index [idx_DateInstanceCounter]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [idx_DateInstanceCounter] ON [Baseline].[MonitoredInstancePerfCounters]
(
	[CollectionDate] ASC,
	[InstanceID] ASC,
	[CounterID] ASC
)
INCLUDE ( 	[Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_InstanceID]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [idx_InstanceID] ON [Baseline].[MonitoredInstanceServerWaits]
(
	[InstanceID] ASC
)
INCLUDE ( 	[CollectionDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_DateServerCounter]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [idx_DateServerCounter] ON [Baseline].[MonitoredServerPerfCounters]
(
	[CollectionDate] ASC,
	[ServerID] ASC,
	[CounterID] ASC
)
INCLUDE ( 	[Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20140718-104355]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20140718-104355] ON [Baseline].[MonitoredServerPerfCounters]
(
	[ServerID] ASC,
	[CollectionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_JobName]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [idx_JobName] ON [dbo].[MonitoredInstanceJobs]
(
	[JobName] ASC
)
INCLUDE ( 	[JobID],
	[InstanceID],
	[LastRunDate],
	[NextRunDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_jobID_Duration]    Script Date: 2/4/2015 9:53:56 AM ******/
CREATE NONCLUSTERED INDEX [idx_jobID_Duration] ON [History].[MonitoredInstanceJobs]
(
	[JobID] ASC,
	[JobDuration] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MonitoredInstances]  WITH CHECK ADD  CONSTRAINT [chk_InstanceEnvironment] CHECK  (([Environment]='QA' OR [Environment]='DEVELOPMENT' OR [Environment]='PRODUCTION'))
GO
ALTER TABLE [dbo].[MonitoredInstances] CHECK CONSTRAINT [chk_InstanceEnvironment]
GO
ALTER TABLE [dbo].[MonitoredServers]  WITH CHECK ADD  CONSTRAINT [chk_ServerEnvironment] CHECK  (([Environment]='QA' OR [Environment]='DEVELOPMENT' OR [Environment]='PRODUCTION'))
GO
ALTER TABLE [dbo].[MonitoredServers] CHECK CONSTRAINT [chk_ServerEnvironment]
GO
/****** Object:  StoredProcedure [dbo].[AddCMSServer]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddCMSServer]
@ServerName varchar(128)
,@InstanceName varchar(128) = NULL
,@Environment varchar(20) = 'PRODUCTION'
,@IsVirtualServerName bit = 0
AS
BEGIN
SET NOCOUNT ON

	DECLARE @ServerID int,@InstanceID int
	
	--Check for server existence, add if not
	IF NOT EXISTS(SELECT ServerID FROM MonitoredServers WHERE ServerName = @ServerName)
		BEGIN
			INSERT INTO MonitoredServers (ServerName,Environment,deleted,IsVirtualServerName) VALUES (@ServerName,@Environment,0,@IsVirtualServerName)
			SELECT @ServerID = SCOPE_IDENTITY()

			exec CacheUpdateController @CacheID = 1, @Refresh = 1
		END
	ELSE
		SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ServerName

	IF @InstanceName IS NOT NULL
	BEGIN	
		--check for instance existence add if not
		IF NOT EXISTS(SELECT InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName AND ServerID = @ServerID)
		BEGIN
			INSERT INTO MonitoredInstances (ServerID,InstanceName,Environment,Deleted) VALUES (@ServerID,@InstanceName,@Environment,0)

			exec CacheUpdateController @CacheID = 2, @Refresh = 1
		END
		ELSE
			BEGIN
				SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName AND ServerID = @ServerID
				PRINT 'Instance already exists. InstanceName: ' + @InstanceName + ', InstanceID: ' + CAST(@InstanceID as varchar)
			END
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_AgentJobs]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_AgentJobs]
@Environment varchar(20)
AS
BEGIN
	DECLARE @bodyMsg nvarchar(max)
	DECLARE @subject nvarchar(max)
	DECLARE @Message nvarchar(max)
	SET @subject = 'Agent Job Report ' + @Environment

	BEGIN
		IF EXISTS(SELECT TOP 1 mj.JobID FROM MonitoredInstanceJobs mj JOIN MonitoredInstances mi ON mj.InstanceID = mi.InstanceID WHERE mi.Environment = @Environment AND mj.JobEnabled = 1 AND mj.MonitorJob = 1 AND mj.Deleted = 0 AND mj.JobCategory <> 'Report Server' AND (mj.FailFlag = 1 OR mj.NotifyFlag = 1 OR mj.OwnerFlag = 1) AND LastRunDate > DATEADD(day,-2,GETDATE()))
			BEGIN
				SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green"><th>ServerName</th>
				<th>InstanceName</th>
				<th>JobName</th>
				<th>LastRunDate</th>
				<th>NextRunDate</th>
				<th>JobOwner</th>
				<th>JobOutcome</th>
				<th>JobEmailLevel</th>
				<th>JobPageLevel</th>
				<th>JobNetSendLevel</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td>'+ms.ServerName+'</td>
						<td>'+mi.InstanceName+'</td>
						<td>'+mj.JobName+'</td>
						<td>'+CAST(mj.LastRunDate AS VARCHAR)+'</td>
						<td>'+CAST(mj.NextRunDate AS VARCHAR)+'</td>
						<td>'+CASE WHEN OwnerFlag = 1 THEN '<font color = orange>' ELSE '' END + mj.JobOwner+'</td>	
						<td>'+CASE WHEN FailFlag = 1 THEN '<font color = red>' ELSE '' END + mj.JobOutcome+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobEmailLevel+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobPageLevel+'</td>
						<td>'+CASE WHEN NotifyFlag = 1 THEN '<font color = red>' ELSE '' END +mj.JobNetSendLevel+'</td>
					</tr>'
					FROM MonitoredInstanceJobs mj
					JOIN MonitoredInstances mi
					ON mj.InstanceID = mi.InstanceID
					JOIN MonitoredServers ms
					ON mj.ServerID = ms.ServerID
					WHERE mi.Environment = @Environment AND mj.Deleted = 0 AND
					mj.JobEnabled = 1 AND mj.MonitorJob = 1 AND mj.JobCategory <> 'Report Server' AND
					(mj.FailFlag = 1 OR mj.OwnerFlag = 1 OR NotifyFlag = 1)
					AND LastRunDate > DATEADD(day,-2,GETDATE())
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'AgentReport',@subject,1, @HTML = 1
			END
		END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_Backups]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Alert_Backups]
@Environment varchar(20)
AS
BEGIN
SET NOCOUNT ON
               DECLARE @RunDate DATETIME = GETDATE()


                /*********************************************
                                Clear out old backup records
                **********************************************/
                DELETE
                FROM CurrentBackupsOutstanding
                WHERE BackupRecordDate < DATEADD(mi,-1440,@RunDate)
                /*************************************
                                CHECK FOR NEW OUTSTANDING BACKSUP
                **************************************/
                INSERT INTO CurrentBackupsOutstanding (BackupID,ServerName,InstanceName,InstanceEnvironment,DatabaseName,DatabaseID,BackupRecordDate,LastFullBackupDate,FullFlag,LastDIfferentialBackupDate,DiffFlag,LastLogBackupDate,TFlag)
                SELECT mdb.BackupID,ms.ServerName,mi.InstanceName,mi.Environment,md.DatabaseName,md.DatabaseID,mdb.BackupRecordDate
                ,mdb.LastFullBackupDate
                ,CASE
                                WHEN md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold THEN 1
                                ELSE 0
                END FullFlag
                ,mdb.LastDifferentialBackupDate
                ,CASE
                                WHEN md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold THEN 1
                                ELSE 0
                END DiffFlag
                ,mdb.LastLogBackupDate
                ,CASE
                                WHEN md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold THEN 1
                                ELSE 0
                END TFlag
                FROM MonitoredDatabaseBackups mdb
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                JOIN MonitoredInstances mi
                ON md.InstanceID = mi.InstanceID
                JOIN MonitoredServers ms
                ON mi.ServerID = ms.ServerID
                LEFT OUTER JOIN CurrentBackupsOutstanding cb
                ON mdb.BackupID = cb.BackupID
                WHERE md.Deleted = 0 AND md.ReadOnly = 0 AND
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440
                AND 
                ((md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold)
                OR 
                (
					(md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold)
					AND
					(md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.DBThreshold)
				) 
                OR
                (md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold))
                AND cb.BackupID IS NULL

                /*
                                CHECK FOR ANY RECORDS THAT SHOULD BE REMOVED FROM CURRENT OUTSTANDING
                */
                DELETE cb
                FROM CurrentBackupsOutstanding cb
                JOIN MonitoredDatabaseBackups mdb
                ON cb.BackupID = mdb.BackupID
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                WHERE md.Deleted = 1 OR md.ReadOnly = 1 OR
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440
                AND
                (
				(md.FullBackupFlag = 0 OR (md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) <		md.FBThreshold))
                AND
                (
					(md.DiffBackupFlag = 0 OR (md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) < md.DBThreshold)) AND (md.FullBackupFlag = 0 OR (md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) <		md.DBThreshold))
				)
                AND
                (md.TranBackupFlag = 0 OR (md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) < md.TBThreshold))
				)

                /*
                                UPDATE EXISTING RECORDS WITH LATEST 
                */
                UPDATE CurrentBackupsOutstanding
                SET
                LastFullBackupDate = mdb.LastFullBackupDate
                ,FullFlag = 
                CASE
                                WHEN md.FullBackupFlag = 1 AND DATEDIFF(mi,mdb.LastFullBackupDate,@RunDate) >= md.FBThreshold THEN 1
                                ELSE 0
                END 
                ,LastDifferentialBackupDate = mdb.LastDifferentialBackupDate
                ,DiffFlag = 
                CASE
                                WHEN md.DiffBackupFlag = 1 AND DATEDIFF(mi,mdb.LastDifferentialBackupDate,@RunDate) >= md.DBThreshold THEN 1
                                ELSE 0
                END 
                ,LastLogBackupDate = mdb.LastLogBackupDate
                ,TFlag = 
                CASE
                                WHEN md.TranBackupFlag = 1 AND DATEDIFF(mi,mdb.LastLogBackupDate,@RunDate) >= md.TBThreshold THEN 1
                                ELSE 0
                END 
                FROM MonitoredDatabaseBackups mdb
                JOIN MonitoredDatabases md
                ON mdb.DatabaseID = md.DatabaseID
                JOIN MonitoredInstances mi
                ON md.InstanceID = mi.InstanceID
                JOIN MonitoredServers ms
                ON mi.ServerID = ms.ServerID
                JOIN CurrentBackupsOutstanding cb
                ON cb.BackupID = mdb.BackupID
                WHERE md.Deleted = 0 AND 
                DATEDIFF(mi,mdb.BackupRecordDate,@RunDate) <= 1440


			IF EXISTS(SELECT TOP 1 BackupID FROM CurrentBackupsOutstanding WHERE InstanceEnvironment = @Environment)
				BEGIN
					DECLARE @bodyMsg nvarchar(max)
					DECLARE @subject nvarchar(max)
					DECLARE @Message nvarchar(max)

					SET @subject = 'Missing Backup Report ' + @Environment


					SET @Message = dbo.get_css()


					SET @Message = @Message + N'<table id="box-table" >' +
					N'<tr><font color="Green"><th>ServerName</th>
					<th>InstanceName</th>
					<th>DatabaseName</th>
					<th>LastFullBackupDate</th>
					<th>LastDifferentialBackupDate</th>
					<th>LastLogBackupDate</th>
					</tr>' 
					SELECT @Message = @Message + N'
					<tr>
						<td>'+[cb].[ServerName]+'</td>
						<td>'+[cb].[InstanceName]+'</td>
						<td>'+[cb].[DatabaseName]+'</td>
						<td>'+CASE WHEN FullFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.FullBackupFlag = 0 THEN 'NA' WHEN [cb].[LastFullBackupDate] = '01/01/1900 00:00:00' THEN 'No record of a full backup' ELSE CONVERT(VARCHAR(30),[cb].[LastFullBackupDate],120) END+'</td>
						<td>'+CASE WHEN DiffFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.DiffBackupFlag = 0 THEN 'NA' ELSE CONVERT(VARCHAR(30),[cb].[LastDifferentialBackupDate],120) END+'</td>
						<td>'+CASE WHEN TFlag = 1 THEN '<font color="red">' ELSE '' END +CASE WHEN md.TranBackupFlag = 0 THEN 'NA' WHEN [cb].[LastLogBackupDate] = '01/01/1900 00:00:00' THEN 'No record of log backups' ELSE CONVERT(VARCHAR(30),[cb].[LastLogBackupDate],120) END+'</td>
					</tr>'
					FROM [dbo].[CurrentBackupsOutstanding] cb
					JOIN [dbo].[MonitoredDatabases] md
					ON cb.DatabaseID = md.DatabaseID
					WHERE cb.InstanceEnvironment = @Environment
					ORDER BY [BackupID]
					SET @Message = @Message + '</table>' 

					exec CMS_SendPage @Message,'BackupReport',@subject,1, @HTML = 1
				END

END

GO
/****** Object:  StoredProcedure [dbo].[Alert_Blocking]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_Blocking]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @InstanceID INT,@Spid SMALLINT,@LoginName varchar(128),@Duration int,@StartCollectionTime DATETIME, @PageCount INT, @LastPageDate DATETIME, @PageThreshold INT,@PageDate DATETIME,@BlockingID BIGINT
	DECLARE @Message VARCHAR(MAX),@ServerName varchar(128),@InstanceName varchar(128),@DatabaseName varchar(128),@SQLStatement varchar(max),@Command varchar(16),@ProgramName varchar(128)
	IF EXISTS(SELECT TOP 1 CB.InstanceID from CurrentBlocking CB JOIN dbo.MonitoredBlocking MB ON CB.BlockingID = MB.BlockingID WHERE MB.DatabaseName <> 'distribution')
		BEGIN
			SET @Message = ''

			SELECT CB.InstanceID,CB.CurrentBlockingSpid,MB.LoginName,MB.StartCollectionTime,DATEDIFF(ss,MB.StartCollectionTime,GETDATE()) AS [Duration],CB.PageCount,CB.LastPageDate,CB.BlockingID,MS.ServerName,MI.InstanceName,MB.DatabaseName,MB.SQLStatement,MB.Command,MB.ProgramName
			INTO #tmp
			FROM CurrentBlocking CB
			JOIN MonitoredBlocking MB
			ON CB.BlockingID = MB.BlockingID
			JOIN MonitoredInstances MI
			ON MI.InstanceID = MB.InstanceID
			JOIN MonitoredServers MS
			ON MS.ServerID = MI.ServerID
			WHERE MB.DatabaseName <> 'distribution'

			WHILE (SELECT COUNT(*) FROM #tmp) > 0
			BEGIN
				SELECT TOP 1
					@ServerName = ServerName,
					@InstanceName = InstanceName,
					@DatabaseName = DatabaseName,
					@SQLStatement = SQLStatement,
					@Command = Command,
					@Duration = Duration,
					@ProgramName = ProgramName,
					@InstanceID = InstanceID,
					@Spid = CurrentBlockingSpid,
					@LoginName = LoginName,
					@StartCollectionTime = StartCollectionTime,
					@PageCount = [PageCount],
					@LastPageDate = LastPageDate,
					@BlockingID = BlockingID
				FROM #tmp

				SELECT @PageThreshold = C.PageThresholdMinutes
				FROM CriticalityMatrix C
				JOIN MonitoredInstances I
				ON I.Criticality = C.Criticality
				WHERE I.InstanceID = @InstanceID

				--Handle Initial Page
				SET @PageDate = GETDATE()
				IF @PageCount IS NULL AND DATEDIFF(mi,@StartCollectionTime,@PageDate) >= @PageThreshold
				BEGIN
					SET @Message = @Message + CHAR(13) + 'Server Name: ' + @ServerName + CHAR(13) + 'Instance Name: ' + @InstanceName + CHAR(13) + 'Session: ' + CAST(@Spid as varchar) + CHAR(13) + 'LoginName: ' + @LoginName + CHAR(13) + 'Duration: ' + CAST(@Duration AS VARCHAR) + CHAR(13) + 'Database Name: ' + @DatabaseName + CHAR(13) + 'Statement Type: ' + @Command + CHAR(13) + 'Program Name: ' + @ProgramName + CHAR(13) + 'SQL Statement: ' + @SQLStatement + CHAR(13)
					EXEC [dbo].[CMS_SendPage] @Body = @Message, @Category = 'BlockingReport',@PageCount = @PageCount,@Title = 'Blocking Report'
					
					UPDATE CurrentBlocking
					SET [PageCount] = 1
					,LastPageDate = @PageDate
					WHERE BlockingID = @BlockingID

					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END
				--Handle non first page
				ELSE IF @PageCount > 0 AND DATEDIFF(mi,@LastPageDate,@PageDate) >= @PageThreshold
				BEGIN
					SET @Message = @Message + CHAR(13) + 'Server Name: ' + @ServerName + CHAR(13) + 'Instance Name: ' + @InstanceName + CHAR(13) + 'Session: ' + CAST(@Spid as varchar) + CHAR(13) + 'LoginName: ' + @LoginName  + CHAR(13) + 'Duration: ' + CAST(@Duration AS VARCHAR) + CHAR(13)  + 'Database Name: ' + @DatabaseName + CHAR(13) + 'Statement Type: ' + @Command + CHAR(13) + 'Program Name: ' + @ProgramName + CHAR(13) + 'SQL Statement: ' + @SQLStatement + CHAR(13)
					EXEC [dbo].[CMS_SendPage] @Body = @Message, @Category = 'BlockingReport',@PageCount = @PageCount,@Title = 'Blocking Report'
					
					UPDATE CurrentBlocking
					SET [PageCount] = @PageCount + 1
					,LastPageDate = @PageDate
					WHERE BlockingID = @BlockingID

					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END
				ELSE
				BEGIN
					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END

			END
			DROP TABLE #tmp
		END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_DatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_DatabaseFiles]
@Report varchar(25) = 'daily'
,@Environment varchar(25)
AS
BEGIN
       SET NOCOUNT ON
       DECLARE @Message varchar(max), @Subject varchar(60) = 'Database File Alert ' + @Environment
       /**************************************************
              Insert new records
       ***************************************************/
       INSERT INTO [dbo].[CurrentDatabaseFileIssues]
                        ([DatabaseFileID],[ServerName],[InstanceName],[InstanceEnvironment],[DatabaseName],[LogicalName],[FileSize],[UsedSpace],[AvailableSpace],[MaxSize],[PercentageFree],[Growth],[GrowthType],[DatabaseFileSpaceThreshold],[FileType],[AvailableGrowth])
       SELECT       mdf.DatabaseFileID,ms.ServerName,mi.InstanceName,mi.Environment,mdb.DatabaseName,mdf.LogicalName,mdf.FileSize,mdf.UsedSpace,mdf.AvailableSpace,mdf.MaxSize,mdf.PercentageFree,mdf.Growth,mdf.GrowthType,mdf.DatabaseFileSpaceThreshold,mdf.FileType
                           ,1-(mdf.FileSize/mdf.MaxSize) as AvailableGrowth
                           FROM MonitoredDatabaseFiles mdf
                           JOIN MonitoredDatabases mdb
                           ON mdf.DatabaseID = mdb.DatabaseID
                           JOIN MonitoredInstances mi
                           ON mdf.InstanceID = mi.InstanceID
                           JOIN MonitoredServers ms
                           ON mi.ServerID = ms.ServerID
                           LEFT OUTER JOIN CurrentDatabaseFileIssues cdf
                           ON mdf.DatabaseFileID = cdf.DatabaseFileID
                           WHERE mdb.Deleted = 0 AND
                           mdb.DatabaseName NOT IN ('master','model') AND
                           cdf.DatabaseFileID IS NULL AND
                           (mdf.PercentageFree < mdf.DatabaseFileSpaceThreshold
                           OR
                           ((mdf.MaxSize = -1) OR (1-(mdf.FileSize/mdf.MaxSize) < mdf.DatabaseFileSpaceThreshold)))

                     /***************************************************************************
                           Delete records that are fixed
                     ***************************************************************************/

                     DELETE cdf
                     FROM CurrentDatabaseFileIssues cdf
                     JOIN MonitoredDatabaseFiles mdf
                     ON cdf.DatabaseFileID = mdf.DatabaseFileID
                     JOIN MonitoredDatabases md
                     ON mdf.DatabaseID = md.DatabaseID
                     WHERE md.MonitorDatabaseFiles = 0 OR md.Deleted = 1 OR
                     (mdf.PercentageFree >= mdf.DatabaseFileSpaceThreshold
                     AND
                     mdf.MaxSize <> -1
                     AND 1-(mdf.FileSize/mdf.MaxSize) >= mdf.DatabaseFileSpaceThreshold)

                     /**********************************************************************
                           Update Existing Records                  
                     ***********************************************************************/
                     UPDATE cdf
                        SET cdf.[FileSize] = mdf.FileSize
                             ,cdf.[UsedSpace] = mdf.UsedSpace
                             ,cdf.[AvailableSpace] = mdf.AvailableSpace
                             ,cdf.[MaxSize] = mdf.MaxSize
                             ,cdf.[PercentageFree] = mdf.PercentageFree
                             ,cdf.[Growth] = mdf.Growth
                             ,cdf.[GrowthType] = mdf.GrowthType
                             ,cdf.[DatabaseFileSpaceThreshold] = mdf.DatabaseFileSpaceThreshold
                             ,cdf.[FileType] = mdf.FileType
                             ,cdf.[AvailableGrowth] = 1-(mdf.FileSize/mdf.MaxSize) 
                           FROM MonitoredDatabaseFiles mdf
                           JOIN CurrentDatabaseFileIssues cdf
                           ON mdf.DatabaseFileID = cdf.DatabaseFileID




                     IF EXISTS (SELECT TOP 1 DatabaseFileID FROM CurrentDatabaseFileIssues WHERE InstanceEnvironment = @Environment)
                           IF @Report = 'daily'
                                  BEGIN
                                         SET @Message = dbo.get_css()
                                                SET @Message = @Message + N'<table id="box-table" >' +
                                                       N'<tr><font color="Green">
                                                         <th>ServerName</th>      
                                                         <th>InstanceName</th>
                                                         <th>DatabaseName</th>
                                                         <th>LogicalName</th>
                                                         <th>FileType</th>
                                                         <th>UsedSpace</th>
                                                         <th>FileSize</th>
                                                         <th>AvailableSpace</th>
                                                         <th>MaxSize</th>
                                                         <th>PercentageFree</th>
                                                       </tr>'
                                                       SELECT @Message = @Message + N'
                                                       <tr>
                                                              <td>'+[ServerName]+'</td>
                                                              <td>'+[InstanceName]+'</td>
                                                              <td>'+[DatabaseName]+'</td>
                                                              <td>'+[LogicalName]+'</td>
                                                              <td>'+[FileType]+'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' ELSE '' END + CAST(CAST(UsedSPace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CAST(CAST(FileSize AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(CAST(AvailableSpace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN UnlimitedFlag = 1 THEN '<font color="orange">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CASE WHEN MaxSize =-1 THEN 'Unlimited' ELSE CAST(CAST(MaxSize AS BIGINT) AS VARCHAR) END +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(PercentageFree*100 AS VARCHAR) +'</td>
                                                       </tr>'
                                                       FROM [dbo].[CurrentDatabaseFileIssues]
													   WHERE InstanceEnvironment = @Environment
                                                       SET @Message = @Message + '</table>' 
                                                       exec CMS_SendPage @Message,'DatabaseFileReport',@subject,1, @HTML = 1
                                  END
                           IF @Report = 'hourly' AND EXISTS(SELECT TOP 1 DatabaseFileID FROM CurrentDatabaseFileIssues WHERE FileSizeFlag = 1 AND InstanceEnvironment = @Environment)
                                  BEGIN
                                         SET @Message = dbo.get_css()
                                                SET @Message = @Message + N'<table id="box-table" >' +
                                                       N'<tr><font color="Green">
                                                         <th>ServerName</th>      
                                                         <th>InstanceName</th>
                                                         <th>DatabaseName</th>
                                                         <th>LogicalName</th>
                                                         <th>FileType</th>
                                                         <th>UsedSpace</th>
                                                         <th>FileSize</th>
                                                         <th>AvailableSpace</th>
                                                         <th>MaxSize</th>
                                                         <th>PercentageFree</th>
                                                       </tr>'
                                                       SELECT @Message = @Message + N'
                                                       <tr>
                                                              <td>'+[ServerName]+'</td>
                                                              <td>'+[InstanceName]+'</td>
                                                              <td>'+[DatabaseName]+'</td>
                                                              <td>'+[LogicalName]+'</td>
                                                              <td>'+[FileType]+'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' ELSE '' END + CAST(CAST(UsedSPace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange" background="#d3d3d3">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CAST(CAST(FileSize AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(CAST(AvailableSpace AS BIGINT) AS VARCHAR) +'</td>
                                                              <td>'+CASE WHEN UnlimitedFlag = 1 THEN '<font color="orange">' WHEN FileSizeFlag = 1 THEN '<font color="red">' ELSE '' END + CASE WHEN MaxSize =-1 THEN 'Unlimited' ELSE CAST(CAST(MaxSize AS BIGINT) AS VARCHAR) END +'</td>
                                                              <td>'+CASE WHEN SpaceFreeFlag = 1 THEN '<font color="orange">' ELSE '' END + CAST(PercentageFree*100 AS VARCHAR) +'</td>
                                                       </tr>'
                                                       FROM [dbo].[CurrentDatabaseFileIssues]
                                                       WHERE FileSizeFlag = 1 
													   AND InstanceEnvironment = @Environment
                                                       SET @Message = @Message + '</table>' 
                                                       exec CMS_SendPage @Message,'DatabaseFileReport',@subject,1, @HTML = 1
                                  END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_Databases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_Databases]
AS
BEGIN 
SET NOCOUNT ON

DECLARE @Message varchar(max), @Subject varchar(60)

	IF EXISTS(SELECT TOP 1 DatabaseID FROM MonitoredDatabases WHERE DateCreated > DATEADD(mi,-30,GETDATE()))
	BEGIN
		SET @Subject  = 'New Database Found'
		SET @Message = dbo.get_css()
		SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><font color="Green">
				<th>ServerName</th>	
				<th>InstanceName</th>
				<th>DatabaseName</th>
				<th>CreationDate</th>
				<th>RecoveryModel</th>
			</tr>'
		SELECT @Message = @Message + N'
		<tr>
			<td>'+ms.[ServerName]+'</td>
			<td>'+mi.[InstanceName]+'</td>
			<td>'+md.[DatabaseName]+'</td>
			<td>'+CAST(md.[CreationDate] AS VARCHAR)+'</td>
			<td>'+md.[RecoveryModel]+'</td>
		</tr>'
		FROM MonitoredDatabases md
		JOIN MonitoredInstances mi
		ON md.InstanceID = mi.InstanceID
		JOIN MonitoredServers ms
		ON md.ServerID = ms.ServerID
		WHERE md.DateCreated > DATEADD(mi,-30,GETDATE()) 
		SET @Message = @Message + '</table>' 
		exec CMS_SendPage @Message,'DatabaseReport',@subject,1, @HTML = 1
	END

	IF EXISTS(SELECT TOP 1 DatabaseID FROM MonitoredDatabases WHERE DateDeleted > DATEADD(mi,-30,GETDATE()))
	BEGIN
		SET @Subject  = 'Database Marked as Deleted'
		SET @Message = dbo.get_css()
		SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><font color="Green">
				<th>ServerName</th>	
				<th>InstanceName</th>
				<th>DatabaseName</th>
				<th>DeletionDate</th>
			</tr>'
		SELECT @Message = @Message + N'
		<tr>
			<td>'+ms.[ServerName]+'</td>
			<td>'+mi.[InstanceName]+'</td>
			<td>'+md.[DatabaseName]+'</td>
			<td>'+CAST(md.[DateDeleted] AS VARCHAR)+'</td>
		</tr>'
		FROM MonitoredDatabases md
		JOIN MonitoredInstances mi
		ON md.InstanceID = mi.InstanceID
		JOIN MonitoredServers ms
		ON md.ServerID = ms.ServerID
		WHERE md.DateDeleted > DATEADD(mi,-30,GETDATE()) 
		SET @Message = @Message + '</table>' 
		exec CMS_SendPage @Message,'DatabaseReport',@subject,1, @HTML = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_DriveSpace]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_DriveSpace]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @DriveID int,@ServerName varchar(128),@MountPoint varchar(60),@FreeSpace bigint,@TotalCapacity BIGINT, @PercentFree DECIMAL(4,2)
	DECLARE @Message varchar(max), @Subject varchar(60) = 'Drive Space Alert'
	/**************************************************************
		Insert any low drives that don't exist in table already
	**************************************************************/
	
	INSERT INTO CurrentDriveSpaceLow (ServerName,ServerEnvironment,DriveID,MountPoint,FreeSpace,TotalCapacity,PercentageFree,PercentageFreeThreshold)
	SELECT ms.ServerName,ms.Environment,md.DriveID,md.MountPoint,md.FreeSpace,md.TotalCapacity
	,md.PercentageFree
	,md.PercentFreeThreshold
	FROM MonitoredDrives md
	JOIN MonitoredServers ms
	ON md.ServerID = ms.ServerID
	LEFT OUTER JOIN CurrentDriveSpaceLow cds
	ON md.DriveID = cds.DriveID
	WHERE md.Deleted = 0 AND
	md.PercentageFree <= md.PercentFreeThreshold
	AND cds.DriveID IS NULL

	/*************************************************************
		Delete any drives that are in the clear
	**************************************************************/
	DELETE cds
	FROM CurrentDriveSpaceLow cds
	JOIN MonitoredDrives md
	ON cds.DriveID = md.DriveID
	WHERE md.Deleted = 1 OR
	md.PercentageFree > md.PercentFreeThreshold

	/***********************************************************
		Update any Existing records
	************************************************************/
	UPDATE CurrentDriveSpaceLow
	SET FreeSpace = md.FreeSpace
	,TotalCapacity = md.TotalCapacity
	,PercentageFree = md.PercentageFree
	,PercentageFreeThreshold = md.PercentFreeThreshold
	FROM MonitoredDrives md
	JOIN CurrentDriveSpaceLow cds
	ON md.DriveID = cds.DriveID

	/******************************************************
		Begin processing alerts.
	*******************************************************/


	IF EXISTS(SELECT TOP 1 DriveID FROM CurrentDriveSpaceLow WHERE ServerEnvironment = @Environment)
		BEGIN
				SET @Message = dbo.get_css()
				SET @Message = @Message + N'<table id="box-table" >' +
					N'<tr>
					<th>ServerName</th>
					<th>MountPoint</th>
					<th>FreeSpace (MB)</th>
					<th>TotalCapacity (MB)</th>
					<th>PercentFree</th>
					</tr>'
					SELECT @Message = @Message + N'
					<tr>
						<td>'+[ServerName]+'</td>
						<td>'+[MountPoint]+'</td>
						<td>'+CAST(Freespace/1024/1024 AS VARCHAR)+'</td>
						<td>'+CAST(TotalCapacity/1024/1024 AS VARCHAR)+'</td>
						<td>'+CAST(PercentageFree * 100 AS VARCHAR)+'</td>
					</tr>'
					FROM [dbo].[CurrentDriveSpaceLow]
					WHERE ServerEnvironment = @Environment
					SET @Message = @Message + '</table>' 
					exec CMS_SendPage @Message,'DriveSpaceReport',@subject,1, @HTML = 1
			
		END

END

GO
/****** Object:  StoredProcedure [dbo].[Alert_OfflineInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_OfflineInstances]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Instance Report ' + @Environment
	--INSERT new offline instances
	INSERT INTO CurrentOfflineInstances
		(InstanceID,InstanceName,OfflineDate,Environment)
  	SELECT mi.InstanceID,
			mi.InstanceName,
			GETDATE(),
			mi.Environment
	FROM MonitoredInstances mi 
	LEFT OUTER JOIN  CurrentOfflineInstances coi ON mi.InstanceID =  coi.InstanceID
	WHERE PingStatus = 0
	AND DELETED = 0
	AND coi.InstanceID IS NULL;

	--Delete
	DELETE coi
	FROM CurrentOfflineInstances coi
	INNER JOIN MonitoredInstances mi ON coi.InstanceID = mi.InstanceID
	WHERE mi.PingStatus = 1;

	IF EXISTS(SELECT TOP 1 InstanceID FROM CurrentOfflineInstances WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>InstanceName</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+InstanceName+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineInstances
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineInstanceReport',@subject,1, @HTML = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_OfflineServers]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_OfflineServers]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Server Report ' + @Environment
	--INSERT new offline Servers
	INSERT INTO CurrentOfflineServers
		(ServerID,ServerName,OfflineDate,Environment)
  	SELECT ms.ServerID,
			ms.ServerName,
			GETDATE(),
			ms.Environment
	FROM MonitoredServers ms
	LEFT OUTER JOIN  CurrentOfflineServers co ON ms.ServerID =  co.ServerID
	WHERE PingStatus = 0
	AND DELETED = 0
	AND co.ServerID IS NULL;

	--Delete
	DELETE co
	FROM CurrentOfflineServers co
	INNER JOIN MonitoredServers ms ON co.ServerID = ms.ServerID
	WHERE ms.PingStatus = 1;

	IF EXISTS(SELECT TOP 1 ServerID FROM CurrentOfflineServers WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>ServerName</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+ServerName+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineServers
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineServerReport',@subject,1, @HTML = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_OfflineServices]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_OfflineServices]
@Environment varchar(60)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Message varchar(max)
	DECLARE @subject varchar(250)
	SET @subject = 'Offline Service Report ' + @Environment;


	--build service Names
		IF OBJECT_ID('tempdb..#ServiceNames') IS NOT NULL
			DROP TABLE #ServiceNames
	
		SELECT InstanceID,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'SQLAgent$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'SQLSERVERAGENT'
		END AgentServiceName,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'MSOLAP$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'MSSQLServerOLAPService'
		END SSASServiceName,
		CASE 
			WHEN CHARINDEX('\',InstanceName) > 0 THEN 'ReportServer$' + SUBSTRING(InstanceName,CHARINDEX('\',InstanceName) + 1, LEN(InstanceName) - CHARINDEX('\',InstanceName))
			ELSE 'ReportServer'
		END SSRSServiceName
		INTO #Servicenames
		FROM MonitoredInstances


	--INSERT new offline Servers
	INSERT INTO CurrentOfflineServices
		(ServerID,ServerName,InstanceID,InstanceName,ServiceName,ServiceStatus,OfflineDate,Environment)
  	SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.AgentServiceName,mi.AgentStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.AgentServiceName
			WHERE mi.Deleted = 0
			AND mi.AgentStatus <> 'Running'
			AND co.InstanceID IS NULL
			UNION 
			SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.SSASServiceName,mi.SSASStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.SSASServiceName
			WHERE mi.Deleted = 0
			AND mi.InstanceID not in (10,18,19,21,28,30,40,42,48,29)
			AND mi.SSAS = 1
			AND mi.SSASStatus <> 'Running'
			AND co.InstanceID IS NULL
			UNION 
			SELECT ms.ServerID,ms.ServerName,mi.InstanceID,mi.InstanceName,sn.SSRSServiceName,mi.SSRSStatus
			,Getdate() as OfflineDate
			,mi.Environment
			FROM MonitoredInstances mi
			INNER JOIN #ServiceNames sn ON mi.InstanceID = sn.InstanceID
			INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
			LEFT OUTER JOIN CurrentOfflineServices co ON mi.InstanceID = co.InstanceID AND co.ServiceName = sn.SSRSServiceName
			WHERE mi.Deleted = 0
			AND mi.InstanceID not in (3,48)
			AND mi.SSRS = 1
			AND mi.SSRSStatus <> 'Running'
			AND co.InstanceID IS NULL;

	--Delete
	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.AgentServiceName
	WHERE mi.AgentStatus = 'Running'
	
	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.SSASServiceName
	WHERE mi.SSASStatus = 'Running'
		OR mi.InstanceID IN (10,18,19,21,28,30,40,42,48,49);

	DELETE co
	FROM CurrentOfflineServices co
		INNER JOIN MonitoredInstances mi ON co.InstanceID = mi.InstanceID
		INNER JOIN #Servicenames sn ON co.InstanceID = sn.InstanceID AND co.ServiceName = sn.SSRSServiceName
	WHERE mi.SSRSStatus = 'Running'
		OR mi.InstanceID IN (3,48);


	IF EXISTS(SELECT TOP 1 ServerID FROM CurrentOfflineServices WHERE Environment = @Environment)
	BEGIN
	SET @Message = dbo.get_css()

				SET @Message = @Message + N'<table id="box-table" >' +
				N'<tr><font color="Green">
				<th>ServerName</th>
				<th>InstanceName</th>
				<th>ServiceName</th>
				<th>ServiceStatus</th>
				<th>OfflineDate</th>
				</tr>' 
				SELECT @Message = @Message + N'
					<tr>
						<td><font color = red>'+ServerName+'</td>
						<td><font color = red>'+InstanceName+'</td>
						<td><font color = red>'+ServiceName+'</td>
						<td><font color = red>'+ServiceStatus+'</td>
						<td><font color = red>'+CAST(OfflineDate AS VARCHAR)+'</td>
					</tr>'
					FROM CurrentOfflineServices
					WHERE Environment = @Environment
				SET @Message = @Message + '</table>' 

				exec CMS_SendPage @Message,'OfflineServiceReport',@subject,1, @HTML = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Alert_ServerStatus]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Alert_ServerStatus]
@Environment varchar(60) = 'PRODUCTION'
AS
BEGIN
	DECLARE @bodyMsg nvarchar(max)
	DECLARE @subject nvarchar(max)
	DECLARE @Message nvarchar(max)
	SET @subject = 'Server Status Report ' + @Environment

	IF EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE PingStatus <> 0 AND Environment = @Environment)
		BEGIN
			SET @Message = dbo.get_css()

			SET @Message = @Message + N'<table id="box-table" >' +
			N'<tr><th>ServerName</th>
				  <th>PingStatus</th>
			</tr>' 
			SELECT @Message = @Message + N'
					<tr>
						<td>'+ServerName+'</td>
						<td>'+CASE
								 WHEN PingStatus = 11003 THEN 'Destination Host Unreachable'
								 WHEN PingStatus = 11010 THEN 'Request Timed Out'
								 WHEN PingStatus = 11050 THEN 'General Failure'
							  END +'</td>
					</tr>'
			FROM MonitoredServers
			WHERE PingStatus <> 0 
			AND Environment = @Environment
		
			SET @Message = @Message + '</table>'
			exec CMS_SendPage @Message,'ServerAlert',@subject,1, @HTML = 1
		END
				
END

GO
/****** Object:  StoredProcedure [dbo].[CacheAcknowledgeRefresh]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CacheAcknowledgeRefresh]
@CacheName varchar(25)
AS
BEGIN
	IF EXISTS(SELECT CacheID FROM CacheController WHERE CacheName = @CacheName)
		UPDATE CacheController	
		SET Refresh = 0
		,LastRefreshDate = getdate()
		WHERE CacheName = @CacheName;
	ELSE
		INSERT INTO CacheController VALUES (@CacheName,0,GETDATE())
END

GO
/****** Object:  StoredProcedure [dbo].[CacheUpdateController]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CacheUpdateController]
@CacheName varchar(25)
,@Refresh bit
AS
BEGIN
	UPDATE CacheController
	SET REFRESH = @Refresh
	WHERE CacheName = @CacheName
END

GO
/****** Object:  StoredProcedure [dbo].[CMS_SendPage]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMS_SendPage]
@Body varchar(max)
,@Category varchar(28)
,@Title varchar(128)
,@PageCount int = 1
,@MaxTries tinyint = 2
,@HTML bit = 0
,@Type varchar(20) = 'Report'
AS
BEGIN
	DECLARE @rc int = 1
	DECLARE @RetryCnt tinyint = 0
	DECLARE @Receiver varchar(128)
	DECLARE @OperatorID int 
	DECLARE @PageDate Datetime
	DECLARE @PageStatus varchar(28)

	CREATE TABLE #tmp (id int, email_address nvarchar(100))

	IF @Type = 'Page'
		INSERT INTO #tmp
		SELECT so.id,
		so.email_address
		from msdb.dbo.sysoperators so
		JOIN CMS.dbo.Alerts_Operators ao
		on so.id = ao.OperatorID
		WHERE ao.OnDuty = 1
	ELSE IF @Type = 'Report'
		INSERT INTO #tmp
		SELECT s.operatorid, so.email_address
		FROM Reporting.Reports e
		JOIN Reporting.Subscriptions s
		ON e.reportid = s.reportid
		JOIN msdb..sysoperators so
		ON s.operatorid = so.id
		WHERE ReportName = @Category

	WHILE (SELECT COUNT(*) FROM #tmp) > 0
	BEGIN
	SELECT top 1
			@OperatorID = id,
			@Receiver = email_address
	FROM #tmp
	Set @rc = 1
		WHILE @rc <> 0 AND @RetryCnt < @MaxTries
		BEGIN	
			SET @PageDate = GETDATE()
				IF @HTML = 1
			 		EXECUTE @rc = msdb.dbo.sp_send_dbmail 
							@Profile_Name = 'MS SQL Mail',
							@Subject = @Title,
							@Recipients = @Receiver,
							@Body = @Body,
							@Body_Format = 'HTML'
				ELSE
					EXECUTE @rc = msdb.dbo.sp_send_dbmail 
							@Profile_Name = 'MS SQL Mail',
							@Subject = @Title,
							@Recipients = @Receiver,
							@Body = @Body
			SET @RetryCnt += 1
		END
		IF @rc = 0 
			SET @PageStatus = 'SENT'
		ELSE
			SET @PageStatus = 'FAIL'

		INSERT INTO Alert_PageRecords VALUES (@OperatorID,@Category,@PageDate,@PageStatus,@PageCount,@RetryCnt)
	DELETE FROM #tmp WHERE id = @OperatorID
	
	END
	DROP TABLE #tmp

END

GO
/****** Object:  StoredProcedure [dbo].[LogModule]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LogModule]
@ModuleName varchar(60),
@LogID bigint = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Date DATETIME = GETDATE()
	 
	 IF NOT EXISTS(SELECT LogID FROM CollectionLog WHERE LogID = @LogID)
		BEGIN
			INSERT INTO CollectionLog (ModuleName,StartTime) VALUES (@ModuleName,@Date)
			SELECT @LogID = SCOPE_IDENTITY()
			SELECT @LogID AS [LogID]
		END
	ELSE
		UPDATE CollectionLog
		SET EndTime = @Date
		WHERE LogID = @LogID

	RETURN 
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_GetCounts]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_GetCounts]
@Type varchar(10),
@InstanceID int
AS
BEGIN
	DECLARE @SQL varchar(4000)

	IF @Type = 'Groups'
		SET @SQL = N'SELECT COUNT(DISTINCT g.AvailabilityGroupID) as AGCount
					FROM MonitoredAvailabilityGroups g
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON g.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE g.Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Type = 'Replicas'
		SET @SQL = N'SELECT COUNT(DISTINCT(REPLICAid)) AS ReplicaCount
					FROM MonitoredAvailabilityGroupReplicas
					WHERE Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Type = 'Databases' 
		SET @SQL = N'SELECT COUNT (DISTINCT(DetailID)) AS DatabaseCount
					FROM MonitoredAvailabilityGroupDBDetails gdb
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gdb.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE gdb.Deleted = 0 
					AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)

	ELSE 
		SET @SQL = N'SELECT COUNT(DISTINCT(ListenerID)) AS ListenerCount
					FROM MonitoredAvailabilityGroupListeners gl
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gl.AvailabilityGroupID = gr.AvailabilityGroupID
					WHERE gl.Deleted = 0
					AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)

	exec (@SQL)
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_GetGroups]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_GetGroups]
@Mode varchar(25),
@InstanceID int
AS
BEGIN
	DECLARE @SQL varchar(4000)
	 IF @Mode = 'Listener'
		SET @SQL = N'SELECT distinct(gl.ListenerName),gl.ListenerGUID,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupListeners gl
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gl.AvailabilityGroupID = gr.AvailabilityGroupID
					JOIN MonitoredAvailabilityGroups g
					ON g.AvailabilityGroupID = gl.AvailabilityGroupID
					WHERE gr.InstanceID =' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Database'
		SET @SQL = N'SELECT distinct(gd.DatabaseName),gd.AGDatabaseGuid,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupDBDetails gd
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON gd.AvailabilityGroupID = gr.AvailabilityGroupID
					JOIN MonitoredAvailabilityGroups g
					ON gd.AvailabilityGroupID = g.AvailabilityGroupID
					WHERE gd.Deleted = 0 AND
					gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Replica'
		SET @SQL = N'SELECT gr.ReplicaName,gr.ReplicaGUID,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroupReplicas gr
					JOIN MonitoredAvailabilityGroups g
					ON gr.AvailabilityGroupID = g.AvailabilityGroupID
					WHERE gr.Deleted = 0 AND InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	ELSE IF @Mode = 'Group'
		SET @SQL = N'SELECT DISTINCT g.AvailabilityGroupID,g.AvailabilityGroupName,g.AvailabilityGroupGUID
					FROM MonitoredAvailabilityGroups g
					JOIN MonitoredAvailabilityGroupReplicas gr
					ON g.AvailabilityGroupID = gr.AvailabilityGroupID 
					WHERE g.Deleted = 0 AND gr.InstanceID = ' + CAST(@InstanceID AS VARCHAR)
	exec(@SQL)
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_SetDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetDatabases]
@AGGuid varchar(36) = NULL,
@DatabaseGuid varchar(36) = null,
@AGDBGuid varchar(36),
@IsFailoverReady bit = null,
@SyncState varchar(13) = null,
@ReplicaName varchar(128) = null,
@InstanceID int = null,
@Deleted bit = null
AS
BEGIN
	DECLARE @DatabaseID int, @AvailabilityGroupID int,@DatabaseName varchar(128),@ReplicaID int
	
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
	SELECT @ReplicaID = ReplicaID FROM MonitoredAvailabilityGroupReplicas where ReplicaName = @ReplicaName AND AvailabilityGroupID = @AvailabilityGroupID AND InstanceID = @InstanceID
	SELECT 
		@DatabaseID = DatabaseID,
		@DatabaseName = DatabaseName
		FROM MonitoredDatabases WHERE InstanceID = @InstanceID  AND DatabaseGUID = @DatabaseGuid

	IF NOT EXISTS (SELECT TOP 1 DetailID FROM MonitoredAvailabilityGroupDBDetails WHERE AvailabilityGroupID = @AvailabilityGroupID AND AGDatabaseGuid = @AGDBGuid)
		INSERT INTO MonitoredAvailabilityGroupDBDetails(DatabaseID,DatabaseName,IsFailOverReady,SynchronizationState,DateCreated,DateUpdated,Deleted,AGDatabaseGUID,AvailabilityGroupID,ReplicaID)
		VALUES (@DatabaseID,@DatabaseName,@IsFailoverReady,@SyncState,GETDATE(),GETDATE(),0,@AGDBGuid,@AvailabilityGroupID,@ReplicaID)
	ELSE IF @Deleted = 1
		BEGIN
			UPDATE MonitoredAvailabilityGroupDBDetails
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AGDatabaseGuid = @AGDBGuid
		END
	ELSE
		BEGIN
			UPDATE MonitoredAvailabilityGroupDBDetails
			SET
				DatabaseID = @DatabaseID,
				DatabaseName = @DatabaseName,
				IsFailoverReady = @IsFailoverReady,
				SynchronizationSTate = @SyncState,
				DateUpdated = GETDATE(),
				ReplicaID = @ReplicaID
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND AGDatabaseGuid = @AGDBGuid

			UPDATE md
			SET md.AvailabilityGroupID = g.AvailabilityGroupID
			FROM MonitoredDatabases md
			JOIN MonitoredAvailabilityGroupDBDetails gdb
			ON md.DatabaseName = gdb.DatabaseName
			JOIN MonitoredAvailabilityGroups g
			ON gdb.AvailabilityGroupID = g.AvailabilityGroupID
			WHERE g.AvailabilityGroupID = @AvailabilityGroupID
			AND gdb.DatabaseName = @DatabaseName
		END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_SetGroups]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetGroups]
@AGName varchar(128) = null,
@AGGuid varchar(36),
@Deleted bit = 0
AS
BEGIN
	DECLARE @InstanceID int, @AvailabilityGroupID int,@PreviousRole varchar(9),@DatabaseID int,@DatabaseName varchar(128)
	
	IF NOT EXISTS(SELECT TOP 1 AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid)
		INSERT INTO MonitoredAvailabilityGroups (AvailabilityGroupName,AvailabilityGroupGUID,DateCreated,DateUpdated,deleted) VALUES (@AGName,@AGGuid,GETDATE(),GETDATE(),0)
	ELSE IF @Deleted = 1
		BEGIN
			SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
			UPDATE MonitoredAvailabilityGroups
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE 
				AvailabilityGroupGUID = @AGGuid

			UPDATE MonitoredAvailabilityGroupReplicas
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0

			UPDATE MonitoredAvailabilityGroupDBDetails
			SET
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0

			UPDATE MonitoredAvailabilityGroupListeners
			SET
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0				
		END
	ELSE
		UPDATE MonitoredAvailabilityGroups
		SET 
			AvailabilityGroupName = @AGName,
			DateUpdated = getdate()
		WHERE AvailabilityGroupGUID = @AGGuid
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_SetListeners]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetListeners]
@AGGuid varchar(36),
@ListenerName varchar(128) = null,
@ListenerGUID varchar(36) = null,
@ListenerIPAddress varchar(15) = null,
@ListenerIPState varchar(16) = null,
@ListenerPort varchar(10) = null,
@Deleted bit = null
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @AvailabilityGroupID INT
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid

	IF NOT EXISTS(SELECT TOP 1 ListenerID FROM MonitoredAvailabilityGroupListeners WHERE [AvailabilityGroupID] = @AvailabilityGroupID)
		INSERT INTO MonitoredAvailabilityGroupListeners (ListenerName,ListenerGUID,ListenerIPAddress,ListenerIPState,ListenerPort,DateCreated,DateUpdated,Deleted,[AvailabilityGroupID])
		VALUES (@ListenerName,@ListenerGUID,@ListenerIPAddress,@ListenerIPState,@ListenerPort,GETDATE(),GETDATE(),0,@AvailabilityGroupID)
	ELSE IF @Deleted = 1
		UPDATE MonitoredAvailabilityGroupListeners
		SET
			Deleted = 1,
			DateDeleted = GETDATE()
		WHERE
			ListenerGUID = @ListenerGUID		
	ELSE
		UPDATE MonitoredAvailabilityGroupListeners
		SET
			ListenerName = @ListenerName,
			ListenerIPAddress = @ListenerIPAddress,
			ListenerIPState = @ListenerIPState,
			ListenerPort = @ListenerPort,
			DateUpdated = GETDATE()
		WHERE 
			ListenerGUID = @ListenerGUID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredAvailabilityGroups_SetReplicas]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetReplicas]
@AGGuid varchar(36),
@ParentName varchar(128),
@ReplicaName varchar(128) = null,
@ReplicaAvailabilityMode varchar(18) = null,
@FailoverMode varchar(10) = null,
@CurrentRole varchar(9) = null,
@SyncState varchar(13) = null,
@ReplicaGuid varchar(36),
@Deleted bit = 0
AS
BEGIN
	DECLARE @PreviousRole varchar(9),@InstanceID int,@AvailabilityGroupID int

	SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @ParentName
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
	IF NOT EXISTS(SELECT TOP 1 ReplicaID FROM MonitoredAvailabilityGroupReplicas WHERE InstanceID = @InstanceID AND AvailabilityGroupID = @AvailabilityGroupID AND ReplicaGuid = @ReplicaGuid)
		INSERT INTO MonitoredAvailabilityGroupReplicas (AvailabilityGroupID,ReplicaName,InstanceID,AvailabilityMode,FailoverMode,CurrentRole,SynchronizationState,DateCreated,DateUpdated,Deleted,FailoverFlag,ReplicaGuid)
		VALUES (@AvailabilityGroupID,@ReplicaName,@InstanceID,@ReplicaAvailabilityMode,@FailoverMode,@CurrentRole,@SyncState,GETDATE(),GETDATE(),0,0,@ReplicaGuid)
	ELSE IF(@Deleted = 1)
		UPDATE MonitoredAvailabilityGroupReplicas
		SET
			Deleted = 1,
			DateDeleted = GETDATE()
		WHERE
			ReplicaGUID = @ReplicaGuid
			AND AvailabilityGroupID = @AvailabilityGroupID
	ELSE
	BEGIN
		SELECT @PreviousRole = CurrentRole FROM MonitoredAvailabilityGroupReplicas WHERE InstanceID = @InstanceID AND AvailabilityGroupID = @AvailabilityGroupID AND ReplicaGuid = @ReplicaGuid
		UPDATE MonitoredAvailabilityGroupReplicas
		SET
			ReplicaName = @ReplicaName,
			AvailabilityMode = @ReplicaAvailabilityMode,
			FailoverMode = @FailoverMode,
			CurrentRole = @CurrentRole,
			SynchronizationState = @SyncState,
			DateUpdated = GETDATE(),
			FailoverFlag = 
				CASE
					WHEN @PreviousRole = @CurrentRole THEN 0
					ELSE 1
				END
		WHERE InstanceID = @InstanceID
		AND AvailabilityGroupID = @AvailabilityGroupID
		AND ReplicaGuid = @ReplicaGuid
	END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredBlocking_GetBlocking]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredBlocking_GetBlocking]
@InstanceID INT
AS
	SELECT CurrentBlockingSpid,LastBatchTime
	FROM CurrentBlocking
	WHERE InstanceID = @InstanceID

GO
/****** Object:  StoredProcedure [dbo].[MonitoredBlocking_SetBlocking]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredBlocking_SetBlocking]
@InstanceID int,
@SPID smallint,
@LastBatchTime datetime,
@Action varchar(10),
@Status varchar(30) = null,
@LoginName varchar(128) = null,
@HostName varchar(128) = null,
@ProgramName varchar(128) = null,
@OpenTran smallint = null,
@DatabaseName varchar(128) = null,
@Command varchar(16) = null,
@LastWaitType varchar(32) = null,
@WaitTime bigint = null,
@SQL varchar(max) = null,
@BlockingID BIGINT = null
AS
BEGIN
	IF @Action = 'OPEN'
	  --Check to see if the current process is already recorded
		IF NOT EXISTS(SELECT TOP 1 InstanceID FROM MonitoredBlocking WHERE InstanceID = @InstanceID and SPID = @SPID and EndCollectionTime IS NULL)
			BEGIN
				
				INSERT INTO MonitoredBlocking (InstanceID,Spid,Status,LoginName,HostName,ProgramName,OpenTran,DatabaseName,Command,LastWaitType,WaitTime,LastBatchTime,StartCollectionTime,SQLStatement)
				VALUES (@InstanceID,@SPID,@Status,@LoginName,@HostName,@ProgramName,@OpenTran,@DatabaseName,@Command,@LastWaitType,@WaitTime,@LastBatchTime,GETDATE(),@SQL)

				SELECT @BlockingID = SCOPE_IDENTITY()

				INSERT INTO CurrentBlocking (InstanceID,CurrentBlockingSpid,LastBatchTime,BlockingID) values (@InstanceID,@SPID,@LastBatchTime,@BlockingID)

			END
		ELSE
			UPDATE MonitoredBlocking
			SET Status = @Status
			,LastWaitType = @LastWaitType
			,WaitTime = @WaitTime
			,LastBatchTime = @LastBatchTime
			WHERE InstanceID = @InstanceID
			AND Spid = @SPID
			AND EndCollectionTime IS NULL

			UPDATE CurrentBlocking
			SET LastBatchTime = @LastBatchTime
			WHERE InstanceID = @InstanceID
			AND CurrentBlockingSpid = @SPID

			DELETE cb
			FROM CurrentBlocking cb
			JOIN monitoredinstances mi
			ON cb.instanceid = mi.instanceid 
			WHERE mi.MonitorBlocking = 0

	IF @Action = 'CLOSE'
		BEGIN
			UPDATE MonitoredBlocking
			SET EndCollectionTime = GETDATE()
			WHERE Spid = @SPID
			AND InstanceID = @InstanceID
			AND EndCollectionTime IS NULL

			DELETE FROM CurrentBlocking
			WHERE InstanceID = @InstanceID 
			AND CurrentBlockingSpid = @SPID
			AND LastBatchTime = @LastBatchTime
		END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredClusters_SetCluster]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredClusters_SetCluster]
@ClusterName varchar(128),
@Deleted bit = 0,
@ClusterID int = null
AS
BEGIN
	IF NOT EXISTS(SELECT TOP 1 ClusterID FROM MonitoredClusters WHERE ClusterName = @ClusterName)
		BEGIN
			INSERT INTO MonitoredClusters VALUES (@ClusterName,getdate(),getdate(),0,null)
			SELECT @ClusterID = SCOPE_IDENTITY()
		END
	ELSE IF @Deleted = 1
		UPDATE MonitoredClusters
		SET
			Deleted = 1,
			DateDeleted = GETDATE(),
			DateUpdated = GETDATE()
		WHERE
			ClusterName = @ClusterName
	ELSE
		BEGIN
			SELECT @ClusterID = ClusterID
			FROM MonitoredClusters
			WHERE ClusterName = @ClusterName
		END

	RETURN @ClusterID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredClusters_SetDetails]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredClusters_SetDetails]
@ClusterID int
,@InstanceID int = null
,@NodeName varchar(128)
,@IsCurrentOwner bit = null
,@Deleted bit = 0
AS
BEGIN
	DECLARE @ServerID int,@PreviousRole bit
	IF NOT EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE ServerName = @NodeName)
		exec MonitoredServers_SetServer @ServerName = @NodeName
	SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @NodeName

	IF NOT EXISTS (Select TOP 1 DetailID FROM MonitoredClusterDetails WHERE ClusterID = @ClusterID AND ServerID = @ServerID AND InstanceID = @InstanceID)
		INSERT INTO MonitoredClusterDetails VALUES (@ClusterID,@InstanceID,@ServerID,@IsCurrentOwner,getdate(),getdate(),@Deleted,null,0)
	ELSE IF @Deleted = 1
		UPDATE MonitoredClusterDetails
		SET 
			Deleted = 1,
			DateUpdated = GETDATE(),
			DateDeleted = GETDATE()
		WHERE 
			ClusterID = @ClusterID
			AND ServerID = @ServerID
	ELSE
	BEGIN
		SELECT @PreviousRole = IsCurrentOwner FROM MonitoredClusterDetails WHERE ClusterID = @ClusterID and ServerID = @ServerID

		UPDATE MonitoredClusterDetails
		SET
			IsCurrentOwner = @IsCurrentOwner,
			DateUpdated = GETDATE(),
			FailoverFlag = 
				CASE
					WHEN @PreviousRole = @IsCurrentOwner THEN 0
					ELSE 1
				END
		WHERE
			ClusterID = @ClusterID
			AND ServerID = @ServerID
	END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabaseFiles_GetDatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_GetDatabaseFiles]
	@InstanceID int,
	@DatabaseID int,
	@FileType varchar(10)
AS
BEGIN
	SELECT InstanceID,DatabaseID,DatabaseFileID,LogicalName,PhysicalName,Directory
	FROM MonitoredDatabaseFiles
	WHERE InstanceID = @InstanceID
	AND DatabaseID = @DatabaseID
	AND FileType = @FileType
	AND Deleted = 0
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabaseFiles_SetDatabaseFiles]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_SetDatabaseFiles]
@InstanceID int
,@DatabaseID int = NULL
,@LogicalName varchar(60) = null
,@PhysicalName varchar(60) = null
,@Directory varchar(250) = null
,@FileType varchar(10) = null 
,@FileSize float = null
,@UsedSpace float = null
,@AvailableSpace float = null
,@PercentageFree decimal(4,3) = null
,@MaxSize float = null
,@Growth float = null
,@GrowthType varchar(60) = null
,@Deleted bit = 0
,@DatabaseFileID int = null
,@DatabaseGUID varchar(36)
AS
BEGIN

	DECLARE @dbfid table (id int)
	SELECT @DatabaseID = DatabaseID FROM dbo.MonitoredDatabases WHERE InstanceID = @InstanceID AND DatabaseGUID = @DatabaseGUID
	IF NOT EXISTS(SELECT DatabaseFileID FROM MonitoredDatabaseFiles WHERE InstanceID = @InstanceID and DatabaseID = @DatabaseID and PhysicalName = @PhysicalName)
		BEGIN
			INSERT INTO MonitoredDatabaseFiles
				(InstanceID,DatabaseID,LogicalName,PhysicalName,Directory,FileType,FileSize,UsedSpace,AvailableSpace,PercentageFree,MaxSize,Growth,GrowthType,Deleted)
			Values
				(@InstanceID,@DatabaseID,@LogicalName,@PhysicalName,LTRIM(RTRIM(@Directory)),@FileType,@FileSize,@UsedSpace,@AvailableSpace,@PercentageFree,@MaxSize,@Growth,@GrowthType,0)
			SELECT @DatabaseFileID = SCOPE_IDENTITY()
			EXEC [dbo].[MonitoredDatabaseFiles_SetDriveID] @DatabaseFileID
		END
	ELSE IF (@Deleted = 1)
	BEGIN
		UPDATE MonitoredDatabaseFiles
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		DateUpdated = GETDATE()
		WHERE InstanceID = @InstanceID
		AND DatabaseID = @DatabaseID
		AND DatabaseFileID = @DatabaseFileID
	END
	ELSE
		UPDATE MonitoredDatabaseFiles
		SET [LogicalName] = @LogicalName
			  ,[PhysicalName] = @PhysicalName
			  ,[Directory] = LTRIM(RTRIM(@Directory))
			  ,[FileType] = @FileType
			  ,[FileSize] = @FileSize
			  ,[UsedSpace] = @UsedSpace
			  ,[MaxSize] = @MaxSize
			  ,[AvailableSpace] = @AvailableSpace
			  ,[PercentageFree] = @PercentageFree
			  ,[Growth] = @Growth
			  ,[GrowthType] = @Growthtype
			  ,[DateUpdated] = GETDATE()
			  ,[Deleted] = 0
			  ,[DateDeleted] = null
		OUTPUT inserted.DatabaseFileID INTO @dbfid
		WHERE
			InstanceID = @InstanceID
			and DatabaseID = @DatabaseID
			and PhysicalName = @PhysicalName
		SELECT top 1 @DatabaseFileID = id FROM @dbfid
		EXEC [dbo].[MonitoredDatabaseFiles_SetDriveID] @DatabaseFileID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabaseFiles_SetDriveID]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_SetDriveID]
@DatabaseFileID int
AS
BEGIN
	SET NOCOUNT ON


	DECLARE @ServerID int,@DriveID int, @MP varchar(60), @len int, @sub varchar(60)


	SELECT @ServerID = serverID
	FROM MonitoredDatabaseFiles mdf
	JOIN MonitoredDatabases md
	ON mdf.DatabaseID = md.DatabaseID
	WHERE DatabaseFileID = @DatabaseFileID

	SELECT ServerID,DriveID,MountPoint
	INTO #TMP
	FROM MonitoredDrives
	WHERE ServerID = @ServerID

	WHILE (SELECT COUNT(*) FROM #TMP) > 0
	BEGIN
		SELECT TOP 1
			 @MP = MountPoint,
			 @DriveID = DriveID
		FROM #TMP
		SELECT @len = LEN(@MP)


		SELECT @sub = SUBSTRING(Directory,1,@len) FROM MonitoredDatabaseFiles where DatabaseFileID = @DatabaseFileID
		IF @sub = @MP
		BEGIN
			UPDATE MonitoredDatabaseFiles
			SET DriveID = @DriveID
			WHERE DatabaseFileID = @DatabaseFileID
			TRUNCATE TABLE #TMP
		END
		ELSE
			DELETE FROM #TMP WHERE MountPoint = @MP
	END

	drop table #TMP
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabases_GetDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabases_GetDatabases]
@ModuleName varchar(28)
,@InstanceID INT = NULL
as
BEGIN
DECLARE @SQL VARCHAR(MAX)

IF @ModuleName = 'ProcessDatabaseFiles'
	SET @SQL = 'SELECT DISTINCT s.serverID, s.servername,i.instanceID,i.instanceName, db.DatabaseID,db.DatabaseName,COALESCE(DataFiles.DataFileCount,0) as DataFileCount,COALESCE(LogFiles.LogFileCount,0) AS LogFileCount
		FROM MonitoredDatabases db
		JOIN MonitoredInstances i
		ON db.InstanceID = i.instanceId
		JOIN MonitoredServers s
		ON db.ServerID = s.serverid
		LEFT OUTER JOIN MonitoredDatabaseFiles mdf
		ON db.DatabaseID = mdf.DatabaseID
		LEFT OUTER JOIN (SELECT DatabaseID,COUNT(*) as DataFileCount
				FROM MonitoredDatabaseFiles
				WHERE FileType = ''data'' AND Deleted = 0
				group by DatabaseID) AS DataFiles
		ON mdf.DatabaseID = DataFiles.DatabaseID
		LEFT OUTER JOIN (SELECT DatabaseID,COUNT(*) as LogFileCount
				FROM MonitoredDatabaseFiles
				WHERE FileType = ''log'' AND Deleted = 0
				group by DatabaseID) AS LogFiles
		ON mdf.DatabaseID = LogFiles.DatabaseID
		WHERE db.monitordatabasefiles = 1
		AND db.Deleted = 0'
IF @ModuleName = 'ProcessDatabases'
	SET @SQL = 'SELECT DatabaseName, DatabaseGUID
				FROM MonitoredDatabases
				WHERE InstanceID = ' + CAST(@InstanceID AS VARCHAR) + '
				AND Deleted = 0'
IF @ModuleName = 'GatherBackups'
	SET @SQL = 'SELECT distinct mi.InstanceID,mi.InstanceName
				FROM MonitoredDatabases md
				JOIN MonitoredInstances mi
				ON md.InstanceID = mi.InstanceID
				WHERE md.Deleted = 0'

EXEC (@SQL)


END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabases_SetBackups]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabases_SetBackups]
@InstanceID INT,
@DatabaseGuid varchar(36),
@LastFullBackupDate DATETIME,
@LastDifferentialBackupDate DATETIME,
@LastLogBackupDate DATETIME,
@RecoveryModel varchar(25)
AS
BEGIN
	DECLARE @RecordDate DATETIME = GETDATE(),@CurrentRecoveryModel varchar(25),@DatabaseID int

	SELECT @DatabaseID = DatabaseID FROM dbo.MonitoredDatabases WHERE InstanceID = @InstanceID AND DatabaseGUID = @DatabaseGuid
	
	IF NOT EXISTS(SELECT TOP 1 BackupID FROM MonitoredDatabaseBackups WHERE DatabaseID = @DatabaseID and DATEDIFF(mi,BackupRecordDate,@RecordDate) <=1440)
		BEGIN
			INSERT INTO MonitoredDatabaseBackups (BackupRecordDate,DatabaseID,LastFullBackupDate,LastDifferentialBackupDate,LastLogBackupDate)
			VALUES (@RecordDate,@DatabaseID,@LastFullBackupDate,@LastDifferentialBackupDate,@LastLogBackupDate)
			
			SELECT @CurrentRecoveryModel = RecoveryModel 
			FROM MonitoredDatabases 
			WHERE DatabaseID = @DatabaseID
			
			IF(@CurrentRecoveryModel <> @RecoveryModel)
				UPDATE MonitoredDatabases
				SET RecoveryModel = @RecoveryModel
				WHERE DatabaseID = @DatabaseID
		END
	ELSE
		UPDATE MonitoredDatabaseBackups
		SET
			LastFullBackupDate = @LastFullBackupDate,
			LastDifferentialBackupDate = @LastDifferentialBackupDate,
			LastLogBackupDate = @LastLogBackupDate
		WHERE DatabaseID = @DatabaseID
		AND DATEDIFF(mi,BackupRecordDate,@RecordDate) < 1440

		SELECT @CurrentRecoveryModel = RecoveryModel 
		FROM MonitoredDatabases 
		WHERE DatabaseID = @DatabaseID
			
		IF(@CurrentRecoveryModel <> @RecoveryModel)
			UPDATE MonitoredDatabases
			SET RecoveryModel = @RecoveryModel
			WHERE DatabaseID = @DatabaseID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDatabases_SetDatabases]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDatabases_SetDatabases]
@ServerID int
,@InstanceID int
,@Databasename varchar(128)
,@CreationDate datetime = null
,@CompatibilityLevel int = null
,@Collation varchar(60) = null
,@size int = null
,@DataSpaceUsage int = null
,@IndexSpaceUsage int = null
,@SpaceAvailable int = null
,@RecoveryModel varchar(25) = null
,@AutoClose bit = null
,@AutoShrink bit = null
,@ReadOnly bit = null
,@PageVerify varchar(25) = null
,@Owner varchar(60) = null
,@Status varchar(60) = null
,@Deleted BIT = null
,@GUID varchar(36)
AS
BEGIN
	DECLARE @TBFlag BIT = 1
	
	IF NOT EXISTS (SELECT DatabaseID FROM MonitoredDatabases WHERE ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID)
	BEGIN
		INSERT INTO [dbo].[MonitoredDatabases]
           ([ServerID],[InstanceID],[DatabaseName],[CreationDate],[CompatibilityLevel],[Collation],[Size],[DataSpaceUsage],[IndexSpaceUsage],[SpaceAvailable],[RecoveryModel],[AutoClose],[AutoShrink],[ReadOnly],[PageVerify],[Owner],[DateCreated],[Dateupdated],[Status],[DatabaseGUID],[Deleted])
		VALUES
           (@ServerID,@InstanceID,@Databasename,@CreationDate,@CompatibilityLevel,@Collation,@size,@DataSpaceUsage,@IndexSpaceUsage,@SpaceAvailable,@RecoveryModel,@AutoClose,@AutoShrink,@ReadOnly,@PageVerify,@Owner,getdate(),getdate(),@Status,@GUID,0)

		   exec CacheUpdateController @CacheName = 'Database', @Refresh = 1;
	END
    ELSE IF @Deleted = 1
	BEGIN
		UPDATE MonitoredDatabases
		SET Dateupdated = getdate()
		,Deleted = @Deleted
		,DateDeleted = getdate()
		WHERE ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID
	
		exec CacheUpdateController @CacheName = 'Database',@Refresh = 1;
	END
	ELSE
		UPDATE MonitoredDatabases
		   SET 
		   [DatabaseName] = @Databasename
		  ,[CreationDate] = @CreationDate
		  ,[CompatibilityLevel] = @CompatibilityLevel
		  ,[Collation] = @Collation
		  ,[Size] = @size
		  ,[DataSpaceUsage] = @DataSpaceUsage
		  ,[IndexSpaceUsage] = @IndexSpaceUsage
		  ,[SpaceAvailable] = @SpaceAvailable
		  ,[RecoveryModel] = @RecoveryModel
		  ,[AutoClose] = @AutoClose
		  ,[AutoShrink] = @AutoShrink
		  ,[ReadOnly] = @ReadOnly
		  ,[PageVerify] = @PageVerify
		  ,[Owner] = @Owner
		  ,[Dateupdated] = getdate()
		  ,[Status] = @Status
		  ,[Deleted] = @Deleted
		WHERE 	
			ServerID = @ServerID and InstanceID = @InstanceID and DatabaseGUID = @GUID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDrives_GetDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDrives_GetDrives]
  @ServerID int
  AS
  BEGIN
		SELECT DeviceID 
		FROM [dbo].[MonitoredDrives]
		WHERE ServerID = @ServerID
		AND Deleted = 0
  END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredDrives_SetDrives]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredDrives_SetDrives]
@ServerID int
,@DeviceID varchar(60)
,@MountPoint varchar(60) = null
,@TotalCapacity bigint = null
,@FreeSpace bigint = null
,@VolumeName varchar(128) = null
,@Deleted bit = 0
AS
BEGIN
	IF NOT EXISTS(select DriveID from MonitoredDrives where ServerID = @ServerID and DeviceID = @DeviceID)
		INSERT INTO MonitoredDrives(ServerID,DeviceID,MountPoint,TotalCapacity,FreeSpace,VolumeName,DateCreated,DateUpdated,Deleted) VALUES (@ServerID,@DeviceID,@MountPoint,@TotalCapacity,@FreeSpace,@VolumeName,getdate(),getdate(),0)
	IF @Deleted = 1
		BEGIN
			UPDATE MonitoredDrives
			SET Deleted = @Deleted,
			DateDeleted = getdate()
			WHERE ServerID = @ServerID
			AND DeviceID = @DeviceID
		END
	ELSE
		UPDATE MonitoredDrives
		SET
			TotalCapacity = @TotalCapacity
			,FreeSpace = @FreeSpace
			,VolumeName = @VolumeName
			,MountPoint = @MountPoint
			,DateUpdated = GETDATE()
			,Deleted = @Deleted
			,DateDeleted = null
		WHERE
			ServerID = @ServerID
			AND DeviceID = @DeviceID
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredInstanceJobs_GetJobs]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredInstanceJobs_GetJobs]
@InstanceID int
AS
BEGIN
	SELECT JobName, JobGUID
	FROM MonitoredInstanceJobs
	WHERE InstanceID = @InstanceID
	AND Deleted = 0
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredInstanceJobs_SetJobs]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredInstanceJobs_SetJobs]
@InstanceID int,
@ServerID int = NULL,
@JobName varchar(128) = NULL,
@JobGUID varchar(36),
@JobCategory varchar(128) = NULL,
@JobOwner varchar(60) = NULL,
@LastRunDate datetime = NULL,
@NextRunDate datetime = NULL,
@JobOutcome varchar(60) = NULL,
@JobEnabled bit = NULL,
@JobScheduled bit = NULL,
@JobDuration int = NULL,
@JobCreationDate datetime = NULL,
@JobModifiedDate datetime = NULL,
@JobEmailLevel varchar(60) = NULL,
@JobPageLevel varchar(60) = NULL,
@JobNetSendLevel varchar(60) = NULL,
@OperatorToEmail varchar(60) = NULL,
@OperatorToPage varchar(60) = NULL,
@OperatorToNetSend varchar(60) = NULL,
@Deleted bit = 0
AS
BEGIN
	DECLARE @RunDate DATETIME = GETDATE(),@JobID INT

	IF NOT EXISTS(SELECT JobID FROM MonitoredInstanceJobs WHERE InstanceID = @InstanceID AND JobGUID = @JobGUID)
		BEGIN
			INSERT INTO [dbo].[MonitoredInstanceJobs]
			([InstanceID],[ServerID],[JobName],[JobGUID],[JobCategory],[JobOwner],[LastRunDate],[NextRunDate],[JobOutcome],[JobEnabled],[JobScheduled],[JobDuration],[JobCreationDate],[JobModifiedDate],[JobEmailLevel],[JobPageLevel],[JobNetSendLevel],[OperatorToEmail],[OperatorToPage],[OperatorToNetSend],[DateCreated],[DateUpdated],[Deleted])
			VALUES
			(@InstanceID,@ServerID,@JobName,@JobGUID,@JobCategory,@JobOwner,@LastRunDate,@NextRunDate,@JobOutcome,@JobEnabled,@JobScheduled,@JobDuration,@JobCreationDate,@JobModifiedDate,@JobEmailLevel,@JobPageLevel,@JobNetSendLevel,@OperatorToEmail,@OperatorToPage,@OperatorToNetSend,@RunDate,@RunDate,@Deleted)

			SELECT @JobID = SCOPE_IDENTITY()

			exec CacheUpdateController @CacheName = 'AgentJob',@Refresh = 1;

			IF NOT EXISTS(SELECT sa.Name FROM MonitoredInstanceJobs mj JOIN ServiceAccounts sa ON mj.JobOwner = sa.name WHERE JobID = @JobID AND sa.AgentJobs = 1)
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 1
				WHERE JobId = @JobID
			ELSE
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 0
				WHERE JobId = @JobID
		END
	ELSE IF @Deleted = 1
		BEGIN
			UPDATE MonitoredInstanceJobs
			SET Deleted = 1,
			DateDeleted = GETDATE(),
			JobEnabled = 0
			WHERE InstanceID = @InstanceID
			AND JobGUID = @JobGUID

			exec CacheUpdateController @CacheName = 'AgentJob',@Refresh = 1;
		END
	ELSE
		BEGIN
			SELECT @JobID = JobID FROM MonitoredInstanceJobs WHERE InstanceID = @InstanceID AND JobGUID = @JobGUID

			UPDATE [dbo].[MonitoredInstanceJobs]
			   SET [ServerID]		= @ServerID
				  ,[JobName]		= @JobName
				  ,[JobGUID]		= @JobGUID
				  ,[JobCategory]	= @JobCategory
				  ,[JobOwner]		= @JobOwner
				  ,[LastRunDate]	= @LastRunDate
				  ,[NextRunDate]	= @NextRunDate
				  ,[JobOutcome]		= @JobOutcome
				  ,[JobEnabled]		= @JobEnabled
				  ,[JobScheduled]	= @JobScheduled
				  ,[JobDuration]	= @JobDuration
				  ,[JobCreationDate] = @JobCreationDate
				  ,[JobModifiedDate] = @JobModifiedDate
				  ,[JobEmailLevel]	= @JobEmailLevel
				  ,[JobPageLevel]	= @JobPageLevel
				  ,[JobNetSendLevel] = @JobNetSendLevel
				  ,[OperatorToEmail] = @OperatorToEmail
				  ,[OperatorToPage] = @OperatorToPage
				  ,[OperatorToNetSend] = @OperatorToNetSend
				  ,[DateUpdated]	= @RunDate
				  ,[Deleted]		= @Deleted
			 WHERE 
				InstanceID = @InstanceID AND
				JobGUID = @JobGUID

			IF NOT EXISTS(SELECT sa.Name FROM MonitoredInstanceJobs mj JOIN ServiceAccounts sa ON mj.JobOwner = sa.name WHERE JobID = @JobID)
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 1
				WHERE JobId = @JobID
			ELSE
				UPDATE MonitoredInstanceJobs
				SET OwnerFlag = 0
				WHERE JobId = @JobID
		END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredInstances_GetInstances]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredInstances_GetInstances]
@Module varchar(128) = null,
@ServerID int = NULL
AS
DECLARE @SQL varchar(max)

       SET @SQL = N'SELECT mi.ServerID,ms.ServerName,mi.INSTANCEID,mi.INSTANCENAME 
					FROM MonitoredInstances mi 
					JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
					WHERE mi.MonitorInstance = 1 AND mi.Deleted = 0'
IF @Module = 'ProcessDatabases'
       SET @SQL = N'SELECT mi.ServerID,mi.INSTANCEID,mi.INSTANCENAME,COALESCE(DBCount.DatabaseCount,0) AS DatabaseCount
					FROM MonitoredInstances mi
					LEFT OUTER JOIN 
					(select InstanceID, Count(DatabaseID) as DatabaseCount
					from MonitoredDatabases
					WHERE Deleted = 0
					group by InstanceID) AS DBCount
					ON mi.InstanceID = DBCount.InstanceID
					WHERE MonitorDatabases = 1 AND mi.Deleted = 0'
ELSE IF @Module = 'GatherBlocking'
       SET @SQL = N'SELECT InstanceName,InstanceID FROM MonitoredInstances WHERE MonitorBlocking = 1 AND Deleted = 0'
ELSE IF @Module = 'ProcessAvailabilityGroups'
	   SET @SQL = N'SELECT mi.ServerID, mi.InstanceID,mi.InstanceName
					FROM MonitoredInstances mi
					WHERE mi.MonitorInstance = 1 AND DELETED = 0 AND CAST(LEFT(Version,2) AS INT) >= 11 AND mi.Edition LIKE ''Enterprise%''' 
ELSE IF @Module = 'ProcessDrives'
	   SET @SQL = N'SELECT mi.InstanceID,mi.InstanceName,mi.ServerID,CO.ServerName
					FROM MonitoredInstances mi
					JOIN 
					(
						SELECT mcd.InstanceID,mcd.ServerID,ms.ServerName
						FROM MonitoredClusterDetails mcd
						JOIN MonitoredServers ms
						ON mcd.ServerID = ms.ServerID
						WHERE mcd.IsCurrentOwner = 1
					) as CO
					ON mi.InstanceID = CO.InstanceID
					JOIN MonitoredServers ms
					ON mi.ServerID = ms.ServerID
					WHERE ms.ServerID = ' + CAST(@ServerID as varchar)
ELSE IF @Module = 'CheckServers'
		SET @SQL = N'SELECT ms.ServerID,ms.Servername,mi.InstanceID,mi.InstanceName,mi.SSAS,mi.SSRS
					FROM MonitoredInstances mi
					INNER JOIN MonitoredServers ms ON mi.ServerID = ms.ServerID
					WHERE mi.MonitorInstance = 1 AND mi.Deleted = 0'
ELSE IF	@Module = 'GatherInstanceWaitStats'
		SET @SQL = N'SELECT InstanceID,InstanceName
					FROM MonitoredInstances
					WHERE Deleted = 0 AND MonitorWaitStats = 1'
exec (@sql)

GO
/****** Object:  StoredProcedure [dbo].[MonitoredInstances_SetInstance]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredInstances_SetInstance]
@ServerID int = null
,@InstanceID int
,@InstanceName varchar(128) = null
,@Edition varchar(128) = null
,@Version varchar(120) = null
,@isClustered bit = null
,@MaxMemory bigint = null
,@MinMemory bigint = null
,@ServiceAccount varchar(60) = null
,@ProductLevel varchar(10) = null
,@SSAS bit = NULL
,@SSRS bit = NULL 
,@PingTest bit = 0
,@PingStatus bit = 1
,@SSASStatus varchar(20) = NULL
,@SSRSStatus varchar(20) = NULL
,@AgentStatus varchar(20) = NULL
AS
BEGIN
	IF EXISTS (SELECT INSTANCEID FROM MonitoredInstances WHERE INSTANCENAME = @InstanceName and ServerID = @ServerID and InstanceID = @InstanceID)
	BEGIN
		IF @PingTest = 1
			UPDATE MonitoredInstances
			SET 
				PingStatus = @PingStatus,
				SSASStatus = @SSASStatus,
				SSRSStatus = @SSRSStatus,
				AgentStatus = @AgentStatus
			WHERE InstanceID = @InstanceID
		ELSE
		BEGIN
			UPDATE MonitoredInstances
			SET
				Edition = @Edition
				,[Version] = @Version
				,isClustered = @isClustered
				,MaxMemory = @MaxMemory
				,MinMemory = @MinMemory
				,ServiceAccount = @ServiceAccount
				,ProductLevel = @ProductLevel
				,DateUpdated = getdate()
				,SSAS = @SSAS
				,SSRS = @SSRS
				,Deleted = 0
				,DateDeleted = NULL
			WHERE
				InstanceName = @InstanceName
				AND ServerID = @ServerID
	
			IF @isClustered = 1
				UPDATE MonitoredServers
				SET
					IsVirtualServerName = 1
				WHERE
					ServerID = @ServerID
		END
	END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredInstanceServerWaits_SetWaits]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredInstanceServerWaits_SetWaits]
@InstanceID int
,@WaitType nvarchar(60)
,@Waiting_Task_Count bigint
,@Wait_Time_MS bigint
,@Max_Wait_Time_MS bigint
,@Signal_Wait_Time_MS bigint
,@CollectionDate datetime
AS
BEGIN
	DECLARE @WaitID int
	SELECT @WaitID = WaitID
	FROM ServerWaits 
	WHERE WaitType = @WaitType 
	AND Capture = 1

	IF @WaitID IS NOT NULL AND @Waiting_Task_Count > 0 AND @Wait_Time_MS > 0 AND @Max_Wait_Time_MS > 0 AND @Signal_Wait_Time_MS > 0
	BEGIN
		INSERT INTO MonitoredInstanceServerWaits VALUES (@InstanceID,@WaitID,@Waiting_Task_Count,@Wait_Time_MS,@Max_Wait_Time_MS,@Signal_Wait_Time_MS,@CollectionDate)
	END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredPerfCounters_SetCounters]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredPerfCounters_SetCounters]
@CollectionDate datetime
,@ServerID int = null
,@InstanceID int = null
,@CounterName varchar(250)
,@Value DECIMAL (30,15)
,@Type varchar(10)
AS
BEGIN
	DECLARE @CounterID smallint
	
	SELECT @CounterID = CounterID
	FROM dbo.PerfCounters
	WHERE CounterName = @CounterName

	IF @CounterID IS NOT NULL
		BEGIN
			IF @Type = 'server'
				IF (SELECT COALESCE(DATEDIFF(second,MAX(collectionDate),getdate()),301)
  FROM [dbo].[MonitoredServerPerfCounters]
  where ServerID = @ServerID and CounterID = @CounterID) > 300
					INSERT INTO MonitoredServerPerfCounters VALUES (@CollectionDate,@ServerID,@CounterID,@Value)
			IF @Type = 'instance'
				INSERT INTO MonitoredInstancePerfCounters VALUES (@CollectionDate,@InstanceID,@CounterID,@Value)
		END
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredServers_GetServers]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredServers_GetServers]
@ModuleName varchar(128)
as
BEGIN
DECLARE @SQL varchar(max)

IF @ModuleName = 'ProcessServers'
	SET @SQL = N'SELECT ServerID,ServerName,IsVirtualServerName FROM MonitoredServers WHERE MonitorServer = 1 AND Deleted = 0'
ELSE IF @ModuleName = 'ProcessDrives' 
	SET @SQL = N'SELECT ms.ServerID,ms.ServerName,ms.IsVirtualServerName,COALESCE(MCD.IsPartofCluster,0) AS IsPartOfCluster
					FROM MonitoredServers ms
					LEFT OUTER JOIN (
					select distinct ServerID, 1 as IsPartofCluster
					from MonitoredClusterDetails
					) AS mcd
					on ms.ServerID = mcd.ServerID
					WHERE ms.MonitorDrives = 1 AND ms.Deleted = 0'

exec (@SQL)
END

GO
/****** Object:  StoredProcedure [dbo].[MonitoredServers_SetServer]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MonitoredServers_SetServer]
@ServerName varchar(128) = null
,@ServerID int = null
,@TotalMemory bigint = null
,@Manufacturer varchar(128) = null
,@Model varchar(128) = null
,@IPAddress varchar(15) = null
,@OperatingSystem varchar(128) = null
,@BitLevel char(2) = null
,@DateInstalled datetime = null
,@DateLastBoot datetime = null
,@NumberofProcessors tinyint = null
,@NumberofProcessorCores tinyint = null
,@ProcessorClockSpeed smallint = null
,@PingStatus bit = 1
,@PingTest bit = 0
,@VSN bit = 0
,@InstanceID int = null
,@Environment varchar(128) = 'PRODUCTION'
AS
BEGIN
	--Check for existence of server
	

	IF NOT EXISTS(SELECT ServerID FROM MonitoredServers WHERE ServerName = @ServerName)
	BEGIN
		INSERT INTO [dbo].[MonitoredServers]
			([ServerName],[MonitorServer],[TotalMemory],[Manufacturer],[Model],[IPAddress],[OperatingSystem],[BitLevel],[DateInstalled],[NumberofProcessors],[NumberofProcessorCores],[ProcessorClockSpeed],[DateCreated],[DateUpdated],[DateLastBoot],[MonitorDrives],[PingStatus],[Deleted],[IsVirtualServerName],[Environment])
		VALUES
			(@ServerName,1,@TotalMemory,@Manufacturer,@Model,@IPAddress,@OperatingSystem,@BitLevel,@DateInstalled,@NumberofProcessors,@NumberofProcessorCores,@ProcessorClockSpeed,getdate(),getdate(),@DateLastBoot,1,@PingStatus,0,@VSN,@Environment)
		
		EXEC CacheUpdateController @CacheName = 'Server', @Refresh =1
	END
	ELSE IF @PingTest = 1
		UPDATE [dbo].[MonitoredServers]
		SET PingStatus = @PingStatus
		WHERE ServerName = @ServerName
	ELSE IF @VSN = 1
	BEGIN
		SELECT @ServerID = ServerID
		FROM MonitoredClusterDetails
		WHERE InstanceID = @InstanceID
		AND IsCurrentOwner = 1

		UPDATE ms2
		SET
			 ms2.[Environment] = ms.[Environment]
			,ms2.[MonitorServer] = ms.[MonitorServer]
			,ms2.[TotalMemory] = ms.[TotalMemory]
			,ms2.[Manufacturer] = ms.[Manufacturer]
			,ms2.[Model] = ms.[Model]
			,ms2.[OperatingSystem] = ms.[OperatingSystem]
			,ms2.[BitLevel] = ms.[BitLevel]
			,ms2.[DateInstalled] = ms.[DateInstalled]
			,ms2.[NumberofProcessors] = ms.[NumberofProcessors]
			,ms2.[NumberofProcessorCores] = ms.[NumberofProcessorCores]
			,ms2.[ProcessorClockSpeed] = ms.[ProcessorClockSpeed]
			,ms2.[DateUpdated] = GETDATE()
			,ms2.[DateLastBoot] = ms.[DateLastBoot]
			,ms2.[MonitorDrives] = ms.[MonitorDrives]
			,ms2.[PingStatus] = ms.[PingStatus]
			,ms2.[Deleted] = ms.[Deleted]
			,ms2.[DateDeleted] = ms.[DateDeleted]
			,ms2.[IPAddress] = @IPAddress
		FROM [dbo].[MonitoredServers] ms,
		[dbo].[MonitoredServers] ms2
		WHERE ms2.ServerName = @ServerName
		AND ms.ServerID = @ServerID
	END
	ELSE 
	UPDATE [dbo].[MonitoredServers]
		   SET [TotalMemory] = @TotalMemory
			  ,[Manufacturer] = @Manufacturer
			  ,[Model] = @Model
			  ,[IPAddress] = @IPAddress
			  ,[OperatingSystem] = @OperatingSystem
			  ,[BitLevel] = @BitLevel
			  ,[DateInstalled] = @DateInstalled
			  ,[NumberofProcessors] = @NumberofProcessors
			  ,[NumberofProcessorCores] = @NumberofProcessorCores
			  ,[ProcessorClockSpeed] = @ProcessorClockSpeed
			  ,[DateUpdated] = GETDATE()
			  ,[DateLastBoot] = @DateLastBoot
			  ,[PingStatus] = @PingStatus
			  ,[Deleted] = 0
			  ,[DateDeleted] = null
		 WHERE ServerName = @ServerName

END

GO
/****** Object:  StoredProcedure [dbo].[Purge_CMS]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Purge_CMS]
AS
	DECLARE @Purge_Value int, @LogID bigint
	DECLARE @Table varchar(30),@hPurge_Value varchar(5)
	DECLARE @SQL varchar(max)


		SET @Table = 'CollectionLog'
		SELECT @Purge_Value = IntValue
		FROM Config
		WHERE Setting = 'CollectionLog - Cleanup Days'
	
		SET @Purge_Value = '-' + cast(@Purge_Value as varchar)

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - ' + @Table,GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM CollectionLog
		WHERE StartTime < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
	


		SELECT @Purge_Value = CAST(IntValue AS VARCHAR(5))
		FROM Config
		WHERE Setting = 'History Schema - Cleanup Days'

	
		SET @Purge_Value = '-' + cast(@Purge_Value as varchar)

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDatabaseFiles',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDatabaseFiles
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDatabases',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDatabases
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
	
		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDrives',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDrives
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredInstanceJobs',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredInstanceJobs
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredInstances',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredInstances
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
		
		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredServers',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredServers
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[ReportServerWaits]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReportServerWaits]
@InstanceName varchar(128) = null
,@StartTime datetime = NULL
,@EndTime datetime = NULL
,@Top int = NULL
,@OrderBy varchar(25) = NULL
,@Help bit = 0
AS
BEGIN
	IF @InstanceName IS NULL AND @Help = 0
	BEGIN
		PRINT 'Please enter InstanceName or use @help = 1 parameter'
		RETURN
	END
	IF @InstanceName IS NOT NULL
	BEGIN
		DECLARE @InstanceID int = (SELECT InstanceID FROM MonitoredInstances where InstanceName = @InstanceName)
		DECLARE @Msg nvarchar(500)
		IF @Top IS NULL
			SET @Top = 10
		IF @OrderBy IS NULL
			SET @OrderBy = 'WaitTimeMS'
		IF @InstanceID IS NOT NULL
			IF @OrderBy IS NULL
				SET @OrderBy = 'WaitTimeMS'
			IF @StartTime IS NOT NULL AND @EndTime IS NOT NULL
				BEGIN
					SELECT @StartTime = MIN(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate >= @StartTime
					group by InstanceID;
	
					SELECT @EndTime = MAX(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate <= @EndTime
					group by InstanceID;
	
				select top (@Top) InstanceName
					,WaitType
					,t2.Waiting_Task_Count - t1.Waiting_Task_Count as WaitingTaskCount
					,t2.Wait_Time_MS - t1.Wait_Time_MS as WaitTimeMS
					,t2.Signal_Wait_Time_MS - t1.Signal_Wait_Time_MS as SignalWaitTimeMS
						,(t2.Wait_Time_MS - t1.Wait_Time_MS) -(t2.Signal_Wait_Time_MS - t1.Signal_Wait_Time_MS) as ResourceWaitTimeMS
						,CAST((100.0 * (t2.[wait_time_ms]-t1.[Wait_Time_MS]) / SUM ((t2.[wait_time_ms]-t1.[Wait_Time_MS])) OVER()) as Decimal(5,2)) AS [Percentage]
				FROM [dbo].[MonitoredInstanceServerWaits] t1
				INNER JOIN [dbo].[MonitoredInstanceServerWaits] t2 ON t1.InstanceID = t2.InstanceID AND t1.WaitID = t2.WaitID
				INNER JOIN MonitoredInstances mi ON t1.InstanceID = mi.InstanceID
				INNER JOIN ServerWaits sw on t1.WaitID = sw.WaitID
				WHERE t1.InstanceID = @InstanceID
				AND t1.CollectionDate = @StartTime
				AND t2.CollectionDate = @EndTime
				ORDER BY WaitTimeMS desc
				END
			ELSE IF @StartTime IS NULL OR @EndTime IS NULL
			BEGIN
				SELECT @EndTime = MAX(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate <= getdate()
					group by InstanceID;

				select top (@Top) InstanceName
					,WaitType
					,t1.Waiting_Task_Count as WaitingTaskCount
					,t1.Wait_Time_MS as WaitTimeMS
					,t1.Signal_Wait_Time_MS as SignalWaitTimeMS
						,(t1.Wait_Time_MS) -(t1.Signal_Wait_Time_MS) as ResourceWaitTimeMS
						,CAST((100.0 * (t1.[Wait_Time_MS]) / SUM ((t1.[Wait_Time_MS])) OVER()) as Decimal(5,2)) AS [Percentage]
				FROM [dbo].[MonitoredInstanceServerWaits] t1
				INNER JOIN MonitoredInstances mi ON t1.InstanceID = mi.InstanceID
				INNER JOIN ServerWaits sw on t1.WaitID = sw.WaitID
				WHERE t1.InstanceID = @InstanceID
				AND t1.CollectionDate = @EndTime
				ORDER BY WaitTimeMS DESC;
			END
		ELSE 
			SET @Msg = 'Instance not found: ' + @InstanceName
			RAISERROR (@Msg, 0, 1) WITH NOWAIT
	
	END
	IF @Help = 1
		PRINT N'dbo.ReportServerWaits' + CHAR(13) + 'Author: J.Shurak' + char(13) + 'Description: Returns Server wait information for specified Instance' + char(13) + 'Parameters:' + CHAR(13) + CHAR(9) + '@InstanceName (varchar(128)) - InstanceName to report' + CHAR(13) + CHAR(9) + '@StartTime (datetime) - Used to specify a start date for report' + CHAR(13) + CHAR(9) + '@EndTime (datetime) - Used to specify a end date for report' + CHAR(13) + CHAR(9) + '@Top (int) - Used to specify the number of rows to return. Default is 10' + CHAR(13) + CHAR(9) + '@OrderBy (varchar(25)) - Used to specify the order by. Default is WaitTimeMS'
END

GO
/****** Object:  StoredProcedure [dbo].[RetireCMSInstance]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RetireCMSInstance]
	@InstanceID int = null,
	@InstanceName varchar(128) = null
AS
	DECLARE @id int

	IF (@InstanceID IS NULL AND @InstanceName IS NULL)
	BEGIN
		RAISERROR('Please Specify InstanceID or InstanceName for retirement',0,1)
		RETURN 1
	END
	ELSE IF(@InstanceID IS NOT NULL AND @InstanceName IS NOT NULL)
	BEGIN
		SELECT @id = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName
		IF(@id <> @InstanceID)
			BEGIN
				RAISERROR('InstanceID does not match value found in database.  Please specify InstanceID or InstanceName. (do not need both)',0,1)
				RETURN 1			
			END	
	END
	ELSE IF(@InstanceID IS NULL AND @InstanceID IS NOT NULL)
		SELECT @id = InstanceID FROM MonitoredInstances WHERE InstanceName = @InstanceName
	ELSE
		SET @id = @InstanceID
	BEGIN TRANSACTION
		--Mark the instance as deleted
		UPDATE MonitoredInstances
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 2, @Refresh = 1

		--Mark all databases as deleted
		UPDATE MonitoredDatabases
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 3, @Refresh = 1

		--Mark all databaseFiles as deleted
		UPDATE MonitoredDatabaseFiles
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		--Mark all Jobs as deleted
		UPDATE MonitoredInstanceJobs
		SET Deleted = 1,
		DateDeleted = GETDATE(),
		Dateupdated = GETDATE()
		WHERE InstanceID = @id
		AND Deleted = 0

		exec CacheUpdateController @CacheID = 4, @Refresh = 1

	COMMIT TRANSACTION
RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[RetireCMSServer]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RetireCMSServer]
	@ObjectName varchar(128),
	@ObjectType varchar(10) 
AS
	DECLARE @ServerID int, @InstanceID int,@msg varchar(1000)
	IF (@ObjectType <> 'Server' AND @ObjectType <> 'Instance')
	BEGIN
		SET @msg = 'Please Specify Server or Instance for @ObjectType for retirement' 
		RAISERROR(@msg,0,1)
		RETURN 1
	END
	IF(@ObjectType = 'Instance')
	BEGIN
		IF EXISTS(SELECT TOP 1 InstanceID FROM MonitoredInstances WHERE InstanceName = @ObjectName)
		BEGIN
			SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @ObjectName
			EXEC RetireCMSInstance @InstanceID = @InstanceID
			RETURN 0
		END
		ELSE
		BEGIN
			SET @msg = 'Instance ' + @ObjectName + ' not found'
			RAISERROR(@msg,0,1)
			RETURN 1			
		END
	END
	IF(@ObjectType = 'Server')
	BEGIN
		IF EXISTS(SELECT TOP 1 ServerID FROM MonitoredServers WHERE ServerName = @ObjectName)
		BEGIN
			SELECT @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ObjectName

			SELECT InstanceID
			INTO #Instances
			FROM MonitoredInstances
			WHERE ServerID = @ServerID
			BEGIN TRANSACTION
				--Retire Drives
				UPDATE MonitoredDrives
				SET Deleted = 1,
				DateDeleted = GETDATE(),
				DateUpdated = GETDATE()
				WHERE ServerID = @ServerID
				AND Deleted = 0

				WHILE(SELECT COUNT(*) FROM #Instances) > 0
				BEGIN
					SELECT TOP 1 @InstanceID = InstanceID FROM #Instances
					EXEC RetireCMSInstance @InstanceID = @InstanceID

					DELETE FROM #Instances WHERE InstanceID = @InstanceID
				END

				UPDATE MonitoredServers
				SET Deleted = 1,
				DateDeleted = getdate(),
				DateUpdated = getdate()
				WHERE ServerID = @ServerID

				exec CacheUpdateController @CacheID = 1, @Refresh = 1
			COMMIT TRANSACTION
		END
		ELSE 
		BEGIN
			SET @msg = 'Server ' + @ObjectName + ' not found'
			RAISERROR(@msg,0,1)
			RETURN 1
		END
	END
RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[TrackBaseline]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TrackBaseline]
AS
BEGIN
	DECLARE @BaseLength int
	SELECT @BaseLength = intValue
	FROM [dbo].[config]
	where Setting = 'Baseline - length Days'

	IF OBJECT_ID('tempdb..#ServerDates') IS NOT NULL
		DROP TABLE #ServerDates

	IF OBJECT_ID('tempdb..#InstancePerfDates') IS NOT NULL
		DROP TABLE #InstancePerfDates

	IF OBJECT_ID('tempdb..#InstanceWaitDates') IS NOT NULL
		DROP TABLE #InstanceWaitDates


	select ms.ServerID, COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #ServerDates
	from dbo.MonitoredServers ms 
	LEFT OUTER JOIN baseline.MonitoredServerPerfCounters c ON  c.ServerID = ms.ServerID
	WHERE ms.ServerID is NOT null
	and ms.Deleted = 0
	group by ms.serverid


	select mi.InstanceID, COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #InstancePerfDates
	from dbo.MonitoredInstances mi
	LEFT OUTER JOIN baseline.MonitoredInstancePerfCounters c ON  mi.InstanceID = c.InstanceID
	WHERE mi.InstanceID is NOT null
	and mi.Deleted = 0
	group by mi.InstanceID

	select mi.InstanceID,COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #InstanceWaitDates
	FROM MonitoredInstances mi
	LEFT OUTER JOIN Baseline.MonitoredInstanceServerWaits w ON mi.InstanceID = w.InstanceID
	WHERE mi.InstanceID IS NOT NULL
	AND mi.Deleted = 0
	group by mi.InstanceID

---Check to see if BaseLength has changes since setting the HasBaseline value.  If it has, set HasBaseline back to 0 to record new length

	MERGE dbo.MonitoredServers t
	USING (
	SELECT mspf.ServerID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredServerPerfCounters mspf
	INNER JOIN dbo.MonitoredServers ms ON mspf.ServerID = ms.ServerID
	WHERE ms.HasBaseline = 1 
	GROUP BY mspf.ServerID,ms.BaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.BaselineStartDate)
	) s ON (t.ServerID = s.ServerID)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 0;

	MERGE dbo.MonitoredInstances t
	USING (
	SELECT mspf.InstanceID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredInstancePerfCounters mspf
	INNER JOIN dbo.MonitoredInstances ms ON mspf.InstanceID = ms.InstanceID
	WHERE ms.HasBaseline = 1 
	GROUP BY mspf.InstanceID,ms.BaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.BaselineStartDate)
	) s ON (t.InstanceID = s.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 0;

	MERGE dbo.MonitoredInstances t
	USING (
	SELECT misw.InstanceID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredInstanceServerWaits misw
	INNER JOIN dbo.MonitoredInstances ms ON misw.InstanceID = ms.InstanceID
	WHERE ms.HasWaitsBaseline = 1 
	GROUP BY misw.InstanceID,ms.WaitsBaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.WaitsBaselineStartDate)
	) s ON (t.InstanceID = s.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET t.HasWaitsBaseline = 0;


	--set baselinestartdate
	MERGE [dbo].[MonitoredServers] AS target
	USING (
		SELECT mspc.ServerID,MIN(mspc.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredServerPerfCounters] mspc 
		INNER JOIN [dbo].[MonitoredServers] ms ON mspc.ServerID = ms.ServerID
		WHERE ms.Deleted = 0 AND ms.BaselineStartDate IS NULL
		GROUP by mspc.ServerID) AS source(ServerID,CollectionDate)
	ON (target.ServerID = source.ServerID)
	WHEN MATCHED THEN
		UPDATE SET BaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredServerPerfCounters] as t
	USING(
	SELECT mspc.CollectionDate,mspc.ServerID,mspc.CounterID,mspc.Value
	FROM [dbo].[MonitoredServerPerfCounters] mspc
	INNER JOIN #ServerDates ON mspc.ServerID = #ServerDates.ServerID
	INNER JOIN [dbo].[MonitoredServers] ms on mspc.ServerID = ms.ServerID
	WHERE mspc.CollectionDate >= #ServerDates.MaxDate and mspc.CollectionDate <= CAST(DATEADD(day,@BaseLength + 1,BaseLineStartDate) AS date)
	AND ms.HasBaseline = 0
	AND ms.Deleted = 0
	) AS s (CollectionDate,ServerID,CounterID,Value)
	ON (t.CollectionDate = s.CollectionDate AND t.ServerID = s.ServerID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,ServerID,CounterID,Value) VALUES (s.CollectionDate,s.ServerID,s.CounterID,s.Value);

	--update hasbaseline if baseline is complete
	MERGE [dbo].[MonitoredServers] t
	USING(
	SELECT b.ServerID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredServerPerfCounters] b
	INNER JOIN [dbo].[MonitoredServers] ms ON B.ServerID = ms.ServerID
	WHERE ms.HasBaseline = 0
	AND ms.BaseLineStartDate IS NOT NULL
	GROUP BY b.ServerID
	) as s (ServerID,StartDate,EndDate)
	ON (s.ServerID = t.ServerID AND s.StartDate = t.BaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 1;


--Baseline Instance Perf Counters
--set baselinestartdate
	MERGE [dbo].MonitoredInstances AS target
	USING (
		SELECT mipc.InstanceID,MIN(mipc.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredInstancePerfCounters] mipc 
		INNER JOIN [dbo].MonitoredInstances mi ON mipc.InstanceID = mi.InstanceID
		WHERE mi.Deleted = 0 AND mi.BaselineStartDate IS NULL
		GROUP by mipc.InstanceID) AS source(InstanceID,CollectionDate)
	ON (target.InstanceID = source.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET BaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredInstancePerfCounters] as t
	USING(
	SELECT mipc.CollectionDate,mipc.InstanceID,mipc.CounterID,mipc.Value
	FROM [dbo].[MonitoredInstancePerfCounters] mipc
	INNER JOIN #InstancePerfDates ipd ON mipc.InstanceID = ipd.InstanceID
	INNER JOIN [dbo].[MonitoredInstances] ms on mipc.InstanceID = ms.InstanceID
	WHERE mipc.CollectionDate >= ipd.MaxDate and mipc.CollectionDate <= CAST(DATEADD(day,@BaseLength + 1,BaseLineStartDate) AS date)
	AND ms.HasBaseline = 0
	AND ms.Deleted = 0
	) AS s (CollectionDate,InstanceID,CounterID,Value)
	ON (t.CollectionDate = s.CollectionDate AND t.InstanceID = s.InstanceID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,InstanceID,CounterID,Value) VALUES (s.CollectionDate,s.InstanceID,s.CounterID,s.Value);


	--update hasbaseline if baseline is complete
	MERGE [dbo].MonitoredInstances t
	USING(
	SELECT b.InstanceID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredInstancePerfCounters] b
	INNER JOIN [dbo].MonitoredInstances mi ON B.InstanceID = mi.InstanceID
	WHERE mi.HasBaseline = 0
	AND mi.BaseLineStartDate IS NOT NULL
	GROUP BY b.InstanceID
	) as s (InstanceID,StartDate,EndDate)
	ON (s.InstanceID = t.InstanceID AND s.StartDate = t.BaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 1;

-- Start InstanceServer Waits

	--set baselinestartdate
	MERGE [dbo].MonitoredInstances AS target
	USING (
		SELECT misw.InstanceID,MIN(misw.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredInstanceServerWaits] misw 
		INNER JOIN [dbo].MonitoredInstances mi ON misw.InstanceID = mi.InstanceID
		WHERE mi.Deleted = 0 AND mi.WaitsBaselineStartDate IS NULL
		GROUP by misw.InstanceID) AS source(InstanceID,CollectionDate)
	ON (target.InstanceID = source.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET WaitsBaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredInstanceServerWaits] as t
	USING(
	SELECT misw.CollectionDate,misw.InstanceID,misw.WaitID,misw.Waiting_Task_Count,misw.Wait_Time_MS,misw.Max_Wait_Time_MS,misw.Signal_Wait_Time_MS
	FROM [dbo].[MonitoredInstanceServerWaits] misw
	INNER JOIN #InstanceWaitDates iwd ON misw.InstanceID = iwd.InstanceID
	INNER JOIN [dbo].MonitoredInstances mi on misw.InstanceID = mi.InstanceID
	WHERE misw.CollectionDate >= iwd.MaxDate
	AND misw.CollectionDate <= CAST(DATEADD(day,@Baselength + 1,WaitsBaseLineStartDate) AS date)
	AND mi.HasWaitsBaseline = 0
	AND mi.Deleted = 0
	) AS s (CollectionDate,InstanceID,WaitID,Waiting_Task_Count,Wait_Time_MS,Max_Wait_Time_MS,Signal_Wait_Time_MS)
	ON (t.CollectionDate = s.CollectionDate AND t.InstanceID = s.InstanceID AND t.WaitID = s.WaitID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,InstanceID,WaitID,Waiting_Task_Count,Wait_Time_MS,Max_Wait_Time_MS,Signal_Wait_Time_MS) VALUES (s.CollectionDate,s.InstanceID,s.WaitID,s.Waiting_Task_Count,s.Wait_Time_MS,s.Max_Wait_Time_MS,s.Signal_Wait_Time_MS);

	--update hasbaseline if baseline is complete
	MERGE [dbo].MonitoredInstances t
	USING(
	SELECT b.InstanceID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredInstanceServerWaits] b
	INNER JOIN [dbo].MonitoredInstances mi ON B.InstanceID = mi.InstanceID
	WHERE mi.HasWaitsBaseline = 0
	AND mi.WaitsBaseLineStartDate IS NOT NULL
	GROUP BY b.InstanceID
	) as s (InstanceID,StartDate,EndDate)
	ON (s.InstanceID = t.InstanceID AND s.StartDate = t.WaitsBaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasWaitsBaseline = 1;

END

GO
/****** Object:  StoredProcedure [dbo].[TrackHistory]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TrackHistory]
@TrackJobs bit = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @HistoryDate Datetime = GETDATE()

IF @TrackJobs = 0
	BEGIN
		--Record ServerHistory
		INSERT INTO [History].[MonitoredServers]
			   ([HistoryDate]
			   ,[ServerID]
			   ,[ServerName]
			   ,[Environment]
			   ,[MonitorServer]
			   ,[TotalMemory]
			   ,[Manufacturer]
			   ,[Model]
			   ,[IPAddress]
			   ,[OperatingSystem]
			   ,[BitLevel]
			   ,[DateInstalled]
			   ,[NumberofProcessors]
			   ,[NumberofProcessorCores]
			   ,[ProcessorClockSpeed]
			   ,[DateCreated]
			   ,[DateLastBoot]
			   ,[MonitorDrives])
		 SELECT @HistoryDate
		  ,[ServerID]
		  ,[ServerName]
		  ,[Environment]
		  ,[MonitorServer]
		  ,[TotalMemory]
		  ,[Manufacturer]
		  ,[Model]
		  ,[IPAddress]
		  ,[OperatingSystem]
		  ,[BitLevel]
		  ,[DateInstalled]
		  ,[NumberofProcessors]
		  ,[NumberofProcessorCores]
		  ,[ProcessorClockSpeed]
		  ,[DateCreated]
		  ,[DateLastBoot]
		  ,[MonitorDrives]
	  FROM [dbo].[MonitoredServers]
	  WHERE Deleted = 0
	  AND MonitorServer = 1
 
	 --Instances
	INSERT INTO [History].[MonitoredInstances]
			   ([HistoryDate]
			   ,[InstanceID]
			   ,[ServerID]
			   ,[InstanceName]
			   ,[Environment]
			   ,[MonitorInstance]
			   ,[Edition]
			   ,[Version]
			   ,[isClustered]
			   ,[MaxMemory]
			   ,[MinMemory]
			   ,[DateCreated]
			   ,[ServiceAccount]
			   ,[MonitorDatabases]
			   ,[MonitorBlocking]
			   ,[Criticality]
			   ,[ProductLevel])
		SELECT @HistoryDate
				,[InstanceID]
				,[ServerID]
				,[InstanceName]
				,[Environment]
				,[MonitorInstance]
				,[Edition]
				,[Version]
				,[isClustered]
				,[MaxMemory]
				,[MinMemory]
				,[DateCreated]
				,[ServiceAccount]
				,[MonitorDatabases]
				,[MonitorBlocking]
				,[Criticality]
				,[ProductLevel]
			FROM [dbo].[MonitoredInstances]
			WHERE Deleted = 0
			AND MonitorInstance = 1

	--databases
	INSERT INTO [History].[MonitoredDatabases]
			   ([HistoryDate]
			   ,[DatabaseID]
			   ,[ServerID]
			   ,[InstanceID]
			   ,[DatabaseName]
			   ,[CreationDate]
			   ,[CompatibilityLevel]
			   ,[Collation]
			   ,[Size]
			   ,[DataSpaceUsage]
			   ,[IndexSpaceUsage]
			   ,[SpaceAvailable]
			   ,[RecoveryModel]
			   ,[AutoClose]
			   ,[AutoShrink]
			   ,[ReadOnly]
			   ,[PageVerify]
			   ,[Owner]
			   ,[DateCreated]
			   ,[MonitorDatabaseFiles]
			   ,[Status]
			   ,[Deleted]
			   ,[DatabaseGUID])
		SELECT @HistoryDate 
			  ,[DatabaseID]
			  ,[ServerID]
			  ,[InstanceID]
			  ,[DatabaseName]
			  ,[CreationDate]
			  ,[CompatibilityLevel]
			  ,[Collation]
			  ,[Size]
			  ,[DataSpaceUsage]
			  ,[IndexSpaceUsage]
			  ,[SpaceAvailable]
			  ,[RecoveryModel]
			  ,[AutoClose]
			  ,[AutoShrink]
			  ,[ReadOnly]
			  ,[PageVerify]
			  ,[Owner]
			  ,[DateCreated]
			  ,[MonitorDatabaseFiles]
			  ,[Status]
			  ,[Deleted]
			  ,[DatabaseGUID]
		  FROM [dbo].[MonitoredDatabases]
		  WHERE Deleted = 0
		  

		  --Drives
		  INSERT INTO [History].[MonitoredDrives]
			   ([HistoryDate]
			   ,[DriveID]
			   ,[ServerID]
			   ,[TotalCapacity]
			   ,[FreeSpace]
			   ,[PercentFreeThreshold]
			   ,[DateCreated]
			   ,[VolumeName]
			   ,[MountPoint]
			   ,[DeviceID])
		SELECT @HistoryDate 
			  ,[DriveID]
			  ,[ServerID]
			  ,[TotalCapacity]
			  ,[FreeSpace]
			  ,[PercentFreeThreshold]
			  ,[DateCreated]
			  ,[VolumeName]
			  ,[MountPoint]
			  ,[DeviceID]
		  FROM [dbo].[MonitoredDrives]
		  WHERE Deleted = 0

		-- Database Files
		INSERT INTO [History].[MonitoredDatabaseFiles]
			   ([HistoryDate]
			   ,[DatabaseFileID]
			   ,[InstanceID]
			   ,[DatabaseID]
			   ,[LogicalName]
			   ,[PhysicalName]
			   ,[FileSize]
			   ,[UsedSpace]
			   ,[MaxSize]
			   ,[AvailableSpace]
			   ,[PercentageFree]
			   ,[Growth]
			   ,[GrowthType]
			   ,[DateCreated]
			   ,[MonitorDatabaseFileSpace]
			   ,[DatabaseFileSpaceThreshold]
			   ,[FileType]
			   ,[Directory]
			   ,[DriveID])
			SELECT @HistoryDate
				  ,[DatabaseFileID]
				  ,[InstanceID]
				  ,[DatabaseID]
				  ,[LogicalName]
				  ,[PhysicalName]
				  ,[FileSize]
				  ,[UsedSpace]
				  ,[MaxSize]
				  ,[AvailableSpace]
				  ,[PercentageFree]
				  ,[Growth]
				  ,[GrowthType]
				  ,[DateCreated]
				  ,[MonitorDatabaseFileSpace]
				  ,[DatabaseFileSpaceThreshold]
				  ,[FileType]
				  ,[Directory]
				  ,[DriveID]
			  FROM [dbo].[MonitoredDatabaseFiles]
			  WHERE Deleted = 0
	END
IF @TrackJobs = 1
	BEGIN
		INSERT INTO History.MonitoredInstanceJobs
		SELECT @HistoryDate,
			   mj.[JobID]
			  ,mj.[LastRunDate]
			  ,mj.[JobOutcome]
			  ,mj.[JobDuration]
		  FROM [dbo].[MonitoredInstanceJobs] mj
		  LEFT OUTER JOIN [History].[MonitoredInstanceJobs] hj
		  ON mj.JobID = hj.JobID 
		  AND mj.LastRunDate = hj.LastRunDate
		  WHERE hj.HistoryId is null
		  AND mj.Deleted = 0
		  AND mj.MonitorJob = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[UntrackCMSServer]    Script Date: 2/4/2015 9:53:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UntrackCMSServer]
@ServerName varchar(128) = null
,@ServerID int = null
AS
BEGIN
	IF(@ServerName IS NULL AND @ServerID IS NULL)
		BEGIN
			PRINT 'Please enter a server name or server id.'
			RETURN
		END
	ELSE
		BEGIN
			IF(@ServerID IS NULL)
				SELECT TOP 1 @ServerID = ServerID FROM MonitoredServers WHERE ServerName = @ServerName
			IF(@ServerID IS NULL)
				BEGIN
					Print 'The server ' + @ServerName + ' not found.'
				END
			ELSE
				BEGIN
					UPDATE MonitoredServers 
					SET MonitorServer = 0
					WHERE ServerID = @ServerID

					exec CacheUpdateController @CacheID = 1,@Refresh = 1;
				END
		END
END

GO
USE [master]
GO
ALTER DATABASE [CMS_C] SET  READ_WRITE 
GO
