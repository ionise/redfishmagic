
function Get-RedfishAPISession {
    <#
    .SYNOPSIS
    Get any existing Redfish API Sessions
    .DESCRIPTION
    This command checks for an existing Redfish API Session.
    If there is an existing session then it will return the Session object
    .PARAMETER All
    Returns all the sessions open on the target.
    .EXAMPLE
    #>
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [switch]
        $All
        
    )
    
    begin {
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
    }
    
    process {
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        Write-Verbose -Message "Checking for existing RedfishSession"
        if(!$Script:RedfishSessions){
            Write-Output "No Redfish session. Use Connect-RedfishAPI before calling this cmdlet"

        }else{
            If($All){
                Write-Verbose -Message "All specified, reaching out to the target for all the current sessions"

            }else{
                Write-Verbose -Message "This is our own session token"
                $Script:RedfishSessions
            }
        }
    }
    
    end {
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
        
    }
}
