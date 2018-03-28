function Disable-Proxy {
  "Disabling Proxy Settings"
  "-Resetting WinHTTP Proxy Settings"
  & netsh winhttp reset proxy

  "-Resetting WinINET Proxy Settings"
  [SetProxy.ProxyRoutines]::SetProxy($false)

  "-Turning off Machine-Wide Proxy Setting"
  Upsert-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxySettingsPerUser' -Value 0x1
}
