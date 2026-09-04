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

# 使用固定签名配置给 debug APK 签名。签名参数由 GitHub Actions 写入
# local.properties；这样每次构建都使用同一把密钥，才能覆盖安装升级。
if ($g -notmatch '(?s)buildTypes\s*\{.*?debug\s*\{\s*signingConfig\s*=') {
    $debugSigning = @"
    debug {
        signingConfig = hasReleaseSigning ? signingConfigs.release : signingConfigs.debug
    }
"@
    if ($g -notmatch '(?s)buildTypes\s*\{\r?\n') {
        throw '上游 app/build.gradle 缺少 buildTypes 配置，无法绑定固定签名'
    }
    $g = [regex]::Replace($g, '(?s)(buildTypes\s*\{\r?\n)', "`$1$debugSigning`n", 1)
}
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



# ===== overlay string duplicate protection V2 =====
# 扫描所有 values XML，自动清理 overlay 与上游重复资源
# 保留上游资源，删除 overlay 同名 string/plurals/string-array

function Remove-DuplicateOverlayResources {
    param(
        [string]$ValuesDir
    )

    if (!(Test-Path $ValuesDir)) {
        return
    }

    $xmlFiles = Get-ChildItem -LiteralPath $ValuesDir -Filter '*.xml'

    $baseNames = @{}

    # 先收集 strings.xml 等基础资源
    foreach ($file in $xmlFiles) {
        if ($file.Name -notmatch 'lab|overlay') {
            try {
                [xml]$xml = Get-Content $file.FullName -Encoding UTF8
                foreach ($node in $xml.resources.string) {
                    $baseNames[$node.name] = $true
                }
                foreach ($node in $xml.resources.plurals) {
                    $baseNames[$node.name] = $true
                }
                foreach ($node in $xml.resources.'string-array') {
                    $baseNames[$node.name] = $true
                }
            } catch {}
        }
    }

    # 再处理 lab/overlay 文件
    foreach ($file in $xmlFiles | Where-Object {$_.Name -match 'lab|overlay'}) {
        try {
            [xml]$xml = Get-Content $file.FullName -Encoding UTF8
            $changed = $false

            @($xml.resources.string) | ForEach-Object {
                if ($baseNames.ContainsKey($_.name)) {
                    [void]$xml.resources.RemoveChild($_)
                    $changed = $true
                }
            }

            @($xml.resources.plurals) | ForEach-Object {
                if ($baseNames.ContainsKey($_.name)) {
                    [void]$xml.resources.RemoveChild($_)
                    $changed = $true
                }
            }

            @($xml.resources.'string-array') | ForEach-Object {
                if ($baseNames.ContainsKey($_.name)) {
                    [void]$xml.resources.RemoveChild($_)
                    $changed = $true
                }
            }

            if ($changed) {
                $xml.Save($file.FullName)
                Write-Host "清理重复资源: $($file.Name)"
            }
        } catch {
            Write-Warning "跳过资源文件: $($file.Name)"
        }
    }
}

$valuesDir = Join-Path $SourceDir 'app\src\main\res\values'
Remove-DuplicateOverlayResources -ValuesDir $valuesDir

Write-Host '实验室补丁已应用（V2自动资源冲突修复）'
