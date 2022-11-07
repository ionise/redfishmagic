function Update-RedfishApiSession {
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
[OutputType([type])]
param(
    [Parameter(Mandatory=$true)]
    [string]
    $parameter_name
)

begin {
    Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
}

process {
    Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
    
}

end {
    Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
}
}