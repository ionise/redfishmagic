Set-Location -Path $PSScriptRoot
$ModuleName = "redfishmagic"
$ModulePath = "./"+ $ModuleName
$Public  = @( Get-ChildItem -Path .\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse)
$Private  = @( Get-ChildItem -Path .\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse)

$PublicItemsDestination = Join-Path $ModulePath -ChildPath "Public"
$PPrivateItemsDestination = Join-Path $ModulePath -ChildPath "Private"
$Public | Copy-Item -Destination $PublicItemsDestination -Force
$Private  | Copy-Item -Destination $PPrivateItemsDestination -Force
#Get-ChildItem -Path .\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse | Copy-Item -Destination $PublicItemsDestination -Force
#Get-ChildItem -Path .\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse | Copy-Item -Destination $PPrivateItemsDestination -Force
$PublicFunctionsToExport = @(ForEach($Function in $Public){
    $Name = $($Function.Name).ToString()
    $Name.Trim(".ps1")

}
)
$FunctionsToExport = '"{0}"' -f ($PublicFunctionsToExport -join '","')


$ModuleContent = @"
#Get public and private function definition files.
`$Public  = @( Get-ChildItem -Path `$PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse )
`$Private = @( Get-ChildItem -Path `$PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse )

#Dot source the files
foreach(`$import in @(`$Public + `$Private)) {
    Try {
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
    Copyright = '(c) ContosoAdmin. All rights reserved.'
    Description = 'PowerShell API Wrapper for DMTF Redfish Standard'
    PowerShellVersion = "3.0"
       
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

$ManifestFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
$ModuleFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psm1"
New-ModuleManifest -Path $ManifestFile @ModuleParameters -FunctionsToExport $PublicFunctionsToExport -PassThru
Set-Content -Path $ModuleFile -Value $ModuleContent -Force
