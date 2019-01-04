[Cmdletbinding()]
Param ()
function Resolve-Module {
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name,

        [Parameter()]
        [switch]$AllowClobber
    )

    Process {
        foreach ($ModuleName in $Name) {
            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"

            if ($Module) {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -lt $GalleryVersion) {

                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"

                    Install-Module -Name $ModuleName -Force -AllowClobber:$AllowClobber
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                } else {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            } else {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                Install-Module -Name $ModuleName -Force -AllowClobber:$AllowClobber
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        }
    }
}

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Write-Verbose "Checking before modules"
Get-Command Export-Metadata

Resolve-Module PoshBot
Get-Command Export-Metadata
Write-Verbose "Checking after PoshBot"

Resolve-Module Psake
Get-Command Export-Metadata
Write-Verbose "Checking after Psake"

Resolve-Module PSDeploy
Get-Command Export-Metadata
Write-Verbose "Checking after PSDeploy"

Resolve-Module Pester
Get-Command Export-Metadata
Write-Verbose "Checking after Pester"

Resolve-Module BuildHelpers
Get-Command Export-Metadata
Write-Verbose "Checking after BuildHelpers"


Set-BuildEnvironment -Force

Invoke-psake .\psake.ps1
exit ( [int]( -not $psake.build_success ) )
