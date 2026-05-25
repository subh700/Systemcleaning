param(
    [Parameter(Mandatory = $false)]
    [string[]]$Extensions = @(".c", ".cpp", ".skm", ".python"),

    [switch]$WhatIfOnly
)

$ErrorActionPreference = "SilentlyContinue"

if ($Extensions.Count -eq 1 -and $Extensions[0] -match ",") {
    $Extensions = $Extensions[0] -split ","
}

function Normalize-Extension {
    param([string]$Ext)

    $e = $Ext.Trim()

    if ([string]::IsNullOrWhiteSpace($e)) {
        return $null
    }

    if (-not $e.StartsWith(".")) {
        $e = "." + $e
    }

    return $e.ToLower()
}

function Is-ExcludedPath {
    param([string]$FullPath)

    $p = $FullPath.ToLower()

    if ($p -match '\\appdata(\\|$)') { return $true }
    if ($p -match '\\contacts(\\|$)') { return $true }

    # Exclude any folder/file path segment starting with "."
    if ($p -match '(\\|^)\.[^\\]+(\\|$)') { return $true }

    return $false
}

$NormalizedExtensions = $Extensions |
    ForEach-Object { Normalize-Extension $_ } |
    Where-Object { $_ -ne $null } |
    Select-Object -Unique

if (-not $NormalizedExtensions -or $NormalizedExtensions.Count -eq 0) {
    Write-Host "No valid extensions provided." -ForegroundColor Red
    exit
}

$SearchRoots = @()

if (Test-Path "C:\Users") {
    $UserFolders = Get-ChildItem -LiteralPath "C:\Users" -Directory -Force |
        Where-Object {
            $_.Name -notlike ".*" -and
            $_.Name -ne "All Users" -and
            $_.Name -ne "Default" -and
            $_.Name -ne "Default User" -and
            $_.Name -ne "Public"
        }

    foreach ($userFolder in $UserFolders) {
        if (-not (Is-ExcludedPath $userFolder.FullName)) {
            $SearchRoots += $userFolder.FullName
        }
    }
}

foreach ($drive in @("D","E","F","G","H")) {
    $drivePath = "$drive`:\"
    if (Test-Path $drivePath) {
        $SearchRoots += $drivePath
    }
}

Write-Host "Extensions to clean:" -ForegroundColor Cyan
$NormalizedExtensions | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "Excluded from target scan:" -ForegroundColor DarkYellow
Write-Host "  Any path containing '\AppData\'"
Write-Host "  Any path containing '\Contacts\'"
Write-Host "  Any folder path segment starting with '.'"

Write-Host ""
Write-Host "Search roots:" -ForegroundColor Cyan
$SearchRoots | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "Scanning files..." -ForegroundColor Yellow

$FilesToDelete = foreach ($root in $SearchRoots) {
    Get-ChildItem -LiteralPath $root -File -Recurse -Force |
        Where-Object {
            ($NormalizedExtensions -contains $_.Extension.ToLower()) -and
            (-not (Is-ExcludedPath $_.FullName))
        }
}

$FilesToDelete = $FilesToDelete | Sort-Object FullName -Unique

Write-Host ""
Write-Host "Found $($FilesToDelete.Count) file(s)." -ForegroundColor Green

if ($FilesToDelete.Count -eq 0) {
    Write-Host "No matching files found."
    exit
}

$TotalBytes = ($FilesToDelete | Measure-Object -Property Length -Sum).Sum
if (-not $TotalBytes) {
    $TotalBytes = 0
}

$TotalMB = [math]::Round($TotalBytes / 1MB, 2)
Write-Host "Total size: $TotalMB MB" -ForegroundColor Green
Write-Host ""

$FilesToDelete |
    Select-Object FullName,
                  @{Name="SizeKB";Expression={[math]::Round($_.Length / 1KB, 2)}} |
    Format-Table -AutoSize

Write-Host ""
$answer = Read-Host "Type YES to delete all listed files"

if ($answer -ne "YES") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

foreach ($file in $FilesToDelete) {
    try {
        if ($WhatIfOnly) {
            Remove-Item -LiteralPath $file.FullName -Force -WhatIf
        }
        else {
            Remove-Item -LiteralPath $file.FullName -Force
            Write-Host "Deleted: $($file.FullName)"
        }
    }
    catch {
        Write-Warning "Could not delete: $($file.FullName)"
    }
}

Write-Host ""
Write-Host "Cleaning completed." -ForegroundColor Cyan