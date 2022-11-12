# Set up a session with a Redfish API
# Send username / password and obtain session token
# Store session token for use by other cmdlets

function Connect-RedfishAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Controller,
        [Parameter(Mandatory = $True)]
        [pscredential]$Credential

    )
    begin{
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        
    }
    process{
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        [redfishsession]::new($Controller,$Credential)
    }
    end{
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}

