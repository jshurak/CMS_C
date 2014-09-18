using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceProcess;
using System.Diagnostics;
using System.Timers;

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

            Timer _fiveMinuteTimer = new Timer(300000);
            Timer _thirtyMinuteTimer = new Timer(1000 * 60 * 30);
            Timer _dailyTimer = new Timer(1000 * 60 * 60 * 24);
            

            _fiveMinuteTimer.Enabled = true;
            _fiveMinuteTimer.Start();
            _fiveMinuteTimer.Elapsed += new ElapsedEventHandler(FiveMinuteEvent);

            _thirtyMinuteTimer.Enabled = true;
            _thirtyMinuteTimer.Start();
            _thirtyMinuteTimer.Elapsed += new ElapsedEventHandler(ThirtyMinuteEvent);

            _dailyTimer.Enabled = true;
            _dailyTimer.Start();
            _dailyTimer.Elapsed += new ElapsedEventHandler(DailyEvent);
        }


        private static void FiveMinuteEvent(object source,ElapsedEventArgs e)
        {
            EventLogger.LogEvent("CMS Five Minute Job starting.","Information");
            Jobs.FiveMinutes();
            EventLogger.LogEvent("CMS Five Minute Job complete.","Information");
        }

        private static void ThirtyMinuteEvent(object source, ElapsedEventArgs e)
        {
            EventLogger.LogEvent("CMS Thirty Minute Job starting.", "Information");
            Jobs.ThirtyMinutes();
            EventLogger.LogEvent("CMS Thirty Minute Job complete.", "Information");
        }
        private static void DailyEvent(object source, ElapsedEventArgs e)
        {
            EventLogger.LogEvent("CMS Daily Job starting.", "Information");
            Jobs.Daily();
            EventLogger.LogEvent("CMS Daily Job complete.", "Information");
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
