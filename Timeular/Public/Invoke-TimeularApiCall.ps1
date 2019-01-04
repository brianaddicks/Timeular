function Invoke-TimeularApiCall {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Endpoint,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Body,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $false)]
        [switch]$AutoConnect
    )

    $VerbosePrefix = "Invoke-TimeularApiCall:"
    if ($AutoConnect) {
        Connect-Timeular
    }

    $BaseUri = 'https://api.timeular.com/api/v2'

    $RestParams = @{}
    $RestParams.Headers = @{}
    $RestParams.Uri = $BaseUri + $Endpoint
    $RestParams.Method = $Method
    $RestParams.ContentType = 'application/json'

    if ($Body) {
        $RestParams.Body = $Body
    }

    if ($global:TimeularToken) {
        $RestParams.Headers.Authorization = "Bearer $global:TimeularToken"
    } elseif ($Endpoint -eq '/developer/sign-in') {
    } else {
        Throw "No token present, please use Connect-Timeular to get a valid token."
    }

    $Response = Invoke-RestMethod @RestParams

    return $Response
}