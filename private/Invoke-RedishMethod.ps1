
function Invoke-RedfishMethod {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$uri,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Get","Post","Delete")]
        [string]$Method,
        [Parameter(Mandatory=$False)]
        [pscredential]$Credential,
        [Parameter(Mandatory=$False)]
        [string]$XToken,
        [Parameter(Mandatory=$false)]
        $Body,
        [Parameter(Mandatory=$false)]
        [string]$ContentType,
        <# .PARAMETER Timeout
        Specify how long to attempt to connect to the target in seconds. Default 5 Seconds
        #>
        [Parameter(Mandatory=$false)]
        [Int]
        $Timeout = 5
    )
    
    begin {
        Write-Verbose -Message "[BEGIN  ] $($myInvocation.MyCommand)"
        $HostInfo = Get-Host
        $PowerShellVersion = $HostInfo.Version.Major
        Write-Verbose -Message "PowerShellVersion: $PowerShellVersion"
        function SkipCertificateCheck {
            Write-Verbose -Message "[CALLTO ] $($myInvocation.MyCommand)"
            #Helper function to turn off certificate checking on PS5 and lower.
            $Provider = New-Object Microsoft.CSharp.CSharpCodeProvider
            $Compiler = $Provider.CreateCompiler()
            $Parameters = New-Object System.CodeDom.Compiler.CompilerParameters
            $Parameters.GenerateExecutable = $false
            $Parameters.GenerateInMemory = $true
            $Parameters.IncludeDebugInformation = $false
            $Parameters.ReferencedAssemblies.Add("System.DLL") > $null
            $SourceCode = @'
namespace Local.ToolkitExtensions.Net.CertificatePolicy
{
    public class TrustAll : System.Net.ICertificatePolicy
    {
        public bool CheckValidationResult(System.Net.ServicePoint sp,System.Security.Cryptography.X509Certificates.X509Certificate cert, System.Net.WebRequest req, int problem)
        {
            return true;
        }
    }
}
'@ 
            $Results = $Provider.CompileAssemblyFromSource($Parameters, $SourceCode)
            $Assembly = $Results.CompiledAssembly
            ## We create an instance of TrustAll and attach it to the ServicePointManager
            $TrustAll = $Assembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
            [System.Net.ServicePointManager]::CertificatePolicy = $TrustAll
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
        $Arguments=$null
        $Arguments = @{
            Uri = $uri
            Method = $Method
            ErrorVariable = 'ErrorMessage'
        }
    
        Write-Verbose -Message "Setting the appropriate header type"
        If($XToken){
            Write-Verbose -Message "Header type is for XAuth"
            $Headers = @{
                'Accept' = 'application/json'
                'X-Auth-Token' = $XToken
            }
        }else{
            Write-Verbose -Message "Header type is for basic authentication"
            $Headers = @{
                'Accept' = 'application/json'
            }
        }
        Write-Verbose -Message "Headers: $($Headers | ConvertTo-Json)"
        
        $Arguments.Headers = $Headers
    
        If($Credential){
            Write-Verbose -Message "Adding credentials to the arguments"
            $Arguments.Credential = $Credential
        }

        If($Body){
            Write-Verbose -Message "Adding body to the arguments"
            Write-Verbose -Message "Body: $($Body|ConvertTo-Json) "
            #$JsonBody = $Body | ConvertTo-Json -Compress
            $Arguments.Body = $($Body|ConvertTo-Json -Compress)
        }
        If($ContentType){
            Write-Verbose -Message "Adding Content Type to the arguments"
            Write-Verbose -Message "ContentType: $ContentType"
            $Arguments.ContentType = $ContentType
        }
        Write-Verbose -Message "Arguments: $($Arguments | ConvertTo-Json -Depth 2)"

    }
    
    process {
        Write-Verbose -Message "[PROCESS] $($myInvocation.MyCommand)"
        
        try {
            If($PowerShellVersion -gt 5){
                Write-Verbose -Message "New Powershell supports SkipCertificateCheck"
                $Result = Invoke-WebRequest @Arguments -SkipCertificateCheck -SkipHeaderValidation -UseBasicParsing -TimeoutSec $Timeout
            }
            else{
                Write-Verbose -Message "Legacy Powershell needs help to skip certificate checking"
                SkipCertificateCheck
                $Result = Invoke-WebRequest @Arguments -UseBasicParsing -TimeoutSec $Timeout
            }
            Write-Verbose "Result:`r`n$Result"
            Write-Verbose -Message "StatusCode: $($Result.StatusCode) "
            $Result
        }
        catch [System.TimeoutException]{
            Write-Error "Connection Timed out" -Category ConnectionError -CategoryReason "Timeout"
            throw
        }
        catch {
            Write-Error "ERROR, Problem connecting to Redfish API `r`n $($ErrorMessage)"
            Write-Error "Result if any: $($Result | ConvertTo-Json)"
            throw
        }
    }
    end {
        Write-Verbose -Message "[END    ] $($myInvocation.MyCommand)"
    }
}

