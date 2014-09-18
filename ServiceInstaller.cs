using System;
using System.Collections;
using System.Configuration.Install;
using System.ServiceProcess;
using System.ComponentModel;


[RunInstaller(true)]
public class CMSServiceInstaller : Installer
{
    private ServiceInstaller serviceInstaller;
    private ServiceProcessInstaller processInstaller;

    public CMSServiceInstaller()
    {
        serviceInstaller = new ServiceInstaller();
        processInstaller = new ServiceProcessInstaller();

        processInstaller.Account = ServiceAccount.LocalSystem;
        serviceInstaller.StartType = ServiceStartMode.Manual;
        serviceInstaller.ServiceName = "CMS Collector";

        Installers.Add(serviceInstaller);
        Installers.Add(processInstaller);
            
    }
}
