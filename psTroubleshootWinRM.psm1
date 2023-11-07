function Convert-WinrmError {
    <#
    .SYNOPSIS

    Function to help troubleshoot Powershell Remoting failures.

    .DESCRIPTION

    I needed a function that would take the myriad of random returns that 
    psRemoting gives as errors and consolidate them into useful information 
    in a standardized format. This function aims to do that.

    .PARAMETER server
    The name of the server to troubleshoot. This parameter is mandatory.

    .PARAMETER thrown_error
    The error object thrown by the failed remoting command. This parameter is mandatory.

    .PARAMETER test_ping
    A switch to determine if a ping test should be performed. It is not mandatory and defaults to false.

    .PARAMETER test_dns
    A switch to determine if a DNS resolution test should be performed. It is not mandatory and defaults to false.


    .INPUTS

    None.

    .OUTPUTS

    Returns a psObject with the following properties:
        "server" = The name of the server passed to the function.
        "full_error" = The entire exception thrown by powershell.
        "ping_result" = A result of a Test-Connection command.
        "dns_result" = The result of a Resolve-DNSName command.
        "short_error" = A friendly short error that hopefully gives most of whats relevant from the full exception.

    .EXAMPLE
    This example tries to run a simple invoke-command against a machine 
    and if it fails it calls the fucntion with full ping and DNS checking enabled.

    Try{
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock{
            $env:computername
        } -ErrorAction Stop
        Write-Host "`t This Server did not error. Hostname is $env:computername"

    }
    Catch {
        $Result = Convert-WinrmError -server $server.name -thrown_error $_ -test_ping $true -test_dns $true
        $result
    }

    .EXAMPLE
    This example tries to run a simple invoke-command against a machine 
    and if it fails it calls the fucntion with no ping or dns checking.
    
    Try{
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock{
            $env:computername
        } -ErrorAction Stop
        Write-Host "`t This Server did not error. Hostname is $env:computername"

    }
    Catch {
        $Result = Convert-WinrmError -server $server.name -thrown_error $_
        $result
    }
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        HelpMessage="This is the server to test against.")]
        [String]$server,

        [Parameter(Mandatory=$true,
        HelpMessage='This is the full error normally a $_ in your catch block.')]
        [System.Object]$thrown_error,

        [Parameter(Mandatory=$false,
        HelpMessage="This is a bool to decide if you want to run a ping test.")]
        [bool]$test_ping=$false,

        [Parameter(Mandatory=$false,
        HelpMessage="This is a bool to decide if you want to run a DNS test.")]
        [bool]$test_dns=$false

    )
    begin{
        # Attempt to perform a ping test if requested.
        Try{
            if($test_ping){
                $ping_result = Test-Connection -ComputerName  $server -quiet -ErrorAction Stop
            }
            else{
                $ping_result = 'Skipped'
            }
        }
        Catch{
            $ping_result = "ERROR: $($_.exception.message)"
        }
        # Attempt to perform a DNS resolution test if requested.
        Try{
            if($test_dns){
                $dns = Resolve-DnsName -Name $server -ErrorAction Stop
                $dns_result = $dns.name + ':' + $dns.ipaddress
            }
            else{
                $dns_result = 'Skipped'
            }
        }
        Catch{
            $pattern = "(?!.*:)\s*(.*)"
            if ([string]$_.exception -match $pattern) {
                Write-debug 'Worked'
                $dns_result = $matches[1].Trim()
            }
            else{
                Write-debug 'Didnt Work'
                $dns_result = "$($_.exception.message)" 
            }
        }

        # Create a new object to hold the results of the troubleshooting.
        $return_obj = New-Object -typename psobject -Property @{
            "server" = $server
            "full_error" = $thrown_error.exception
            "ping_result" = $ping_result
            "dns_result" = $dns_result
            "short_error" = 'UNKNOWN'
        }
    }
    process{
        # Debugging output of the exception.
        Write-debug "Exception is: $($thrown_error.exception)"
    
        # Analyze the exception message to set a more user-friendly error message.
        Switch -wildcard ($thrown_error.exception){
            '*the server name cannot be resolved*' {
                Write-Debug "`tMatched error successfully: the server name cannot be resolved"
                $return_obj.short_error = 'The WinRM client cannot process the request because the server name cannot be resolved'
            }
            '*The following error with errorcode 0x80090322 occurred while using Kerberos authentication*' {
                Write-Debug "`tMatched error successfully: the server name cannot be resolved"
                $return_obj.short_error = 'The following error with errorcode 0x80090322 occurred while using Kerberos authentication'
            }
            '*cannot determine the content type of the HTTP response*'{
                Write-Debug "`tCannot determine the content type of the HTTP response"
                $return_obj.short_error = 'Bad HTTP response. The content type is absent or invalid'
            }
            '*If the destination is the WinRM service, run the following command on the destination*'{
                Write-Debug "`tIf the destination is the WinRM service, run the following command on the destination'"
                $return_obj.short_error = 'Generic WINRM Issue. This is probably the winrm config, the service, or the proxy.'
            }
            '*WinRM cannot complete the operation*'{
                Write-Debug "`tMatched error successfully: WinRM cannot complete the operation"
                $return_obj.short_error = 'WinRM cannot complete the operation.'
            }
            '*Access is denied*'{
                Write-Debug "`tMatched error successfully: WinRM cannot complete the operation"
                $return_obj.short_error = 'Access is denied.'
            }
            'default' {
                Write-Debug "`tUnable to match error"
                $_ | select -Property *
            }

        }
    }
    
    end{
        # Return the results object to the caller.
        return $return_obj
    }
}