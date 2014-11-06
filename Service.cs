using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceProcess;
using System.Diagnostics;
using System.Timers;
using System.Data;

namespace CMS_C
{
    class Service : ServiceBase
    {

        public Service()
        {
            this.ServiceName = "CMS Collector";
            this.EventLog.Log = "Application";
            this.CanHandlePowerEvent = true;
            this.CanHandleSessionChangeEvent = true;
            this.CanPauseAndContinue = true;
            this.CanShutdown = true;
            this.CanStop = true;
        }

        DateTime _lastDailyExecutionDateTime;
        Timer _dailyTimer = new Timer(1000 * 60 * 60 * 24);
        
        /// <summary>
        /// Dispose of objects that need it here.
        /// </summary>
        /// <param name="disposing">Whether
        ///    or not disposing is going on.</param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }

        /// <summary>
        /// OnStart(): Put startup code here
        ///  - Start threads, get inital data, etc.
        /// </summary>
        /// <param name="args"></param>
        protected override void OnStart(string[] args)
        {
            base.OnStart(args);



            CMSCache cache = new CMSCache();
            cache.BuildCache();

            
            Timer _fiveMinuteTimer = new Timer(300000);
            Timer _thirtyMinuteTimer = new Timer(1000 * 60 * 30);
            

            _lastDailyExecutionDateTime = GatherLastDailyExecution();
            TimeSpan _daysSince = DateTime.Now - _lastDailyExecutionDateTime;
            if(_daysSince.Hours > 24)
            {
                Jobs.Daily(cache.ServerCache, cache.InstanceCache, cache.DatabaseCache, cache.AgentJobCache);
            }

            SetUpTimer(new TimeSpan(10, 15, 00), cache.ServerCache, cache.InstanceCache, cache.DatabaseCache, cache.AgentJobCache);

            _fiveMinuteTimer.Enabled = true;
            _fiveMinuteTimer.Start();
            _fiveMinuteTimer.Elapsed += new ElapsedEventHandler((sender, e) => FiveMinuteEvent(sender, e, cache.ServerCache,cache.InstanceCache,cache));

            _thirtyMinuteTimer.Enabled = true;
            _thirtyMinuteTimer.Start();
            _thirtyMinuteTimer.Elapsed += new ElapsedEventHandler((sender, e) => ThirtyMinuteEvent(sender, e,cache.DatabaseCache,cache.InstanceCache,cache.AgentJobCache));

            
        }


        private void SetUpTimer(TimeSpan alertTime, List<Server> ServerList, List<Instance> InstanceList, List<Database> DatabaseList, List<AgentJob> AgentList)
        {
            DateTime current = DateTime.Now;
            TimeSpan timeToGo = alertTime - current.TimeOfDay;
            if (timeToGo < TimeSpan.Zero)
            {
                return;//time already passed
            }
            System.Threading.Timer timer = new System.Threading.Timer(x =>
            {
                this.SetUpDaily(ServerList,InstanceList,DatabaseList,AgentList);
            }, null, timeToGo, System.Threading.Timeout.InfiniteTimeSpan);
        }

        private void SetUpDaily(List<Server> ServerList,List<Instance> InstanceList, List<Database> DatabaseList,List<AgentJob> AgentList)
        {
            Jobs.Daily(ServerList, InstanceList, DatabaseList, AgentList);
            _dailyTimer.Enabled = true;
            _dailyTimer.Start();
            _dailyTimer.Elapsed += new ElapsedEventHandler((sender, e) => DailyEvent(sender, e, ServerList, InstanceList, DatabaseList, AgentList));
        }


        private static void FiveMinuteEvent(object source,ElapsedEventArgs e,List<Server> ServerList, List<Instance> InstanceList, CMSCache Cache)
        {
            //EventLogger.LogEvent("CMS Five Minute Job starting.","Information");
            Jobs.FiveMinutes(Cache.ServerCache,Cache.InstanceCache);
            Cache.CheckForCacheRefresh();
            
            //EventLogger.LogEvent("CMS Five Minute Job complete.","Information");
        }

