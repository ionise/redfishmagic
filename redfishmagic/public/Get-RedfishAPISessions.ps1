
function Get-RedfishAPISessions {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        if(!$Global:RedfishSession){
            Write-Error "No Redfish session. Use Connect-RedfishAPI before calling this cmdlet" -Category AuthenticationError -RecommendedAction "Run Connect-RedfishAPI first"

        }
    }
    
    process {
        
    }
    
    end {
        
    }
}
