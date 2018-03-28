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

$Enabled=[bool]$<%= p("set-proxy.enabled") %>

# Disable Proxy
if (-not $Enabled) {
  . (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "disable-proxy.ps1")
  Write-Host "Disabling Proxy"
  Disable-Proxy
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
