# Set up a session with a Redfish API
# Send username / password and obtain session token
# Store session token for use by other cmdlets

function Connect-RedfishAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string[]]$Target,
        [Parameter(Mandatory = $True)]
        [pscredential]$Credential
    )
    begin{
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
    }
    process{
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        ForEach($Endpoint in $Target){
            try {
                Write-Verbose -Message "Testing connection to RedfishAPIRoot"
                $TestRedfishAPIRoot = Get-RedfishAPIRoot -Target $Endpoint
                Write-Verbose -Message "Testing connection to RedfishAPIRoot"
                If($TestRedfishAPIRoot.StatusCode -eq 200){
                    $RedfishAPIRoot = $($TestRedfishAPIRoot.Content | ConvertFrom-Json)
                    Write-Verbose -Message "Raw RedfishVersion: $($RedfishAPIRoot.RedfishVersion)"
                    $RedfishVersion = [int]$($RedfishAPIRoot.RedfishVersion).replace('.', '')
                    Write-Verbose -Message "Parsed RedfishVersion: $($RedfishVersion)"
                    $RedfishSession = New-RedfishAPISession -Target $Endpoint -Credential $Credential -RedfishAPIVersion $RedfishVersion
                    Add-RedfishApiSession -RedfishSession $RedfishSession -RedfishVersion $RedfishVersion
                }
            }    
            catch {
                Write-Verbose "Unable to connect to API at $Endpoint"
                $_
            }
        }
    }
    end{
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}

