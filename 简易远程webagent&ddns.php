<?php
//当客户端访问http://url/1.php?token=XXXX 时会自动将客户端的ip提交至服务器
//当客户端访问http://url/1.php?token=XXXX&ip=1.1.1.1 会将指定ip提交至服务器
//若需要查询客户端IP可访问http://url/1.php?opt=get_ip 此时不验证token


// 获取请求参数
$token = isset($_GET['token']) ? $_GET['token'] : null;
$ip = isset($_GET['ip']) ? $_GET['ip'] : $_SERVER['REMOTE_ADDR']; // 默认使用访问客户端的IP地址
$opt = isset($_GET['opt']) ? $_GET['opt'] : null;

// 验证Token
$validToken = '123456'; // 替换为你的有效Token
$user_ip_file = "/data/ddns/hxyy/client.txt";

function validateIP($ip) {
    // 使用filter_var函数验证IP地址格式
    return filter_var($ip, FILTER_VALIDATE_IP);
}

if ($opt === 'get_ip') {
    // 如果请求是获取IP地址，则从文件中读取保存的IP地址
    $clientIP = file_get_contents($user_ip_file);
    if ($clientIP !== false) {
        echo $clientIP;
    } else {
        echo "没有找到之前提交的 IP 地址";
    }
} elseif ($token === $validToken) {
    // 如果请求包含IP，则验证IP地址并保存IP地址到文件中
    if (isset($_GET['ip']) && validateIP($ip)) {
        file_put_contents($user_ip_file, $ip);
        echo "IP 地址已提交至服务器: " . $ip;
    } elseif (!isset($_GET['ip'])) {
        // 如果请求只包含Token，则提交客户端的IP地址到文件中
        file_put_contents($user_ip_file, $_SERVER['REMOTE_ADDR']);
        echo "客户端的 IP 地址已提交至服务器: " . $_SERVER['REMOTE_ADDR'];
    } else {
        echo "无效的 IP 地址";
    }
} else {
    echo "success";
}
?>
