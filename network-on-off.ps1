<#
.SYNOPSIS
  Disable or enable all network adapters.

.DESCRIPTION
  -DisableAll : disables all network adapters
  -EnableAll  : enables all network adapters
  Run this script from an elevated PowerShell (Run as Administrator).
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$DisableAll,
    [switch]$EnableAll
)

if (-not ($DisableAll -or $EnableAll)) {
    Write-Host "Use -DisableAll or -EnableAll" -ForegroundColor Yellow
    exit 1
}

# Get all visible network adapters
$adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -ne "Unknown" }

if ($DisableAll) {
    Write-Host "Disabling ALL network adapters..." -ForegroundColor Red
    foreach ($nic in $adapters) {
        if ($PSCmdlet.ShouldProcess($nic.Name, "Disable-NetAdapter")) {
            Disable-NetAdapter -Name $nic.Name -Confirm:$false
        }
    }
    Write-Host "All adapters disabled." -ForegroundColor Green
}

if ($EnableAll) {
    Write-Host "Enabling ALL network adapters..." -ForegroundColor Cyan
    foreach ($nic in $adapters) {
        if ($PSCmdlet.ShouldProcess($nic.Name, "Enable-NetAdapter")) {
            Enable-NetAdapter -Name $nic.Name -Confirm:$false
        }
    }
    Write-Host "All adapters enabled." -ForegroundColor Green
}