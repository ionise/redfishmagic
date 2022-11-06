# Set up a session with a Redfish API
# Send username / password and obtain session token
# Store session token for use by other cmdlets

function Connect-RedfishAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$IpAddress,
        [Parameter(Mandatory = $True)]
        [pscredential]$Credential
    )
    begin{
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        $Creds = New-Object System.Management.Automation.PSCredential($Credential.UserName, $Credential.Password)
        $Global:Endpoint = $IpAddress
    }
    process{
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        try {
            Write-Verbose -Message "Testing connection to RedfishAPIRoot"  
            $Global:RedfishAPIRoot = Get-RedfishAPIRoot -Target $Global:Endpoint # -Credential $Credential
            Write-Verbose -Message "Raw RedfishVersion: $($Global:RedfishAPIRoot.RedfishVersion)"
            $RedfishVersion = $($Global:RedfishAPIRoot.RedfishVersion).replace('.', '')
            Write-Verbose -Message "Parsed RedfishVersion: $($global:RedfishVersion)"
            $uri = if($RedfishVersion -ge 160) {
                    Write-Verbose -Message "$($global:RedfishVersion ) is bigger than 160"
                    "https://$Global:Endpoint/SessionService/Sessions"
                
                }
                elseif ($RedfishVersion -lt 160) {
                    Write-Verbose -Message "$($global:RedfishVersion ) is smaller than 160"
                    "https://$Global:Endpoint/redfish/v1/Sessions"
                }
                else {        
                    Write-Error "`n- ERROR, Unable to determine Sessions URI from parsed Redfish version"
                    throw
                }

            try {
                Write-Verbose -Message "Attempting Pre-Authentication to $Uri"
                $Result = Invoke-RedfishMethod -uri $Uri -Method Get -Credential $Creds
                Write-Verbose -Message "Result:`n$Result"
                Switch($Result.StatusCode){
                    200 {
                        Write-Verbose -Message "StatusCode 200 - OK"
                    }
                    Default {
                        Write-Verbose -Message "Unhandled status code during pre-authentication"
                    }
                }
            }
            catch {
                    Write-Error "Pre-Authentication failed"
            }
            Write-Verbose -Message "Sessions URI: $Uri"
            $Body = @{
                    'UserName' = $credential.GetNetworkCredential().UserName 
                    'Password' = $credential.GetNetworkCredential().Password
            }
            try {
                $Result = Invoke-RedfishMethod -uri $Uri -Body $Body -Method Post -ContentType 'application/json'
                Write-Verbose -Message "Result:`n$Result"
                Switch($Result.StatusCode){
                    201 {
                        Write-Verbose -Message "StatusCode 201 - Resource Created"
                        Write-Verbose -Message "Storing the session"
                        $Global:RedfishSession = $Result.Headers
                    }
                    Default{
                        Write-Verbose -Message "Unhandled status code obtaining x-auth-token"
                    }
                }


            }
            catch {
                Write-Error -Message "Could not obtain x-auth-token"
            }
            Write-Verbose "Result Headers:`n $($Result.Headers| ConvertTo-Json)"

        }
        catch {
            $_
            Write-Error "Unable to connect to API, use -Verbose to debug"
        }

    }
    end{
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"

    }
}

