param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir
)

$ErrorActionPreference = 'Stop'
$appName = '默影视实验室版'
$appNameTW = '默影視實驗室版'
$enc = New-Object System.Text.UTF8Encoding($false)

Get-ChildItem -LiteralPath (Join-Path $SourceDir 'app\src') -Recurse -Filter 'strings.xml' | ForEach-Object {
    $file = $_.FullName
    $newName = if ($file -match 'values-zh-rTW') { $appNameTW } else { $appName }
    $txt = [System.IO.File]::ReadAllText($file)
    $patched = [regex]::Replace($txt, '<string name="app_name">[^<]*</string>', '<string name="app_name">' + $newName + '</string>')
    if ($patched -ne $txt) {
        [System.IO.File]::WriteAllText($file, $patched, $enc)
    }
}

$gradleFile = Join-Path $SourceDir 'app\build.gradle'
$g = [System.IO.File]::ReadAllText($gradleFile)
$g = [regex]::Replace($g, 'applicationId\s+"[^"]+"', 'applicationId "com.myself.movie.lab"')
if ($g -notmatch 'libs\.commons\.compress') {
    $g = [regex]::Replace($g, '(?s)(dependencies \{\r?\n.*?)\r?\n\}', "`$1`n    implementation libs.commons.compress`n    implementation libs.xz`n}", 1)
}
[System.IO.File]::WriteAllText($gradleFile, $g, $enc)

$tomlFile = Join-Path $SourceDir 'gradle\libs.versions.toml'
$t = [System.IO.File]::ReadAllText($tomlFile)
if ($t -notmatch 'commonsCompress\s*=') {
    $t = [regex]::Replace($t, '(\r?\n\[libraries\])', "`ncommonsCompress = `"1.27.1`"`nxz = `"1.10`"`$1", 1)
}
if ($t -notmatch 'commons-compress\s*=\s*\{') {
    $libLine = "commons-compress = { group = `"org.apache.commons`", name = `"commons-compress`", version.ref = `"commonsCompress`" }`nxz = { group = `"org.tukaani`", name = `"xz`", version.ref = `"xz`" }"
    if ($t -match '\r?\n\[plugins\]') {
        $t = [regex]::Replace($t, '(\r?\n\[plugins\])', "`n$libLine`$1", 1)
    } elseif ($t -match '\r?\n\[bundles\]') {
        $t = [regex]::Replace($t, '(\r?\n\[bundles\])', "`n$libLine`$1", 1)
    } else {
        $t = $t.TrimEnd() + "`n`n$libLine`n"
    }
}
[System.IO.File]::WriteAllText($tomlFile, $t, $enc)

Write-Host '实验室补丁已应用'
