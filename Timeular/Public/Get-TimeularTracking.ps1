function Get-TimeularTracking {
    [CmdletBinding()]

    Param (
    )

    $VerbosePrefix = "Get-TimeularTracking:"

    $Response = Invoke-TimeularApiCall -Endpoint '/tracking' -Body $Body -Method 'GET'
    $Response = $Response.currentTracking

    if ($null -eq $Response) {
        $false
    } else {
        $ReturnObject = "" | Select-Object `
            ActivityId, Name, Color, Integration, `
            StartTime, `
            Note, Tag, Mention

        $ReturnObject.ActivityId = $Response.activity.id
        $ReturnObject.Name = $Response.activity.name
        $ReturnObject.Color = $Response.activity.color
        $ReturnObject.Integration = $Response.activity.integration

        $ReturnObject.StartTime = [datetime]$Response.startedAt

        $ReturnObject.Note = $Response.note.text
        $ReturnObject.Tag = $Response.note.tags
        $ReturnObject.Mention = $Response.note.mentions

        $ReturnObject
    }
}