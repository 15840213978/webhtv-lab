# patch-lab.ps1 V3
# Disable conflicting overlay resources before Android build

$ErrorActionPreference = "Stop"

Write-Host "=== patch-lab V3 ==="

$root = Get-Location

$valuesDir = Join-Path $root "upstream\app\src\main\res\values"

if (Test-Path $valuesDir) {
    $labStrings = Join-Path $valuesDir "lab_strings.xml"
    $disabled = Join-Path $valuesDir "lab_strings.xml.disabled"

    if (Test-Path $labStrings) {
        if (Test-Path $disabled) {
            Remove-Item $disabled -Force
        }

        Rename-Item $labStrings $disabled -Force
        Write-Host "Disabled conflicting lab_strings.xml"
    }
    else {
        Write-Host "lab_strings.xml not found, skip"
    }
}
else {
    Write-Host "values directory not found, skip"
}

Write-Host "Patch complete"
