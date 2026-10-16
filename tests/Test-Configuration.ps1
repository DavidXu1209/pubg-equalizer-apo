$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'tools\Manage-PUBG.ps1')
function Assert($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
$testDir = Join-Path ([IO.Path]::GetTempPath()) ('pubg-apo-test-' + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $testDir
$template = Join-Path (Split-Path $PSScriptRoot -Parent) 'presets\PUBG-CloudIII.txt'
$plugin = Join-Path $testDir 'test-plugin.dll'
Write-Utf8File $plugin 'Test placeholder. Never loaded or executed.'
$config = Join-Path $testDir 'config.txt'
$original = [byte[]](239,187,191,35,32,111,114,105,103,105,110,97,108,13,10,80,114,101,97,109,112,58,32,45,54,32,100,66,13,10)
[IO.File]::WriteAllBytes($config,$original)
$originalHash = (Get-FileHash -LiteralPath $config).Hash
$id = '{00000000-1111-2222-3333-444444444444}'
$first = Set-PubgConfiguration $testDir Enable $id $template $plugin
Assert ((Get-FileHash -LiteralPath $first.Backup).Hash -eq $originalHash) 'Original bytes were not preserved.'
Assert (([IO.File]::ReadAllText($config)).Contains('Device: ' + $id)) 'Preset is not restricted to the selected endpoint.'
Assert (([IO.File]::ReadAllText((Join-Path $testDir 'pubg-cloudiii.txt'))).Contains($plugin)) 'Installed DLL path was not substituted.'
$second = Set-PubgConfiguration $testDir Enable $id $template $plugin
Assert ($second.Backup -eq $first.Backup) 'Repeated Enable replaced the original backup.'
$null = Set-PubgConfiguration -Directory $testDir -Mode Disable
Assert (-not ([IO.File]::ReadAllText($config)).Contains('Include:')) 'Disable left the processing enabled.'
$null = Set-PubgConfiguration $testDir Enable $id $template $plugin
$null = Set-PubgConfiguration -Directory $testDir -Mode Restore
Assert ((Get-FileHash -LiteralPath $config).Hash -eq $originalHash) 'Restore changed the original bytes.'
$failed = $false
try { $null = Set-PubgConfiguration $testDir Enable $id $template (Join-Path $testDir 'missing.dll') } catch { $failed = $true }
Assert $failed 'Missing DLL was accepted.'
Assert ((Get-FileHash -LiteralPath $config).Hash -eq $originalHash) 'Missing DLL changed the original config.'
$null = Set-PubgConfiguration $testDir Enable $id $template $plugin
Write-Utf8File $config '# Manually edited after enable'
$failed = $false
try { $null = Set-PubgConfiguration $testDir Enable $id $template $plugin } catch { $failed = $true }
Assert $failed 'Unexpected manual edits were overwritten.'
Assert (([IO.File]::ReadAllText($config)) -eq '# Manually edited after enable') 'The manual edit was not preserved.'
$empty = Join-Path $testDir 'initially-empty'
$null = New-Item -ItemType Directory -Path $empty
$null = Set-PubgConfiguration $empty Enable $id $template $plugin
$null = Set-PubgConfiguration -Directory $empty -Mode Restore
Assert (-not (Test-Path -LiteralPath (Join-Path $empty 'config.txt'))) 'Restore did not preserve the original absence of config.txt.'
$failed = $false
try { Assert-X64Plugin $plugin } catch { $failed = $true }
Assert $failed 'Invalid DLL was accepted.'
$pe = New-Object byte[] 128
$pe[0] = 0x4D; $pe[1] = 0x5A; $pe[60] = 64
$pe[64] = 0x50; $pe[65] = 0x45; $pe[68] = 0x64; $pe[69] = 0x86
[IO.File]::WriteAllBytes($plugin,$pe)
Assert-X64Plugin $plugin
$pe[68] = 0x4C; $pe[69] = 0x01
[IO.File]::WriteAllBytes($plugin,$pe)
$failed = $false
try { Assert-X64Plugin $plugin } catch { $failed = $true }
Assert $failed '32-bit DLL was accepted.'
Write-Host 'PASS: backup, selected-device scope, DLL path, repeated enable, disable/re-enable, exact restore, missing dependency, manual edit protection, originally absent config, DLL architecture.'
