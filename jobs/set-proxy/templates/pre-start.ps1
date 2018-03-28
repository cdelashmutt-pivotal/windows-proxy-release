Start-Sleep 5

$ErrorActionPreference = "Stop";
trap {
    $formatstring = "{0} : {1}`n{2}`n" +
                    "    + CategoryInfo          : {3}`n"
                    "    + FullyQualifiedErrorId : {4}`n"
    $fields = $_.InvocationInfo.MyCommand.Name,
              $_.ErrorDetails.Message,
              $_.InvocationInfo.PositionMessage,
              $_.CategoryInfo.ToString(),
              $_.FullyQualifiedErrorId

    $formatstring -f $fields
    Exit 1
}

# Support functions
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "proxy-routines.ps1")

function Test-RegistryValue {
  param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Value
  )

  try {
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $true
  }
  catch {
    return $false
  }
}

function Upsert-RegistryValue {
  param (
    [parameter(Mandatory=$true)]
    [string]$Path,
    [parameter(Mandatory=$true)]
    [string]$Name,
    [parameter(Mandatory=$true)]
    $Value
  )

  if( (Test-RegistryValue -Path $Path -Value $Name) -eq $true) {
    Write-Host "-Updating $(Join-Path $Path $Name) to $Value"
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
  }
  else {
    Write-Host "-Creating $(Join-Path $Path $Name) and setting to $Value"
    New-ItemProperty -Path $Path -Name $Name -Value $Value
  }
}

$Enabled=[bool]$<%= p("set-proxy.enabled") %>

# Disable Proxy
if (-not $Enabled) {
  Write-Host "Disabling Proxy Settings"
  Write-Host "-Resetting WinHTTP Proxy Settings"
  & netsh winhttp reset proxy

  Write-Host "-Resetting WinINET Proxy Settings"
  [SetProxy.ProxyRoutines]::SetProxy($false)

  Write-Host "-Turning off Machine-Wide Proxy Setting"
  Upsert-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxySettingsPerUser' -Value 0x1
}
else {
  Write-Host "Enabling Proxy Settings"
  $proxyServer = "<%= p("set-proxy.proxy-url") %>"
  $bypassList = "<%= p("set-proxy.bypass-list") %>"

  Write-Host "`nTurning on Machine-Wide Proxy Setting"
  Upsert-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxySettingsPerUser' -Value 0x0

  Write-Host "Setting WinINET Proxy Settings"
  [SetProxy.ProxyRoutines]::SetProxy($proxyServer,$bypassList)

  Write-Host "Setting WinHTTP Proxy Settings"
  & netsh winhttp set proxy "$($proxyServer)" "$($bypassList)"
}
