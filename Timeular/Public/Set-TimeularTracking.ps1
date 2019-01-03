function Set-TimeularTracking {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $True)]
        [int]$ActivityId,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Note
    )

    $VerbosePrefix = "Set-TimeularTracking:"

    $ApiParam = @{}
    $ApiParam.Endpoint = '/tracking' + '/' + $ActivityId
    $ApiParam.Method = 'PATCH'

    # Parse Note
    $MentionOrTagRx = [regex] '(@|#)([^\ ]+)'

    $Mentions = @()
    $Tags = @()
    $i = 0
    do {
        $Match = $MentionOrTagRx.Match($Note)
        if ($Match.Success) {
            $i++
            $StartNote = $Note.Substring(0, $Match.Index)
            $StopNote = $Note.Substring($Match.Index + 1)
            $Note = $StartNote + $StopNote
            switch ($Match.Groups[1].Value) {
                '@' {
                    $NewMention = @{}
                    $NewMention.indices = @()
                    $NewMention.indices += $Match.Index
                    $NewMention.indices += $Match.Index + $Match.Length - 1
                    $NewMention.key = $Match.Groups[2].Value
                    $Mentions += $NewMention
                }
                '#' {
                    $NewTag = @{}
                    $NewTag.indices = @()
                    $NewTag.indices += $Match.Index
                    $NewTag.indices += $Match.Index + $Match.Length - 1
                    $NewTag.key = $Match.Groups[2].Value
                    $Tags += $NewTag
                }
            }
        }
    } while ($Match.Success)

    $Body = @{}
    $Body.note = @{}
    $Body.note.text = $Note
    $Body.note.mentions = $Mentions
    $Body.note.tags = $Tags
    $Body = $Body | ConvertTo-Json -Compress -Depth 5
    Write-Verbose "$VerbosePrefix $Body"

    $ApiParam.Body = $Body

    $Response = Invoke-TimeularApiCall @ApiParam

    $Response
}