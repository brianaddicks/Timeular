function Start-TimeularPoshBot {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SlackApiToken,

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]$BotAdmins,

        [Parameter(Mandatory = $false)]
        [switch]$AsJob
    )

    $VerbosePrefix = "Start-TimeularPoshBot:"

    $BotParams = @{
        Name                     = 'TimeularPoshBot'
        BotAdmins                = $BotAdmins
        CommandPrefix            = '!'
        LogLevel                 = 'Info'
        BackendConfiguration     = @{
            Name  = 'SlackBackend'
            Token = $SlackApiToken
        }
        AlternateCommandPrefixes = 'bender', 'hal'
    }

    $MyBotConfig = New-PoshBotConfiguration @BotParams
    if ($AsJob) {
        Start-PoshBot -Configuration $MyBotConfig -AsJob
    } else {
        Start-PoshBot -Configuration $MyBotConfig
    }
}