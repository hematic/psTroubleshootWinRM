---
external help file: psTroubleshootWinRM-help.xml
Module Name: psTroubleshootWinRM
online version:
schema: 2.0.0
---

# Convert-WinrmError

## SYNOPSIS
Function to help troubleshoot Powershell Remoting failures.

## SYNTAX

```
Convert-WinrmError [-server] <String> [-thrown_error] <Object> [[-test_ping] <Boolean>] [[-test_dns] <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
I needed a function that would take the myriad of random returns that 
psRemoting gives as errors and consolidate them into useful information 
in a standardized format.
This function aims to do that.

## EXAMPLES

### EXAMPLE 1
```
This example tries to run a simple invoke-command against a machine
```

and if it fails it calls the fucntion with full ping and DNS checking enabled.

Try{
    $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock{
        $env:computername
    } -ErrorAction Stop
    Write-Host "\`t This Server did not error.
Hostname is $env:computername"

}
Catch {
    $Result = Convert-WinrmError -server $server.name -thrown_error $_ -test_ping $true -test_dns $true
    $result
}

### EXAMPLE 2
```
This example tries to run a simple invoke-command against a machine
```

and if it fails it calls the fucntion with no ping or dns checking.

Try{
    $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock{
        $env:computername
    } -ErrorAction Stop
    Write-Host "\`t This Server did not error.
Hostname is $env:computername"

}
Catch {
    $Result = Convert-WinrmError -server $server.name -thrown_error $_
    $result
}

## PARAMETERS

### -server
The name of the server to troubleshoot.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -thrown_error
The error object thrown by the failed remoting command.
This parameter is mandatory.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -test_ping
A switch to determine if a ping test should be performed.
It is not mandatory and defaults to false.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -test_dns
A switch to determine if a DNS resolution test should be performed.
It is not mandatory and defaults to false.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### Returns a psObject with the following properties:
###     "server" = The name of the server passed to the function.
###     "full_error" = The entire exception thrown by powershell.
###     "ping_result" = A result of a Test-Connection command.
###     "dns_result" = The result of a Resolve-DNSName command.
###     "short_error" = A friendly short error that hopefully gives most of whats relevant from the full exception.
## NOTES

## RELATED LINKS
