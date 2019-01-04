function Connect-Timeular {
    [CmdletBinding()]

    Param (
        [PoshBot.FromConfig()]
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$TimeularApiKey = $global:TimeularApiKey,

        [PoshBot.FromConfig()]
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$TimeularApiSecret = $global:TimeularApiSecret
    )

    $VerbosePrefix = "Connect-Timeular:"


    foreach ($param in @('TimeularApiKey', 'TimeularApiSecret')) {
        if ($null -eq $param) {
            Throw "$param cannot be null. Either specify explicitly or set as global variable."
        }
    }

    $Body = @{}
    $Body.apiKey = $TimeularApiKey
    $Body.apiSecret = $TimeularApiSecret
    $Body = $Body | ConvertTo-Json -Compress

    $Response = Invoke-TimeularApiCall -Endpoint '/developer/sign-in' -Body $Body -Method 'POST'
    $global:TimeularToken = $Response.token
}