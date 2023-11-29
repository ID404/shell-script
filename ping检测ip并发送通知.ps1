#此脚本为ping 指定IP地址，当10个包都无法ping通时，访问指定url以发送通知


try {
    $ping = New-Object System.Net.NetworkInformation.Ping
    $ipAddress = "10.10.10.10"
    $numberOfPings = 10

    $unsuccessfulPings = 0
    for ($i = 0; $i -lt $numberOfPings; $i++) {
        $pingResult = $ping.Send($ipAddress)

        if ($pingResult.Status -ne "Success") {
            $unsuccessfulPings++
        }
    }

    if ($unsuccessfulPings -eq $numberOfPings) {
        # 如果连续10次都ping不通，则发送通知
        $url = "https://api.day.app/Rf77gX/Hxyy/Hxyy_Ipsec_down!!"

        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadString($url)
            $webClient.Dispose()
            Write-Host "无法ping通目标主机，已发送通知"
        } catch {
            Write-Host "无法访问URL: $_"
        }
    } else {
        Write-Host "目标主机可以正常ping通"
    }
} catch {
    Write-Host "无法ping通目标主机: $_"
}

 
