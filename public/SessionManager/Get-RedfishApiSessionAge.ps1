function Get-RedfishApiSessionAge {
<#
.SYNOPSIS
    Calculate the age of a session in seconds
.DESCRIPTION
    Utility function to calculate the age of a session in seconds
.PARAMETER RedfishSession
    An object containing a Redfish session
.EXAMPLE
    Get=RedfishApiSessionAge -RedfishSession $RedfishSession
#>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=$true)]
        [psobject]
        $RedfishSession
    )
    Write-Verbose -Message "[CALLTO ] $($myInvocation.MyCommand)"
    $TimeNow = Get-Date
    Write-Verbose -Message "TimeNow: $TimeNow"
    $Timestamp = $RedfishSession.Timestamp
    Write-Verbose -Message "Timestamp: $Timestamp"
    $Diff = New-Timespan -Start $Timestamp -End $TimeNow
    Write-Verbose -Message "Diff:`n $Diff"
    [int]$Diff.TotalSeconds
}