        private static void ThirtyMinuteEvent(object source, ElapsedEventArgs e,List<Database> DatabaseList, List<Instance> InstanceList, List<AgentJob> AgentList)
        {
            //EventLogger.LogEvent("CMS Thirty Minute Job starting.", "Information");
            Jobs.ThirtyMinutes(DatabaseList,InstanceList,AgentList);
            //EventLogger.LogEvent("CMS Thirty Minute Job complete.", "Information");
        }
        private static void DailyEvent(object source, ElapsedEventArgs e,List<Server> ServerList,List<Instance> InstanceList,List<Database> DatabaseList,List<AgentJob> AgentJobList)
        {
            //EventLogger.LogEvent("CMS Daily Job starting.", "Information");
            Jobs.Daily(ServerList, InstanceList, DatabaseList, AgentJobList);
            //EventLogger.LogEvent("CMS Daily Job complete.", "Information");
        }
        
        private DateTime GatherLastDailyExecution()
        {
            DateTime _lastDateTime = new DateTime();

            DataSet _lastDailyExecution = Jobs.ConnectRepository("select top 1 StartTime from CollectionLog where ModuleName = 'Daily' order by LogID desc");
            if (Jobs.TestDataSet(_lastDailyExecution))
            {
                foreach (DataRow pRow in _lastDailyExecution.Tables[0].Rows)
                {
                    _lastDateTime = (DateTime)pRow["StartTime"];
                }
            }
            else 
            {
                _lastDateTime = Convert.ToDateTime("01/01/1900");
            }

            return _lastDateTime;
        }

        /// <summary>
        /// OnStop(): Put your stop code here
        /// - Stop threads, set final data, etc.
        /// </summary>
        protected override void OnStop()
        {
            base.OnStop();
        }

        /// <summary>
        /// OnPause: Put your pause code here
        /// - Pause working threads, etc.
        /// </summary>
        protected override void OnPause()
        {
            base.OnPause();
        }

        /// <summary>
        /// OnContinue(): Put your continue code here
        /// - Un-pause working threads, etc.
        /// </summary>
        protected override void OnContinue()
        {
            base.OnContinue();
        }

        /// <summary>
        /// OnShutdown(): Called when the System is shutting down
        /// - Put code here when you need special handling
        ///   of code that deals with a system shutdown, such
        ///   as saving special data before shutdown.
        /// </summary>
        protected override void OnShutdown()
        {
            base.OnShutdown();
        }

        /// <summary>
        /// OnCustomCommand(): If you need to send a command to your
        ///   service without the need for Remoting or Sockets, use
        ///   this method to do custom methods.
        /// </summary>
        /// <param name="command">Arbitrary Integer between 128 & 256</param>
        protected override void OnCustomCommand(int command)
        {
            //  A custom command can be sent to a service by using this method:
            //#  int command = 128; //Some Arbitrary number between 128 & 256
            //#  ServiceController sc = new ServiceController("NameOfService");
            //#  sc.ExecuteCommand(command);

            base.OnCustomCommand(command);
        }

        /// <summary>
        /// OnPowerEvent(): Useful for detecting power status changes,
        ///   such as going into Suspend mode or Low Battery for laptops.
        /// </summary>
        /// <param name="powerStatus">The Power Broadcast Status
        /// (BatteryLow, Suspend, etc.)</param>
        protected override bool OnPowerEvent(PowerBroadcastStatus powerStatus)
        {
            return base.OnPowerEvent(powerStatus);
        }

        /// <summary>
        /// OnSessionChange(): To handle a change event
        ///   from a Terminal Server session.
        ///   Useful if you need to determine
        ///   when a user logs in remotely or logs off,
        ///   or when someone logs into the console.
        /// </summary>
        /// <param name="changeDescription">The Session Change
        /// Event that occured.</param>
        protected override void OnSessionChange(
                  SessionChangeDescription changeDescription)
        {
            base.OnSessionChange(changeDescription);
        }
    }
}
