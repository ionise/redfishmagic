function Invoke-RedfishGetMethod {
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
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$RedfishSession,
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [string]
        $Endpoint = $null
    )
    
    begin {
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        $Token = $RedfishSession.AuthToken
        $Uri = $RedfishSession.BaseURL + $Endpoint
        Write-Verbose -Message "URI: $Uri"
        
    }
    
    process {
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        try {
            Write-Verbose -Message "Trying"
            $Result = Invoke-RedfishRestMethod -Uri $Uri -XToken $Token -Method "Get"
            $Result
        }
        catch {
            $_
        }
        

    }
    
    end {
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}