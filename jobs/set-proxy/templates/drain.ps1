Start-Sleep 5

$OutLog = "C:\var\vcap\sys\log\set-proxy\drain.stdout.log"
$ErrLog = "C:\var\vcap\sys\log\set-proxy\drain.stderr.log"

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

    $formatstring -f $fields | Out-File -FilePath $ErrLog -Encoding ascii
    Exit 1
}

echo "Starting to disable proxy" | Out-File -FilePath $OutLog -Encoding ascii

$dir = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $dir "proxy-routines.ps1")
. (Join-Path $dir "disable-proxy.ps1")

echo "Disabling proxy" | Out-File -FilePath $OutLog -Encoding ascii
Disable-Proxy | Out-File -FilePath $OutLog -Encoding ascii

echo "Done" | Out-File -FilePath $OutLog -Encoding ascii
"0"
Exit 0
