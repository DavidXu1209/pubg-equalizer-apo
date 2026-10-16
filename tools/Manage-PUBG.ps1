[CmdletBinding()]
param(
    [ValidateSet('Enable','Disable','Restore','Status')][string]$Action = 'Status',
    [ValidatePattern('^\{?[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\}?$')][string]$DeviceId,
    [switch]$Pause
)
$ErrorActionPreference = 'Stop'
$script:Marker = '# Managed by pubg-equalizer-apo'

function Write-Utf8File([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Set-PubgConfiguration {
    param([string]$Directory, [ValidateSet('Enable','Disable','Restore')][string]$Mode,
          [string]$SelectedDevice, [string]$Template, [string]$Plugin)
    $configFile = Join-Path $Directory 'config.txt'
    $stateFile = Join-Path $Directory '.pubg-apo-state.json'
    $profileFile = Join-Path $Directory 'pubg-cloudiii.txt'
    $state = if (Test-Path -LiteralPath $stateFile) { Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json } else { $null }
    if ($state -and $state.Active) {
        if (-not (Test-Path -LiteralPath $configFile) -or -not ([IO.File]::ReadAllText($configFile)).StartsWith($script:Marker)) {
            throw 'config.txt was changed outside this manager. No files overwritten. Restore your backup manually or inspect the change first.'
        }
    }
    if ($Mode -eq 'Enable') {
        $id = ([Guid]::Parse($SelectedDevice)).ToString('B')
        if (-not (Test-Path -LiteralPath $Plugin -PathType Leaf)) { throw 'ReaComp DLL is missing; no configuration changed.' }
        if (-not (Test-Path -LiteralPath $Template -PathType Leaf)) { throw 'Preset file is missing; no configuration changed.' }
        if (-not $state -or -not $state.Active) {
            $backupDir = Join-Path $Directory 'pubg-backups'
            $null = New-Item -ItemType Directory -Path $backupDir -Force
            $existed = Test-Path -LiteralPath $configFile -PathType Leaf
            $backup = Join-Path $backupDir ('config-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.txt')
            if ($existed) { Copy-Item -LiteralPath $configFile -Destination $backup }
            $state = [pscustomobject]@{Version=1;Active=$true;OriginalExisted=$existed;Backup=$backup;DeviceId=$id}
        }
        $state.DeviceId = $id
        $preset = [IO.File]::ReadAllText($Template).Replace('C:\Program Files\VSTPlugins\ReaPlugs\reacomp-standalone.dll', $Plugin)
        Write-Utf8File $profileFile $preset
        $root = "$script:Marker`r`n# Applies to one playback endpoint only.`r`nDevice: $id`r`nChannel: L R`r`nInclude: pubg-cloudiii.txt`r`n"
        Write-Utf8File $configFile $root
        Write-Utf8File $stateFile ($state | ConvertTo-Json)
    } elseif ($Mode -eq 'Disable') {
        if (-not $state -or -not $state.Active) { throw 'No managed PUBG preset is active; no files changed.' }
        Write-Utf8File $configFile "$script:Marker`r`n# Bypass: no processing. Use Enable-PUBG to turn the preset back on.`r`n"
    } else {
        if (-not $state -or -not $state.Active) { throw 'No active backup to restore; no files changed.' }
        if ($state.OriginalExisted) {
            if (-not (Test-Path -LiteralPath $state.Backup -PathType Leaf)) { throw 'The original backup is missing; no files changed.' }
            Copy-Item -LiteralPath $state.Backup -Destination $configFile -Force
        } else {
            Remove-Item -LiteralPath $configFile -Force
        }
        $state.Active = $false
        Write-Utf8File $stateFile ($state | ConvertTo-Json)
    }
    return $state
}

function Get-PlaybackDevices {
    $base = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    foreach ($endpoint in Get-ChildItem -LiteralPath $base) {
        if (((Get-ItemProperty -LiteralPath $endpoint.PSPath).DeviceState -band 15) -ne 1) { continue }
        $properties = Get-ItemProperty -LiteralPath ($endpoint.PSPath + '\Properties')
        [pscustomobject]@{
            Id = $endpoint.PSChildName
            Name = [string]$properties.'{b3f8fa53-0004-438e-9003-51a46e139bfc},6'
            Connector = [string]$properties.'{a45c254e-df1c-4efd-8020-67d146a850e0},2'
        }
    }
}

function Assert-X64Plugin([string]$Path) {
    $reader = [IO.BinaryReader]::new([IO.File]::OpenRead($Path))
    try {
        if ($reader.ReadUInt16() -ne 0x5A4D) { throw 'ReaComp is not a Windows DLL.' }
        $reader.BaseStream.Position = 0x3C
        $headerOffset = $reader.ReadInt32()
        if ($headerOffset -lt 64 -or $headerOffset -gt $reader.BaseStream.Length - 6) { throw 'ReaComp DLL has an invalid header.' }
        $reader.BaseStream.Position = $headerOffset
        if ($reader.ReadUInt32() -ne 0x4550 -or $reader.ReadUInt16() -ne 0x8664) { throw 'This preset needs the ReaPlugs x64 build. Install the 64-bit download first.' }
    } finally { $reader.Dispose() }
}

# Dot-sourcing loads the same functions used by the regression checks.
if ($MyInvocation.InvocationName -eq '.') { return }
$resultCode = 0
try {
    if ($Action -ne 'Status') {
        $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $admin) {
            $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -Action {1}' -f $PSCommandPath,$Action
            if ($DeviceId) { $arguments += ' -DeviceId ' + $DeviceId }
            if ($Pause) { $arguments += ' -Pause' }
            $child = Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -PassThru -Wait
            exit $child.ExitCode
        }
    }
    $apo = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\EqualizerAPO' -ErrorAction Stop
    $configDir = [IO.Path]::GetFullPath([string]$apo.ConfigPath)
    if (-not (Test-Path -LiteralPath $configDir -PathType Container)) { throw 'Equalizer APO config folder not found. Finish the official installation first.' }
    if ($Action -eq 'Status') {
        Write-Host ('APO: ' + $apo.InstallPath)
        Write-Host ('Config: ' + $configDir)
        $stateFile = Join-Path $configDir '.pubg-apo-state.json'
        if (Test-Path -LiteralPath $stateFile) { Get-Content -LiteralPath $stateFile }
        else { Write-Host 'This manager has not enabled a preset yet.' }
    } else {
        $template = Join-Path (Split-Path $PSScriptRoot -Parent) 'presets\PUBG-CloudIII.txt'
        $plugin = @(
            (Join-Path $env:ProgramFiles 'VSTPlugins\ReaPlugs\reacomp-standalone.dll'),
            (Join-Path $apo.InstallPath 'VSTPlugins\ReaPlugs\reacomp-standalone.dll'),
            (Join-Path $apo.InstallPath 'plugins\reacomp-standalone.dll')
        ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
        if ($Action -eq 'Enable') {
            if (-not $plugin) { throw 'Install ReaPlugs x64 in its default VST folder, then try again.' }
            Assert-X64Plugin $plugin
            $devices = @(Get-PlaybackDevices | Sort-Object Name,Id)
            if ($DeviceId) {
                $wanted = ([Guid]::Parse($DeviceId)).ToString('B')
                $selected = $devices | Where-Object { $_.Id -eq $wanted }
            } else {
                $hyperx = @($devices | Where-Object { $_.Name -eq 'HyperX Cloud III' })
                if ($hyperx.Count -eq 1) { $selected = $hyperx[0] }
                else {
                    if ($devices.Count -eq 0) { throw 'No active playback devices found. Connect your headphones first.' }
                    for ($i=0; $i -lt $devices.Count; $i++) { Write-Host ('{0}. {1} ({2})' -f ($i+1),$devices[$i].Name,$devices[$i].Connector) }
                    $choice = Read-Host 'Choose your HEADPHONE playback device number'
                    if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $devices.Count) { throw 'Invalid selection; no files changed.' }
                    $selected = $devices[[int]$choice - 1]
                }
            }
            if (-not $selected) { throw 'The requested playback device is not connected; no files changed.' }
            Write-Host ('Headphones: ' + $selected.Name + ' ' + $selected.Id)
            $binding = 'HKLM:\SOFTWARE\EqualizerAPO\Child APOs\' + $selected.Id
            if (-not (Test-Path -LiteralPath $binding)) {
                Start-Process -FilePath (Join-Path $apo.InstallPath 'DeviceSelector.exe') -WorkingDirectory $apo.InstallPath -WindowStyle Normal
                throw 'First-time setup: select this HEADPHONE under Playback devices in Device Selector, apply it, then run Enable-PUBG again. No preset written yet.'
            }
            $state = Set-PubgConfiguration $configDir Enable $selected.Id $template $plugin
            Write-Host 'Preset written. It affects all sound played through this selected endpoint, including music and voice chat.'
            Write-Host 'Keep your current low listening volume. Verify with the APO installation test and a listening comparison; this message does not prove the effect is live.'
        } else {
            $state = Set-PubgConfiguration -Directory $configDir -Mode $Action
            Write-Host ($Action + ' completed.')
        }
        if ($state.Backup) { Write-Host ('Original config backup: ' + $state.Backup) }
    }
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    $resultCode = 1
}
if ($Pause) { $null = Read-Host 'Press Enter to close' }
exit $resultCode
