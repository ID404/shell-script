
while ($true) {
    $interface = Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Wireless*"}
    $speed = $interface | Select-Object -ExpandProperty LinkSpeed
    $current_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $channel = (netsh wlan show interfaces | Select-String -Pattern "�ŵ�").Line -replace '\D+(\d+).*', '$1'
    $output = "{0} - ��ǰ WiFi ����Ϊ��{1}  �ŵ�Ϊ��{2}" -f $current_time, $speed ,$channel
    Write-Output $output
    $output | Out-File -Append -FilePath ".\wifi-speed-test.log"

    Start-Sleep -Seconds 1
}

