Write-Host "����һ���򵥵� TCP �����������ڼ���ָ���Ķ˿ڣ����������Կͻ��˵����ݡ�"
Write-Host "�ͻ�����ʹ��telnet IP + �˿ڵķ�ʽ������������"
Write-Host "Ŀǰͬʱֻ֧�ֵ����ͻ��ˣ��������Ӷ���ͻ��ˣ��ᵼ�³��������쳣"
Write-Host "���ߣ�ID404"
Write-Host "�汾��1.0"
Write-Host ""
Write-Host "�����������ִ�г���..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


# �����˿�
$port = Read-Host -Prompt "�����������TCP�˿�"
Write-Host "��ǰ�����ӿ�ΪTCP $port"

# ��ȡ����IPv4��ַ
$ipAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike 'Loopback*' }).IPAddress
Write-Host "��ǰ���Ե� IP ��ַ�ǣ�$ipAddresses"

# ���� TcpListener ���󲢿�ʼ����
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$listener.Start()

# �ȴ��ͻ�������
Write-Host "�ȴ��ͻ�������..."

try {
    while ($true) {
        # ���ܿͻ������Ӳ���ȡ�ͻ��˵�����������
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()

        # ��ȡ�ͻ��˵� IP ��ַ
        $clientIP = $client.Client.RemoteEndPoint.Address
        Write-Host "�ͻ��� $clientIP ���ӳɹ�"

        # ѭ�����տͻ��˷��͵�����
        while ($true) {
            # ���տͻ��˷��͵�����
            $bufferSize = 1024
            $buffer = New-Object byte[] $bufferSize
            $bytesRead = $stream.Read($buffer, 0, $bufferSize)
            $data = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)
            Write-Host "���յ��ͻ��˷��͵����ݣ�$data"

            # �ظ��ͻ���
            $response = "�ѽ��յ����ݣ�$data"
            $responseBuffer = [System.Text.Encoding]::UTF8.GetBytes($response)
            $stream.Write($responseBuffer, 0, $responseBuffer.Length)
            $stream.Flush()

            # ����ͻ��˷��͵�����Ϊ "exit" �� "quit"����Ͽ��ͻ�������
            if ($data.ToLower().Trim() -eq "exit" -or $data.ToLower().Trim() -eq "quit") {
                $client.Close()
                Write-Host "�ͻ��� $clientIP �����ѶϿ�"
                break
            }
        }
    }
}
finally {
    # �رռ���������
    $listener.Stop()
    $stream.Dispose()
    $client.Close()
    Read-Host "�밴������˳�����..."
}