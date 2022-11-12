
function New-RedfishApiSession {
    <#
    .SYNOPSIS
        Authenticate with Redfish API and obtain a session token etc...
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Target,
        [Parameter(Mandatory=$true)]
        [pscredential]
        $Credential,
        [Parameter(Mandatory=$true)]
        [int]
        $RedfishAPIVersion
    )
    begin {
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        if($RedfishVersion -ge 160) {
                Write-Verbose -Message "$($RedfishVersion ) indicates Redfish version greater than than 1.6"
                $uri = "https://$Target/redfish/v1/SessionService/Sessions"
        }
        elseif ($RedfishVersion -lt 160) {
                Write-Verbose -Message "$($RedfishVersion ) indicates Redfish version less than 1.6"
                $uri = "https://$Target/redfish/v1/Sessions"
        }
        else {        
                Write-Error "`n- ERROR, Unable to determine Sessions URI from parsed Redfish version"
                throw
        }
        Write-Verbose -Message "Sessions URI: $Uri"
        $Body = @{
                'UserName' = $Credential.GetNetworkCredential().UserName 
                'Password' = $Credential.GetNetworkCredential().Password
        }
    }
    process {
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        try {
            $Result = Invoke-RedfishMethod -uri $Uri -Body $Body -Method Post -ContentType 'application/json' -Timeout 15
            Write-Verbose -Message "Result.StatusCode:$($Result.Statuscode)"
            Switch($Result.StatusCode){
                201 {
                    Write-Verbose -Message "StatusCode 201 - Resource Created"
                    Write-Verbose -Message "Returning the session"
                    $RedfishSession =[ordered]@{
                        Id = New-Guid
                        Name = $Target
                        SessionHeaders = $Result.Headers
                        SessionBody = $Result.Content
                        Credential = $Credential
                    }
                    [pscustomobject]$RedfishSession
                }
                Default{
                    $ErrorMessage = "Unhandled status code obtaining x-auth-token"
                    Write-Verbose -Message $ErrorMessage
                    throw $ErrorMessage
                }
            }
        }
        catch {
            Write-Verbose -Message "Could not obtain x-auth-token"
            throw "Failed to obtain x-auth-token from $Target $($_.Exception.message)"
        }
    }
    end {
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}
    