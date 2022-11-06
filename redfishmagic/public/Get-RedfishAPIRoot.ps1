
function Get-RedfishAPIRoot {
    #API Ping function to confirm credentials are correct and add the version to the session
    param (
        [Parameter(Mandatory = $True)]
        [string]$Target <#,
        [Parameter(Mandatory = $True)]
        [pscredential]$Credential
        #>
        
    )
    begin{
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        $Uri = "https://$Target/redfish/v1"
    }
    process{
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        try {
            #$Result = Invoke-RedfishMethod -uri $Uri -Method Get
            $Result = Invoke-RedfishMethod -uri $Uri -Method Get #-Credential $Credential
            $($Result.Content | ConvertFrom-Json)
        }
        catch {
            Write-Error "Failed to get the root API for some reason. Use -Verbose to see debug"
        }


    }
    end{
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"

    }  
}