<?php
//当客户端访问http://url/1.php?token=XXXX 时会自动将客户端的ip提交至服务器
//当客户端访问http://url/1.php?token=XXXX&ip=1.1.1.1 会将指定ip提交至服务器
//若需要查询客户端IP可访问http://url/1.php?opt=get_ip 此时不验证token

$token = isset($_GET['token']) ? $_GET['token'] : null;
$ip = isset($_GET['ip']) ? $_GET['ip'] : $_SERVER['REMOTE_ADDR']; // 默认使用访问客户端的IP地址
$opt = isset($_GET['opt']) ? $_GET['opt'] : null;

// 验证Token
$validToken = '123456'; // 替换为你的有效Token

// 文件保存路径
$filePath = '/tmp/ip_data.txt';

if ($opt === 'get_ip') {
    // 如果请求是获取IP地址，则尝试读取保存的IP地址
    if (file_exists($filePath)) {
        $clientIP = file_get_contents($filePath);
        echo $clientIP;
    } else {
        echo "没有找到之前提交的 IP 地址";
    }
} elseif ($token === $validToken) {
    // 如果请求包含IP，则保存IP地址到文件
    if (isset($_GET['ip'])) {
        file_put_contents($filePath, $ip);
        echo "IP 地址已提交至服务器: " . $ip;
    } else {
        // 如果请求只包含Token，则提交客户端的IP地址到文件
        file_put_contents($filePath, $_SERVER['REMOTE_ADDR']);
        echo "客户端的 IP 地址已提交至服务器: " . $_SERVER['REMOTE_ADDR'];
    }
} else {
    echo "success";
}
?>
