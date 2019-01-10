Configuration InstallIIS
# Configuration Main
{

Param ( [string] $nodeName, $WebDeployPackagePath )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature Web-App-Dev
    {
        Name = "Web-App-Dev"
        Ensure = "Present"
    }
    WindowsFeature Web-WMI
    {
        Name="Web-WMI"
        Ensure = "Present"
    }
    WindowsFeature Web-Common-Http
    {
        Name = "Web-Common-Http"
        Ensure = "Present"
    }
    WindowsFeature Web-Security
    {
        Name = "Web-Security"
        Ensure = "Present"
    }
    WindowsFeature Web-Filtering
    {
        Name = "Web-Filtering"
        Ensure = "Present"
    }
    WindowsFeature Web-Static-Content
    {
        Name = "Web-Static-Content"
        Ensure = "Present"
    }
    WindowsFeature Web-Default-Doc
    {
        Name = "Web-Default-Doc"
        Ensure = "Present"
    }
    WindowsFeature Web-Dir-Browsing
    {
        Name = "Web-Dir-Browsing"
        Ensure = "Present"
    }
    WindowsFeature Web-Http-Errors
    {
        Name = "Web-Http-Errors"
        Ensure = "Present"
    }
    WindowsFeature Web-Http-Redirect
    {
        Name = "Web-Http-Redirect"
        Ensure = "Present"
    }
    WindowsFeature Web-ISAPI-Ext
    {
        Name = "Web-ISAPI-Ext"
        Ensure = "Present"
    }
    WindowsFeature Web-ISAPI-Filter
    {
        Name = "Web-ISAPI-Filter"
        Ensure = "Present"
    }
    WindowsFeature Web-Health
    {
        Name = "Web-Health"
        Ensure = "Present"
    }
    WindowsFeature Web-Http-Logging
    {
        Name = "Web-Http-Logging"
        Ensure = "Present"
    }
    WindowsFeature Web-Log-Libraries
    {
        Name = "Web-Log-Libraries"
        Ensure = "Present"
    }
    WindowsFeature Web-Request-Monitor
    {
        Name = "Web-Request-Monitor"
        Ensure = "Present"
    }
    WindowsFeature Web-Http-Tracing
    {
        Name = "Web-Http-Tracing"
        Ensure = "Present"
    }
    WindowsFeature Web-Basic-Auth
    {
        Name = "Web-Basic-Auth"
        Ensure = "Present"
    }
    WindowsFeature Web-Windows-Auth
    {
        Name = "Web-Windows-Auth"
        Ensure = "Present"
    }
    WindowsFeature Web-Url-Auth
    {
        Name = "Web-Url-Auth"
        Ensure = "Present"
    }
    WindowsFeature Web-IP-Security
    {
        Name = "Web-IP-Security"
        Ensure = "Present"
    }
    WindowsFeature Web-Performance
    {
        Name = "Web-Performance"
        Ensure = "Present"
    }
    WindowsFeature Web-Stat-Compression
    {
        Name = "Web-Stat-Compression"
        Ensure = "Present"
    }
    WindowsFeature Web-Dyn-Compression
    {
        Name = "Web-Dyn-Compression"
        Ensure = "Present"
    }
    WindowsFeature Web-Mgmt-Tools
    {
        Name = "Web-Mgmt-Tools"
        Ensure = "Present"
    }
    WindowsFeature Web-Mgmt-Console
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }
    WindowsFeature RSAT-ADDS-Tools
    {
        Name = "RSAT-ADDS-Tools"
        Ensure = "Present"
    }
    WindowsFeature Web-Lgcy-Scripting
    {
        Name = "Web-Lgcy-Scripting"
        Ensure = "Present"
    }
    WindowsFeature Web-Scripting-Tools
    {
        Name = "Web-Scripting-Tools"
        Ensure = "Present"
    }
    WindowsFeature Web-Mgmt-Service
    {
        Name = "Web-Mgmt-Service"
        Ensure = "Present"
    }
    WindowsFeature Web-Mgmt-Compat
    {
        Name = "Web-Mgmt-Compat"
        Ensure = "Present"
    }
    WindowsFeature Web-Metabase
    {
        Name = "Web-Metabase"
        Ensure = "Present"
    }
    WindowsFeature WAS
    {
        Name = "WAS"
        Ensure = "Present"
    }
    WindowsFeature AS-HTTP-Activation
    {
        Name = "AS-HTTP-Activation"
        Ensure = "Present"
    }
    WindowsFeature File-Services
    {
        Name = "File-Services"
        Ensure = "Present"
    }
    WindowsFeature FS-FileServer
    {
        Name = "FS-FileServer"
        Ensure = "Present"
    }
    WindowsFeature Telnet-Client
    {
        Name = "Telnet-Client"
        Ensure = "Present"
    }
    Script DownloadWebDeploy
    {
        TestScript = {
            Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        }
        SetScript ={
            $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
            $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
        DependsOn = "[WindowsFeature]WebServerRole"
    }
    Package InstallWebDeploy
    {
        Ensure = "Present"  
        Path  = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        Name = "Microsoft Web Deploy 3.6"
        ProductId = "{6773A61D-755B-4F74-95CC-97920E45E696}"
        Arguments = "ADDLOCAL=ALL"
        DependsOn = "[Script]DownloadWebDeploy"
    }
    Service StartWebDeploy
    {                    
        Name = "WMSVC"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Package]InstallWebDeploy"
    }
	Script DeployWebPackage
	{
		GetScript = {
            @{
                Result = ""
            }
        }
        TestScript = {
            $false
        }
        SetScript ={
		$WebClient = New-Object -TypeName System.Net.WebClient
		$Destination= "C:\WindowsAzure\WebApplication1.zip" 
        $WebClient.DownloadFile($using:WebDeployPackagePath,$destination)
        $Argument = '-source:package="C:\WindowsAzure\WebApplication1.zip" -dest:auto,ComputerName="localhost", -verb:sync -allowUntrusted'
		$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath")
        Start-Process "$MSDeployPath\msdeploy.exe" $Argument -Verb runas 
        }
    }
  }
}
