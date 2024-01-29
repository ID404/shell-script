#!/bin/bash
#此脚本用于自动生成CA证书、服务器证书、用户证书和吊销用户证书，可用于配置ocserv证书认证

function generate_ca() {
    # Generate a CA Private Key
    certtool --generate-privkey --rsa --bits 4096 --outfile ./ca_cert/ca-key.pem

    # Generate a CA Certificate
    cat > ca-temp.txt <<EOF
cn = "Root CA"
organization = "ID404 Company"
serial = 001
expiration_days = -1
ca
signing_key
cert_signing_key
crl_signing_key
EOF

    certtool --generate-self-signed --load-privkey ./ca_cert/ca-key.pem --template ca-temp.txt --outfile ./ca_cert/ca-cert.pem
    rm ca-temp.txt
    exit 1
}

function generate_server_cert() {
    read -p "Enter Domain Name: " domain_name

    # Server Private Key
    certtool --generate-privkey --rsa --bits 4096  --outfile ./server_cert/$domain_name-key.pem

    # Server Certificate
    echo "organization = $domain_name" > server-temp.txt

    cat <<EOF >server-temp.txt
cn = $domain_name
organization = $domain_name
serial = 2
expiration_days = 360
signing_key
encryption_key
tls_www_server
dns_name = $domain_name
EOF

    certtool --generate-certificate --hash SHA256 --load-privkey ./server_cert/$domain_name-key.pem --load-ca-certificate ./ca_cert/ca-cert.pem --load-ca-privkey ./ca_cert/ca-key.pem --template server-temp.txt --outfile ./server_cert/$domain_name-cert.pem
    rm server-temp.txt
    exit 1
}

function generate_user_cert() {
    read -p "Enter Username: " username

    # User Private Key
    certtool --generate-privkey --rsa --bits 4096 --outfile ./user_cert/$username-key.pem

    # User Certificate
    echo "cn = $username" > user-temp.txt
    echo "uid = $username" >> user-temp.txt
    echo "organization = ID404 Company" >> user-temp.txt
    echo "signing_key" >> user-temp.txt
    echo "tls_www_client" >> user-temp.txt
    certtool --generate-certificate --hash SHA256 --load-privkey ./user_cert/$username-key.pem --load-ca-certificate ./ca_cert/ca-cert.pem --load-ca-privkey ./ca_cert/ca-key.pem --template user-temp.txt --outfile ./user_cert/$username-cert.pem
    rm user-temp.txt

    # User Certificate in PKCS#12 Format
    #openssl pkcs12 -export -in ./user_cert/$username-cert.pem -inkey ./user_cert/$username-key.pem -out ./user_cert/$username.p12 -name "$username User Certificate"

    certtool --to-p12 --load-privkey ./user_cert/$username-key.pem --load-certificate ./user_cert/$username-cert.pem --pkcs-cipher 3des-pkcs12 --outfile ./user_cert/$username-ios.p12 --outder

    exit 1
}

function revoke_user_cert() {
    read -p "Enter Username to Revoke: " username

    # Revoke Certificate
    echo "crl_next_update = 365" > revoke-temp.txt
    echo "crl_number = 1" >> revoke-temp.txt
    certtool --generate-crl --hash SHA256 --load-ca-privkey ./ca_cert/ca-key.pem --load-ca-certificate ./ca_cert/ca-cert.pem --load-certificate ./user_cert/$username-cert.pem --template revoke-temp.txt --outfile crl.pem
    rm revoke-temp.txt
    exit 1
}


# 遍历目录名
for dir in "${dirs[@]}"
do
    # 如果目录不存在，则创建它
    if [[ ! -d $dir ]]; then
        echo "Directory $dir does not exist. Creating now..."
        mkdir $dir
        echo "Directory $dir created."
    else
        echo "Directory $dir exists."
    fi
done

PS3='Please enter your choice: '

options=("Generate CA Certificate" "Generate Server Certificate" "Generate User Certificate" "Revoke User Certificate" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Generate CA Certificate")
            generate_ca
            ;;
        "Generate Server Certificate")
            generate_server_cert
            ;;
        "Generate User Certificate")
            generate_user_cert
            ;;
        "Revoke User Certificate")
            revoke_user_cert
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
