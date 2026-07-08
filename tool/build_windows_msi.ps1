param(
  [string] $AppName = "ShimX",
  [string] $ExecutableName = "shimx.exe",
  [string] $Manufacturer = "ShimX",
  [string] $ReleaseDir,
  [string] $OutputDir,
  [string] $Version,
  [string[]] $Cultures = @("zh-CN", "en-US"),
  [switch] $AcceptWix7Eula
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$dotnetRoot = Join-Path $env:USERPROFILE ".dotnet"
$dotnetTools = Join-Path $dotnetRoot "tools"
if (Test-Path $dotnetRoot) {
  if ([string]::IsNullOrWhiteSpace($env:DOTNET_ROOT)) {
    $env:DOTNET_ROOT = $dotnetRoot
  }
  $pathParts = $env:PATH -split ";"
  if ($pathParts -notcontains $dotnetRoot) {
    $env:PATH = "$dotnetRoot;$env:PATH"
  }
  if ((Test-Path $dotnetTools) -and ($pathParts -notcontains $dotnetTools)) {
    $env:PATH = "$dotnetTools;$env:PATH"
  }
}
if ([string]::IsNullOrWhiteSpace($ReleaseDir)) {
  $ReleaseDir = Join-Path $root "build\windows\x64\runner\Release"
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $root "dist"
}

$releasePath = Resolve-Path $ReleaseDir
$exePath = Join-Path $releasePath $ExecutableName
if (-not (Test-Path $exePath)) {
  throw "Release executable not found: $exePath"
}

if ([string]::IsNullOrWhiteSpace($Version)) {
  $pubspecPath = Join-Path $root "pubspec.yaml"
  $versionLine = Get-Content $pubspecPath -Encoding UTF8 |
    Where-Object { $_ -match "^\s*version:\s*" } |
    Select-Object -First 1
  if ($versionLine -match "version:\s*([0-9]+(?:\.[0-9]+){0,2})") {
    $Version = $Matches[1]
  } else {
    $Version = "1.0.0"
  }
}

$parts = $Version.Split(".")
while ($parts.Count -lt 3) {
  $parts += "0"
}
$Version = ($parts[0..2] -join ".")

$wix = Get-Command wix -ErrorAction SilentlyContinue
if ($null -eq $wix) {
  $toolPath = Join-Path $env:USERPROFILE ".dotnet\tools\wix.exe"
  if (Test-Path $toolPath) {
    $wix = Get-Item $toolPath
  } else {
    throw "WiX CLI not found. Run: dotnet tool install --global wix"
  }
}

$workDir = Join-Path $root ".tmp\wix"
New-Item -ItemType Directory -Force -Path $workDir | Out-Null
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Escape-Xml([string] $value) {
  return [System.Security.SecurityElement]::Escape($value)
}

function New-StableId([string] $prefix, [string] $value) {
  $sha1 = [System.Security.Cryptography.SHA1]::Create()
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
  $hash = $sha1.ComputeHash($bytes)
  $hex = [System.BitConverter]::ToString($hash).Replace("-", "")
  return "$prefix$($hex.Substring(0, 32))"
}

function Get-RelativePathCompat([string] $basePath, [string] $targetPath) {
  $baseFullPath = [System.IO.Path]::GetFullPath($basePath)
  if (-not $baseFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $baseFullPath += [System.IO.Path]::DirectorySeparatorChar
  }

  $targetFullPath = [System.IO.Path]::GetFullPath($targetPath)
  $baseUri = New-Object System.Uri($baseFullPath)
  $targetUri = New-Object System.Uri($targetFullPath)
  $relativeUri = $baseUri.MakeRelativeUri($targetUri)
  $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString())
  return $relativePath.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

function ConvertTo-RtfUnicode([string] $value) {
  $builder = New-Object System.Text.StringBuilder
  foreach ($char in $value.ToCharArray()) {
    $code = [int][char]$char
    if ($code -eq 92) {
      [void] $builder.Append("\\")
    } elseif ($code -eq 123) {
      [void] $builder.Append("\{")
    } elseif ($code -eq 125) {
      [void] $builder.Append("\}")
    } elseif ($code -ge 32 -and $code -le 126) {
      [void] $builder.Append($char)
    } else {
      if ($code -gt 32767) {
        $code = $code - 65536
      }
      [void] $builder.Append("\u$code?")
    }
  }
  return $builder.ToString()
}

$componentIds = New-Object System.Collections.Generic.List[string]
$lines = New-Object System.Collections.Generic.List[string]

function Add-Line([int] $indent, [string] $line) {
  $lines.Add((" " * $indent) + $line)
}

function Add-Directory([System.IO.DirectoryInfo] $directory, [string] $directoryId, [int] $indent) {
  $files = Get-ChildItem -LiteralPath $directory.FullName -File | Sort-Object FullName
  foreach ($file in $files) {
    $relative = Get-RelativePathCompat $releasePath $file.FullName
    $componentId = New-StableId "Cmp_" $relative
    $fileId = New-StableId "Fil_" $relative
    $componentIds.Add($componentId)

    Add-Line $indent "<Component Id=`"$componentId`" Guid=`"*`">"
    Add-Line ($indent + 2) "<File Id=`"$fileId`" Source=`"$(Escape-Xml $file.FullName)`" KeyPath=`"yes`" />"
    Add-Line $indent "</Component>"
  }

  $directories = Get-ChildItem -LiteralPath $directory.FullName -Directory | Sort-Object FullName
  foreach ($child in $directories) {
    $relative = Get-RelativePathCompat $releasePath $child.FullName
    $childDirectoryId = New-StableId "Dir_" $relative
    Add-Line $indent "<Directory Id=`"$childDirectoryId`" Name=`"$(Escape-Xml $child.Name)`">"
    Add-Directory $child $childDirectoryId ($indent + 2)
    Add-Line $indent "</Directory>"
  }
}

$upgradeCode = "8D61B768-2E24-4B75-91C7-862C9B0F0157"
$wxsPath = Join-Path $workDir "shimx.wxs"
$licensePath = Join-Path $workDir "license.rtf"
$iconPath = Join-Path $root "windows\runner\resources\app_icon.ico"
$licenseZhPath = Join-Path $root "windows\installer\license.zh-CN.rtf"
$licenseEnPath = Join-Path $root "windows\installer\license.en-US.rtf"

Add-Line 0 "<?xml version=`"1.0`" encoding=`"UTF-8`"?>"
Add-Line 0 "<Wix xmlns=`"http://wixtoolset.org/schemas/v4/wxs`" xmlns:ui=`"http://wixtoolset.org/schemas/v4/wxs/ui`">"
Add-Line 2 "<Package Name=`"$(Escape-Xml $AppName)`" Manufacturer=`"$(Escape-Xml $Manufacturer)`" Version=`"$Version`" ProductCode=`"*`" UpgradeCode=`"$upgradeCode`" Scope=`"perMachine`">"
Add-Line 4 "<MajorUpgrade DowngradeErrorMessage=`"A newer version of [ProductName] is already installed.`" Schedule=`"afterInstallInitialize`" AllowSameVersionUpgrades=`"yes`" />"
Add-Line 4 "<MediaTemplate EmbedCab=`"yes`" />"
Add-Line 4 "<ui:WixUI Id=`"WixUI_InstallDir`" InstallDirectory=`"INSTALLFOLDER`" />"
Add-Line 4 "<WixVariable Id=`"WixUILicenseRtf`" Value=`"$(Escape-Xml $licensePath)`" />"
Add-Line 4 "<CustomAction Id=`"AppendAppNameToInstallFolder`" Property=`"INSTALLFOLDER`" Value=`"[INSTALLFOLDER]$(Escape-Xml $AppName)\`" />"
Add-Line 4 "<UI>"
Add-Line 6 "<Publish Dialog=`"BrowseDlg`" Control=`"OK`" Event=`"DoAction`" Value=`"AppendAppNameToInstallFolder`" Order=`"4`" Condition=`"WIXUI_INSTALLDIR = &quot;INSTALLFOLDER&quot; AND NOT INSTALLFOLDER &gt;&lt; &quot;\$(Escape-Xml $AppName)\&quot;`" />"
Add-Line 6 "<Publish Dialog=`"InstallDirDlg`" Control=`"Next`" Event=`"DoAction`" Value=`"AppendAppNameToInstallFolder`" Order=`"1`" Condition=`"WIXUI_INSTALLDIR = &quot;INSTALLFOLDER&quot; AND NOT INSTALLFOLDER &gt;&lt; &quot;\$(Escape-Xml $AppName)\&quot;`" />"
Add-Line 4 "</UI>"
if (Test-Path $iconPath) {
  Add-Line 4 "<Icon Id=`"AppIcon`" SourceFile=`"$(Escape-Xml $iconPath)`" />"
  Add-Line 4 "<Property Id=`"ARPPRODUCTICON`" Value=`"AppIcon`" />"
}
Add-Line 4 "<Property Id=`"INSTALLFOLDER`">"
Add-Line 6 "<RegistrySearch Id=`"PreviousInstallFolderSearch`" Root=`"HKLM`" Key=`"Software\$AppName`" Name=`"InstallDir`" Type=`"raw`" />"
Add-Line 4 "</Property>"
Add-Line 4 "<StandardDirectory Id=`"ProgramFiles64Folder`">"
Add-Line 6 "<Directory Id=`"INSTALLFOLDER`" Name=`"$(Escape-Xml $AppName)`">"
Add-Directory (Get-Item $releasePath) "INSTALLFOLDER" 8
Add-Line 8 "<Component Id=`"InstallRegistryComponent`" Guid=`"*`">"
Add-Line 10 "<RegistryKey Root=`"HKLM`" Key=`"Software\$AppName`">"
Add-Line 12 "<RegistryValue Name=`"InstallDir`" Type=`"string`" Value=`"[INSTALLFOLDER]`" KeyPath=`"yes`" />"
Add-Line 12 "<RegistryValue Name=`"Version`" Type=`"string`" Value=`"[ProductVersion]`" />"
Add-Line 10 "</RegistryKey>"
Add-Line 8 "</Component>"
Add-Line 6 "</Directory>"
Add-Line 4 "</StandardDirectory>"
Add-Line 4 "<StandardDirectory Id=`"ProgramMenuFolder`">"
Add-Line 6 "<Directory Id=`"ApplicationProgramsFolder`" Name=`"$(Escape-Xml $AppName)`">"
Add-Line 8 "<Component Id=`"StartMenuShortcutComponent`" Guid=`"*`">"
Add-Line 10 "<Shortcut Id=`"ApplicationStartMenuShortcut`" Name=`"$(Escape-Xml $AppName)`" Description=`"$(Escape-Xml $AppName)`" Target=`"[INSTALLFOLDER]$ExecutableName`" WorkingDirectory=`"INSTALLFOLDER`" />"
Add-Line 10 "<Shortcut Id=`"ApplicationStartMenuUninstallShortcut`" Name=`"!(loc.UninstallShortcutName)`" Description=`"!(loc.UninstallShortcutName)`" Target=`"[SystemFolder]msiexec.exe`" Arguments=`"/x [ProductCode]`" />"
Add-Line 10 "<RemoveFolder Id=`"RemoveApplicationProgramsFolder`" On=`"uninstall`" />"
Add-Line 10 "<RegistryValue Root=`"HKCU`" Key=`"Software\$AppName\StartMenu`" Name=`"installed`" Type=`"integer`" Value=`"1`" KeyPath=`"yes`" />"
Add-Line 8 "</Component>"
Add-Line 6 "</Directory>"
Add-Line 4 "</StandardDirectory>"
Add-Line 4 "<StandardDirectory Id=`"DesktopFolder`">"
Add-Line 6 "<Component Id=`"DesktopShortcutComponent`" Guid=`"*`">"
Add-Line 8 "<Shortcut Id=`"ApplicationDesktopShortcut`" Name=`"$(Escape-Xml $AppName)`" Description=`"$(Escape-Xml $AppName)`" Target=`"[INSTALLFOLDER]$ExecutableName`" WorkingDirectory=`"INSTALLFOLDER`" />"
Add-Line 8 "<RegistryValue Root=`"HKCU`" Key=`"Software\$AppName\Desktop`" Name=`"installed`" Type=`"integer`" Value=`"1`" KeyPath=`"yes`" />"
Add-Line 6 "</Component>"
Add-Line 4 "</StandardDirectory>"
Add-Line 4 "<Feature Id=`"MainFeature`" Title=`"$(Escape-Xml $AppName)`" Level=`"1`">"
foreach ($componentId in $componentIds) {
  Add-Line 6 "<ComponentRef Id=`"$componentId`" />"
}
Add-Line 6 "<ComponentRef Id=`"StartMenuShortcutComponent`" />"
Add-Line 6 "<ComponentRef Id=`"DesktopShortcutComponent`" />"
Add-Line 6 "<ComponentRef Id=`"InstallRegistryComponent`" />"
Add-Line 4 "</Feature>"
Add-Line 2 "</Package>"
Add-Line 0 "</Wix>"

Set-Content -Path $wxsPath -Value $lines -Encoding UTF8

foreach ($targetCulture in $Cultures) {
  if ([string]::IsNullOrWhiteSpace($targetCulture)) {
    continue
  }

  if ($targetCulture -ieq "zh-CN") {
    $sourceLicensePath = $licenseZhPath
  } else {
    $sourceLicensePath = $licenseEnPath
  }
  if (-not (Test-Path $sourceLicensePath)) {
    throw "License file not found: $sourceLicensePath"
  }
  Copy-Item -LiteralPath $sourceLicensePath -Destination $licensePath -Force

  $safeCulture = $targetCulture.Replace("/", "-").Replace([string][char]92, "-")
  $locPath = Join-Path $workDir "strings.$safeCulture.wxl"
  if ($targetCulture -ieq "zh-CN") {
    $locCodepage = "936"
    $uninstallShortcutName = "&#x5378;&#x8F7D; $(Escape-Xml $AppName)"
  } else {
    $locCodepage = "1252"
    $uninstallShortcutName = "Uninstall $(Escape-Xml $AppName)"
  }
  $locLines = @(
    "<?xml version=`"1.0`" encoding=`"UTF-8`"?>",
    "<WixLocalization xmlns=`"http://wixtoolset.org/schemas/v4/wxl`" Culture=`"$targetCulture`" Codepage=`"$locCodepage`">",
    "  <String Id=`"UninstallShortcutName`" Value=`"$uninstallShortcutName`" />",
    "</WixLocalization>"
  )
  Set-Content -Path $locPath -Value $locLines -Encoding UTF8

  $msiPath = Join-Path $OutputDir "$AppName-$Version-x64-$safeCulture.msi"

  $wixArgs = New-Object System.Collections.Generic.List[string]
  $wixArgs.Add("build")
  if ($AcceptWix7Eula) {
    $wixArgs.Add("-acceptEula")
    $wixArgs.Add("wix7")
  }
  $wixArgs.Add("-ext")
  $wixArgs.Add("WixToolset.UI.wixext")
  $wixArgs.Add($wxsPath)
  $wixArgs.Add("-arch")
  $wixArgs.Add("x64")
  $wixArgs.Add("-culture")
  $wixArgs.Add($targetCulture)
  $wixArgs.Add("-loc")
  $wixArgs.Add($locPath)
  $wixArgs.Add("-o")
  $wixArgs.Add($msiPath)

  & $wix.Source @wixArgs
  if ($LASTEXITCODE -ne 0) {
    throw "WiX build failed for culture: $targetCulture"
  }

  Write-Host "MSI created: $msiPath"
}
