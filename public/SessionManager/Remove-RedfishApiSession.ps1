
function Remove-RedfishApiSession {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
        [CmdletBinding()]
        [OutputType([type])]
        param(
            [Parameter(Mandatory=$false)]
            [string[]]
            $Id
        )
        
        begin {
            Write-Verbose -Message "[BEGIN  ] $(myInvocation.MyCommand)"
        }
        
        process {
            Write-Verbose -Message "[PROCESS] $(myInvocation.MyCommand)"
            
        }
        
        end {
            Write-Verbose -Message "[END    ] $(myInvocation.MyCommand)"
        }
    }
    