Set-Location -Path $PSScriptRoot
$ModuleName = "redfishmagic"
$ModulePath = "./"+ $ModuleName
$Public  = @( Get-ChildItem -Path .\Public\*.* -ErrorAction SilentlyContinue -Recurse)
$Private  = @( Get-ChildItem -Path .\Private\*.* -ErrorAction SilentlyContinue -Recurse)
$Classes  = @( Get-ChildItem -Path .\Classes\*.* -ErrorAction SilentlyContinue -Recurse)

Write-Host "Classes files: " $Classes.Count

$PublicItemsDestination = Join-Path $ModulePath -ChildPath "Public"
$PrivateItemsDestination = Join-Path $ModulePath -ChildPath "Private"
$ClassItemsDestination = Join-Path $ModulePath -ChildPath "Classes"
if(-not $(Test-Path -Path $ClassItemsDestination -PathType Container)){
    New-Item -Path $ClassItemsDestination -ItemType Directory

}
$Classes | Copy-Item -Destination $ClassItemsDestination -Force
$Public | Copy-Item -Destination $PublicItemsDestination -Force
$Private  | Copy-Item -Destination $PrivateItemsDestination -Force


#Get-ChildItem -Path .\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse | Copy-Item -Destination $PublicItemsDestination -Force
#Get-ChildItem -Path .\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse | Copy-Item -Destination $PPrivateItemsDestination -Force
$PublicFunctionsToExport = @(ForEach($Function in $Public){
    $Name = $($Function.Name).ToString()
    $Name.Trim(".ps1")
    }
)

$ClassesToExport =  @(ForEach($Function in $Classes){
    $Name = $($Function.Name).ToString()
    $Name.Trim(".ps1")
    }
)

#$FunctionsToExport = '"{0}"' -f ($PublicFunctionsToExport -join '","')


$ModuleContent = @"
#Get public and private function definition files.
`$Classes = @( Get-ChildItem -Path `$PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue -Recurse )
`$Public  = @( Get-ChildItem -Path `$PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse )
`$Private = @( Get-ChildItem -Path `$PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse )

#Write-Verbose -Message "Create New Sessions Collection"
#[System.Collections.ArrayList]`$Global:RedfishSessions = @()

#Dot source the files
foreach(`$import in @(`$Public + `$Private + `$Classes)) {
    Try {
        Write-Verbose -Message "Importing `$(`$Import.Fullname)"
        . `$import.fullName
    } Catch {
        Write-Error -Message "Failed to import function `$(`$import.fullName): `$_"
    }
}

# Read in or create an initial config file and variable
# Export Public functions (`$Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only
Add-Type -AssemblyName System.Web

Export-ModuleMember -Function `$Public.Basename -Alias *
"@
$ModuleParameters = @{
    ModuleVersion = "0.0.1"
    GUID = '61d5c699-60b4-4df6-b6e2-3c21b3902c25'
    Author = 'David Alderman'
    CompanyName = 'David Alderman'
    Copyright = '(c)2022 David Alderman. All rights reserved.'
    Description = 'PowerShell API Wrapper for DMTF Redfish Standard'
    PowerShellVersion = "3.0"
       
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
}

$ManifestFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
$ModuleFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psm1"
New-ModuleManifest -Path $ManifestFile @ModuleParameters -FunctionsToExport $PublicFunctionsToExport -PassThru
Set-Content -Path $ModuleFile -Value $ModuleContent -Force
# Import-Module $ModulePath -Force