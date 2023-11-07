# psTroubleshootWinRM
PowerShell Module to help troubleshoot failed remote commands like Invoke-Command.

# Current Release Notes (1.0.0)
- Initial upload to psGallery.

# Description

I needed a function that would take the myriad of random returns that psRemoting gives as errors and consolidate them into useful information in a standardized format. 
This function aims to do that. It is primarily designed to help you verify that psremoting works against all the servers in your environment, and for ones that don't work give you a standard object back to work from with your troubleshooting.


Release Version [1.0.0](https://www.powershellgallery.com/packages/psTroubleshootWinRM/1.0.0)


# Basic Usage

Below is an example use case for this module.

```
$failures = New-Object -TypeName System.Collections.ArrayList
foreach($server in $windows_servers){
    Write-Host "Processing $($Server)"
    Try{
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock{
            $env:computername
        } -ErrorAction Stop
        #Write-Host "`t This Server did not error. Hostname is $result"
    }
    Catch {
        $Result = Convert-WinrmError -server $server -thrown_error $_ -test_ping $true -test_dns $true
        $failures.add($result) | out-null
    }
}
```

The above code block when run will loop through a list of servers you define and attempt to simply get their hostname with an invoke-command.
If the command works, nothing happens for that server, but if the Invoke-Command fails the catch block will call Convert-WinRMError from the module and return an object with troubleshooting data and add it to the failures arraylist.

The output from the function will look roughly like this.
```
short_error : Generic WINRM Issue. This is probably the winrm config, the service, or the proxy.
server      : <your_server_name>
full_error  : System.Management.Automation.Remoting.PSRemotingTransportException: Connecting to remote server <your_server_name> failed with the following error message The client cannot connect to the destination        
              specified in the request. Verify that the service on the destination is running and is accepting requests. Consult the logs and documentation for the WS-Management service running on the destination,  
              most commonly IIS or WinRM. If the destination is the WinRM service, run the following command on the destination to analyze and configure the WinRM service: "winrm quickconfig". For more information, 
              see the about_Remote_Troubleshooting Help topic.
dns_result  : <your_server_name>.<your_domain>.com:10.187.122.26
ping_result : True
```

## Installation
```
Install-Module -Name psTroubleshootWinRM -Repository PSGallery -Force -Scope CurrentUser
```