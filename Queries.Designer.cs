﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.18444
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace CMS_C {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Queries {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Queries() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("CMS_C.Queries", typeof(Queries).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to SELECT
        ///  DISTINCT
        ///        rs.database_guid as [DatabaseGuid],
        ///		a.recovery_model_desc as [RecoveryModel],
        ///        COALESCE( (SELECT   MAX(backup_finish_date)
        ///                   FROM     msdb.dbo.backupset
        ///                   WHERE    database_name = a.name
        ///                            AND type = &apos;d&apos;
        ///                            AND is_copy_only = &apos;0&apos;
        ///                 ),&apos;01/01/1900 00:00:00&apos;) AS [LastBackupDate] ,
        ///        COALESCE( ( SELECT   MAX(backup_finish_date)
        ///                   FROM     msdb.d [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GatherBackups {
            get {
                return ResourceManager.GetString("GatherBackups", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to SELECT
        ///    spid
        ///    ,LTRIM(RTRIM(sp.STATUS)) AS Status
        ///    ,LTRIM(RTRIM(loginame)) as LoginName
        ///    ,LTRIM(RTRIM(hostname)) as HostName
        ///	,LTRIM(RTRIM(program_name)) as ProgramName
        ///    ,open_tran as OpenTran
        ///    ,LTRIM(RTRIM(DB_NAME(sp.dbid))) as DatabaseName
        ///    ,LTRIM(RTRIM(cmd)) as Command
        ///    ,LTRIM(RTRIM(lastwaittype)) as LastWaitType
        ///    ,waittime
        ///    ,last_batch as LastBatchTime
        ///    ,SQLStatement       =
        ///        SUBSTRING
        ///        (
        ///            qt.text,
        ///            er.statement_start_of [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GatherBlocking {
            get {
                return ResourceManager.GetString("GatherBlocking", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to if OBJECT_ID(&apos;tempdb..#sizes&apos;) IS NOT NULL
        ///	DROP TABLE #sizes
        ///if OBJECT_ID(&apos;tempdb..#dbs&apos;) IS NOT NULL
        ///	DROP TABLE #dbs
        ///
        ///CREATE TABLE #dbs(
        ///	DatabaseName varchar(128)
        ///	,database_id int
        ///	,DatabaseGUID varchar(36)
        ///	,physical_name nvarchar(260)
        ///	,[file_id] int
        ///	,Size bigint
        ///	,Type tinyint
        ///	,AvailableSpace bigint
        ///	,Max_size int
        ///	,Growth int
        ///	,is_percent_growth bit
        ///)
        ///
        ///create table #sizes(
        ///	database_id int
        ///	,LogicalName varchar(128)
        ///	,groupID int
        ///	,SpaceUsed bigint
        ///)
        ///
        ///exec sp_MSforeachdb [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GatherDatabaseFiles {
            get {
                return ResourceManager.GetString("GatherDatabaseFiles", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to if OBJECT_ID(&apos;tempdb..#sizes&apos;) IS NOT NULL
        ///	DROP TABLE #sizes
        ///if OBJECT_ID(&apos;tempdb..#available&apos;) IS NOT NULL
        ///	DROP TABLE #available
        ///
        ///create table #sizes(
        ///	database_id int
        ///	,IndexUsage bigint
        ///	,DataSpaceUsage bigint
        ///)
        ///create table #available (
        ///	database_id int,
        ///	type int,
        ///	SpaceAvailable bigint
        ///)
        ///exec sp_MSforeachdb N&apos;USE [?] INSERT INTO #sizes
        ///	select  db_id() as database_id,(sum(used_pages)-sum(
        ///				CASE
        ///					-- XML-Index and FT-Index and semantic index internal tables are not considered  [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GatherDatabases {
            get {
                return ResourceManager.GetString("GatherDatabases", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to select @@SERVERNAME AS InstanceName,SERVERPROPERTY(&apos;Edition&apos;) AS Edition,SERVERPROPERTY(&apos;ProductVersion&apos;) AS Version,CAST(SERVERPROPERTY(&apos;isClustered&apos;) as BIT) AS isClustered ,SERVERPROPERTY(&apos;ProductLevel&apos;) AS ProductLevel
        ///                                                        ,[Min] as minMemory,CAST([Max] AS BIGINT) as maxMemory
        ///                                                        FROM
        ///                                                        (SELECT left(name,3) as name, value_in_use
        ///               [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GatherInstance {
            get {
                return ResourceManager.GetString("GatherInstance", resourceCulture);
            }
        }
    }
}
