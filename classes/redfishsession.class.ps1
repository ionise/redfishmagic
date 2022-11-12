
class redfishsession {
	[string]$Controller
	[string]$BaseURL
	[string]$SessionID
	[securestring]$AuthToken
    [pscredential]$Credential
	[datetime]$Timestamp = $(Get-Date)
	[int]$SessionTimeout = 300
    [int]$RedfishVersion
	# Constructors
	redfishsession () {
	}
    
    redfishsession ([string]$Controller, [pscredential]$Credential) {
		$this.Controller = $Controller
		$this.Credential = $Credential
        $this.BaseURL = "https://$($This.Controller)"
        try {
            Write-Verbose -Message "Testing connection to RedfishAPIRoot"
            $TestRedfishAPIRoot = Get-RedfishAPIRoot -Target $This.Controller
            Write-Verbose -Message "Testing connection to RedfishAPIRoot"
            If($TestRedfishAPIRoot.StatusCode -eq 200){
                $RedfishAPIRoot = $($TestRedfishAPIRoot.Content | ConvertFrom-Json)
                Write-Verbose -Message "Raw RedfishVersion: $($RedfishAPIRoot.RedfishVersion)"
                $This.RedfishVersion = [int]$($RedfishAPIRoot.RedfishVersion).replace('.', '')
                Write-Verbose -Message "Parsed RedfishVersion: $($this.RedfishVersion)"
                $RedfishSession = New-RedfishAPISession -Target $This.Controller -Credential $This.Credential -RedfishAPIVersion $This.RedfishVersion
                $This.AuthToken = $($RedfishSession.SessionHeaders.'X-Auth-Token' | ConvertTo-SecureString -AsPlainText -Force)
                $This.SessionId =  $($RedfishSession.SessionHeaders.'Location').ToString() # -replace "/redfish/v1",""
                
                Write-Verbose -Message "Determine the SessionTimeout)"
                $Endpoint = "/redfish/v1/SessionService"
                $uri = $($This.BaseUrl)+$Endpoint
                $Result = Invoke-RedfishMethod -uri $uri -Method Get -XToken $This.AuthToken
                If($Result.StatusCode -eq 200){
                    $This.SessionTimeout = [int]$($Result.Content | ConvertFrom-Json).SessionTimeout
                    Write-Verbose -Message "Redfish SessionTimeout: $($This.SessionTimeout)"
                }else{
                    Write-Verbose -Message "Redfish API did not return a successful result, setting SessionTimeout for SessionService default to 300 Seconds"
                    $This.SessionTimeout=300
                }
            }
        }    
        catch {
            Write-Verbose "Unable to connect to API at $($This.Controller)"
            throw $_
        }
	}

    [void]Logout(){
        $Uri = $This.BaseURL+$This.SessionId
        $Diff = New-Timespan -Start $This.Timestamp -End $(Get-date)
        If([int]$Diff.TotalSeconds -le $This.SessionTimeout){
            Invoke-RedfishRestMethod -uri $Uri -Method Delete -XToken $This.AuthToken
        }
        $this.AuthToken = $null
        $this.SessionID = $null
        $this.SessionTimeout = $null
        $this.Timestamp = $(Get-Date)
        $this.RedfishVersion = 0
    }
    
}