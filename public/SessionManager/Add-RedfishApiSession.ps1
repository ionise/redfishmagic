function Add-RedfishApiSession{
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.PARAMETER <ParameterName>
    The description of a parameter. Add a .PARAMETER keyword for each parameter in the function or script syntax.
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [OutputType([type])]
    param(
        [Parameter(Mandatory=$true)]
        [psobject]
        $RedfishSession,
        [Parameter(Mandatory=$false)]
        [int]
        $RedfishVersion
    )
    
    begin {
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        # Check for an existing sessions collection and initialise it if there isnt one.
        if($script:RedFishSessions){
            Write-Verbose -Message "Existing Sessions Collection"
            # TODO Check for existing session to same endpoint and remove it if there is one.
        }else{
            Write-Verbose -Message "Create New Sessions Collection"
            [System.Collections.ArrayList]$Script:RedfishSessions = @()
        }
        $XAuthToken = $($RedfishSession.SessionHeaders.'X-Auth-Token').ToString()
        $Location =  $($RedfishSession.SessionHeaders.'Location').ToString()
        $Id = $RedfishSession.Id
        $Name = $RedfishSession.Name
        $TimeStamp = Get-Date
    }
    process {
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        if($RedfishVersion -gt 160){
            Write-Verbose -Message "Getting the SessionTimeout from the SessionService"
            
            $uri = "https://$($RedfishSession.Name)/redfish/v1/SessionService"
            $Result = Invoke-RedfishMethod -uri $uri -Method Get -XToken $XAuthToken
            If($Result.StatusCode -eq 200){
                [int]$SessionTimeout = $($Result.Content | ConvertFrom-Json).SessionTimeout
            }else{
                Write-Verbose -Message "Redfish API did not return a successful result, setting SessionTimeout for SessionService default to 60 Seconds"
                $SessionTimeout=60
            }
        }
        Else{
            Write-Verbose -Message "Redfish Version less than 1.6, unknown SessionTimeout from the SessionService default to 60 seconds"
            $SessionTimeout=60
        }
        Write-Verbose -Message "Add new session to the collection"
        $Session = [pscustomobject]@{
            Id = [guid]$Id
            Name = [string]$Name
            XauthToken = [string]$XAuthToken
            Location = [string]$Location
            Timestamp = [DateTime]$TimeStamp
            SessionTimeout = [int]$SessionTimeout
            Version = [int]$RedfishVersion
        }
        $($Script:RedfishSessions.add($Session)) | Out-Null

    }
    end {
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}