using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

namespace CMS_C
{
    class EventLogger
    {
        public static void LogEvent(string Message,string EntryType)
        {
            EventLog eventlog = new EventLog("Application");
            eventlog.Source = "CMS Collector";
            
            var entryType = (EventLogEntryType)Enum.Parse(typeof(EventLogEntryType), EntryType);
            eventlog.WriteEntry(Message,entryType);
        }
    }
}
