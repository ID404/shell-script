Write-Host "这是一个简单的 TCP 服务器，用于监听指定的端口，并接收来自客户端的数据。"
Write-Host "客户端请使用telnet IP + 端口的方式连接至服务器"
Write-Host "目前同时只支持单个客户端，请勿连接多个客户端，会导致程序运行异常"
Write-Host "作者：ID404"
Write-Host "版本：1.0"
Write-Host ""
Write-Host "按任意键继续执行程序..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


# 监听端口
$port = Read-Host -Prompt "请输入监听的TCP端口"
Write-Host "当前监听接口为TCP $port"

# 获取本机IPv4地址
$ipAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike 'Loopback*' }).IPAddress
Write-Host "当前电脑的 IP 地址是：$ipAddresses"

# 创建 TcpListener 对象并开始监听
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$listener.Start()

# 等待客户端连接
Write-Host "等待客户端连接..."

try {
    while ($true) {
        # 接受客户端连接并获取客户端的网络流对象
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()

        # 获取客户端的 IP 地址
        $clientIP = $client.Client.RemoteEndPoint.Address
        Write-Host "客户端 $clientIP 连接成功"

        # 循环接收客户端发送的数据
        while ($true) {
            # 接收客户端发送的数据
            $bufferSize = 1024
            $buffer = New-Object byte[] $bufferSize
            $bytesRead = $stream.Read($buffer, 0, $bufferSize)
            $data = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)
            Write-Host "接收到客户端发送的数据：$data"

            # 回复客户端
            $response = "已接收到数据：$data"
            $responseBuffer = [System.Text.Encoding]::ASCII.GetBytes($response)
            $stream.Write($responseBuffer, 0, $responseBuffer.Length)
            $stream.Flush()

            # 如果客户端发送的数据为 "exit" 或 "quit"，则断开客户端连接
            if ($data.ToLower().Trim() -eq "exit" -or $data.ToLower().Trim() -eq "quit") {
                $client.Close()
                Write-Host "客户端 $clientIP 连接已断开"
                break
            }
        }
    }
}
finally {
    # 关闭监听器和流
    $listener.Stop()
    $stream.Dispose()
    $client.Close()
    Read-Host "请按任意键退出程序..."
}
