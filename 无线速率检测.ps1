
while ($true) {
    $interface = Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Wireless*"}
    $speed = $interface | Select-Object -ExpandProperty LinkSpeed
    $current_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output ("{0} - 当前 WiFi 速率为：{1} " -f $current_time, $speed)
    Start-Sleep -Seconds 1
}