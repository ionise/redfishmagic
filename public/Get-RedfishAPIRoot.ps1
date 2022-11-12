
function Get-RedfishAPIRoot {
    #API Ping function to confirm credentials are correct and add the version to the session
    param (
        [Parameter(Mandatory = $True)]
        [string]$Target         
    )
    begin{
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        $Uri = "https://$Target/redfish/v1"
    }
    process{
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        try {
            Write-Verbose -Message "Attempting to connect to APIRoot at $Uri"
            $Result = Invoke-RedfishMethod -uri $Uri -Method Get -Timeout 5
            Write-Verbose -Message "Statuscode: $($Result.StatusCode)"
            If($Result){
                Switch ($Result.StatusCode){
                    404 {
                        Write-Error -Exception "Not Found" -Message "API Endpoint was not found at $Target" -Category ObjectNotFound -RecommendedAction "Check that this endpoint is Redfish capable"
                    }
                    200 {
                        Write-Verbose -Message "Succesfully connected to API Root"
                        $Result
                    }
                    default{
                        Break
                    }

                }
            }else{
                $Result = @{
                    StatusCode = 408
                }
            }
        }
        catch {
            Write-Error "Failed to get the root API"
            $Result = @{
                StatusCode = 408
                Content = "Timeout connecting to target"
            }
        }
    }
    end{
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }  
}